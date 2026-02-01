import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:ui';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:provider/provider.dart';
import 'package:sant_app/provider/location_provider.dart';
import 'package:sant_app/provider/util_provider.dart';
import 'package:sant_app/themes/app_images.dart';
import 'package:sant_app/themes/app_colors.dart';
import 'package:sant_app/themes/app_fonts.dart';
import 'package:sant_app/utils/toast_bar.dart';
import 'package:sant_app/widgets/add_direction_search_bottom_sheet.dart';
import 'package:sant_app/widgets/app_drawer.dart';
import 'package:sant_app/widgets/app_scaffold.dart';
import 'package:sant_app/widgets/app_textfield.dart';
import 'package:sant_app/widgets/keys.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SearchScreen extends StatefulWidget {
  final String? profileType;
  final bool? isUser;

  const SearchScreen({super.key, this.profileType, this.isUser});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  late LocationProvider provider;
  late UtilProvider utilProvider;
  bool isLoading = true;

  TextEditingController searchController = TextEditingController();

  double? latitude, longitude;
  LatLng myLocation = const LatLng(23.0225, 72.5714);
  final List<Marker> _markers = [];
  final Set<Circle> _circles = {};
  GoogleMapController? _controller;
  final Completer<GoogleMapController> _mapController = Completer();

  final Set<Polyline> _santPolylines = {};
  final Set<Polyline> _userPolylines = {};

  bool isJourneyStarted = false;
  LatLng? _currentDestination;

  bool isUser = true;
  String? profileType;

  bool _isFetchingDirections = false;

  @override
  void initState() {
    super.initState();
    provider = Provider.of<LocationProvider>(context, listen: false);
    utilProvider = Provider.of<UtilProvider>(context, listen: false);
    _initAsync().then((_) {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    });
  }

  Future<BitmapDescriptor> _getCircularMarker({
    String? imageUrl,
    int size = 150,
  }) async {
    final recorder = PictureRecorder();
    final canvas = Canvas(recorder);
    final paint = Paint()..isAntiAlias = true;

    final double radius = size / 2;
    final center = Offset(radius, radius);

    // Outer circle
    paint.color = const Color(0xFFF3821E);
    canvas.drawCircle(center, radius, paint);

    ui.Image image;

    // 🔥 LOAD FROM API IF AVAILABLE
    if (imageUrl != null && imageUrl.isNotEmpty) {
      try {
        final response = await http.get(Uri.parse(imageUrl));
        final codec = await instantiateImageCodec(
          response.bodyBytes,
          targetWidth: (size * 0.75).toInt(),
          targetHeight: (size * 0.75).toInt(),
        );
        image = (await codec.getNextFrame()).image;
      } catch (_) {
        final data = await rootBundle.load(AppLogos.appLogo);
        final codec = await instantiateImageCodec(data.buffer.asUint8List());
        image = (await codec.getNextFrame()).image;
      }
    } else {
      final data = await rootBundle.load(AppLogos.appLogo);
      final codec = await instantiateImageCodec(data.buffer.asUint8List());
      image = (await codec.getNextFrame()).image;
    }

    final imgRadius = radius * 0.75;
    final imgOffset = Offset(radius - imgRadius, radius - imgRadius);
    final imgRect = Rect.fromLTWH(
      imgOffset.dx,
      imgOffset.dy,
      imgRadius * 2,
      imgRadius * 2,
    );

    final imgPaint = Paint()..isAntiAlias = true;

    canvas.saveLayer(imgRect, Paint());
    canvas.drawCircle(center, imgRadius, imgPaint);
    imgPaint.blendMode = BlendMode.srcIn;

    canvas.drawImageRect(
      image,
      Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble()),
      imgRect,
      imgPaint,
    );

    canvas.restore();

    final picture = recorder.endRecording();
    final imgFinal = await picture.toImage(size, size);
    final byteData = await imgFinal.toByteData(format: ImageByteFormat.png);

    return BitmapDescriptor.fromBytes(byteData!.buffer.asUint8List());
  }

  LatLngBounds _createLatLngBoundsFromMarkers(List<Marker> markers) {
    double? x0, x1, y0, y1;
    for (var marker in markers) {
      if (x0 == null) {
        x0 = x1 = marker.position.latitude;
        y0 = y1 = marker.position.longitude;
      } else {
        if (marker.position.latitude > x1!) x1 = marker.position.latitude;
        if (marker.position.latitude < x0) x0 = marker.position.latitude;
        if (marker.position.longitude > y1!) y1 = marker.position.longitude;
        if (marker.position.longitude < y0!) y0 = marker.position.longitude;
      }
    }
    return LatLngBounds(
      southwest: LatLng(x0!, y0!),
      northeast: LatLng(x1!, y1!),
    );
  }

  List<String> selectedSamajIds = [];

  Future<void> _initAsync() async {
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      toastMessage("Location Permission is not allowed");
    }
    try {
      Position pos = await Geolocator.getCurrentPosition(
        forceAndroidLocationManager: true,
        desiredAccuracy: LocationAccuracy.high,
      );

      latitude = pos.latitude;
      longitude = pos.longitude;
      myLocation = LatLng(latitude!, longitude!);

      final prefs = await SharedPreferences.getInstance();
      selectedSamajIds = prefs.getStringList("selectedSamaj") ?? [];

      Map<String, dynamic> body = {};
      if (selectedSamajIds.isNotEmpty) {
        body["samaj"] = selectedSamajIds;
      }

      String city = await getCityFromCoordinates(latitude!, longitude!);

      if (!isJourneyStarted) {
        setState(() {
          _markers.removeWhere((m) => m.markerId.value.startsWith('user_'));
          _userPolylines.clear();
        });
      }

      await provider.getNearbySantList(
        data: {"city": city, ...body},
        offSet: 0,
        city: city,
      );

      if (provider.nearbySantList.isNotEmpty) {
        Set<Marker> santMarkers = {};

        for (final sant in provider.nearbySantList) {
          final BitmapDescriptor currentMarkerIcon = await _getCircularMarker(
            imageUrl: sant.saintDetail.profileImage,
            size: 130,
          );

          final journey = sant.journeyDetail;
          final from = LatLng(journey.startLatitude, journey.startLongitude);
          final to = LatLng(journey.endLatitude, journey.endLongitude);
          final current = LatLng(
            journey.currentLatitude,
            journey.currentLongitude,
          );

          santMarkers.add(
            Marker(
              markerId: MarkerId('${sant.saintDetail.saintId}_from'),
              position: from,
              infoWindow: InfoWindow(
                title: '${sant.saintDetail.name} - Start',
                snippet: sant.journeyDetail.currentCity,
              ),
              icon: BitmapDescriptor.defaultMarkerWithHue(
                BitmapDescriptor.hueBlue,
              ),
            ),
          );

          santMarkers.add(
            Marker(
              markerId: MarkerId('${sant.saintDetail.saintId}_to'),
              position: to,
              infoWindow: const InfoWindow(title: 'Destination'),
              icon: BitmapDescriptor.defaultMarkerWithHue(
                BitmapDescriptor.hueGreen,
              ),
            ),
          );

          santMarkers.add(
            Marker(
              markerId: MarkerId('${sant.saintDetail.saintId}_current'),
              position: current,
              infoWindow: InfoWindow(
                title: sant.saintDetail.name,
                snippet: 'Current Location',
              ),
              icon: currentMarkerIcon,
            ),
          );

          await getDirections(from, to);
        }

        setState(() {
          _markers.addAll(santMarkers);
        });

        if (santMarkers.isNotEmpty) {
          final bounds = _createLatLngBoundsFromMarkers(santMarkers.toList());
          _controller?.animateCamera(CameraUpdate.newLatLngBounds(bounds, 80));
        }
      }

      await _restoreJourneyIfNeeded();
      await _initLocationTracking();
    } catch (e) {
      setState(() {});
    }
  }

  Future<void> _initLocationTracking() async {
    Position currentPosition = await getUserCurrentLocation();
    latitude = currentPosition.latitude;
    longitude = currentPosition.longitude;
    myLocation = LatLng(latitude!, longitude!);

    if (_controller == null && _mapController.isCompleted) {
      _controller = await _mapController.future;
    }

    _controller?.animateCamera(CameraUpdate.newLatLngZoom(myLocation, 15));

    Geolocator.getPositionStream().listen((Position newPosition) async {
      if (mounted) {
        setState(() {
          latitude = newPosition.latitude;
          longitude = newPosition.longitude;
          myLocation = LatLng(latitude!, longitude!);
          _markers.removeWhere((m) => m.markerId.value == 'myLocation');
        });

        if (isJourneyStarted &&
            _currentDestination != null &&
            !_isFetchingDirections) {
          _isFetchingDirections = true;
          await getDirections(myLocation, _currentDestination!);
          _isFetchingDirections = false;
        } else if (!isJourneyStarted) {
          return;
          // _controller?.animateCamera(CameraUpdate.newLatLng(myLocation));
        }
      }
    });
  }

  Future<Position> getUserCurrentLocation() async {
    LocationPermission permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      toastMessage("Location Permission is not allowed");
      return Future.error(
        "Location permission is not allowed. Please enable it from Settings.",
      );
    }
    return await Geolocator.getCurrentPosition();
  }

  Future<String> getCityFromCoordinates(double lat, double lng) async {
    const String apiKey = 'AIzaSyBRfHrwA5qB4VynIyDqGIgx0NGJ0AJdtPM';
    final url =
        'https://maps.googleapis.com/maps/api/geocode/json?latlng=$lat,$lng&key=$apiKey';
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final results = data['results'] as List<dynamic>;
      if (results.isNotEmpty) {
        final components = results[0]['address_components'] as List<dynamic>;
        var cityComp = components.firstWhere(
          (c) => (c['types'] as List).contains('locality'),
          orElse: () => null,
        );
        cityComp ??= components.firstWhere(
          (c) => (c['types'] as List).contains('administrative_area_level_2'),
          orElse: () => null,
        );
        return cityComp != null ? cityComp['long_name'] : '';
      } else {
        return '';
      }
    }
    return '';
  }

  Future<void> getDirections(LatLng origin, LatLng destination) async {
    const String apiKey = 'AIzaSyBRfHrwA5qB4VynIyDqGIgx0NGJ0AJdtPM';
    final String url =
        'https://maps.googleapis.com/maps/api/directions/json?origin=${origin.latitude},${origin.longitude}&destination=${destination.latitude},${destination.longitude}&key=$apiKey';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if ((data['routes'] as List).isNotEmpty) {
          final points = data['routes'][0]['overview_polyline']['points'];
          final List<PointLatLng> result = _decodePoly(points);
          final List<LatLng> polylineCoordinates = result
              .map((point) => LatLng(point.latitude, point.longitude))
              .toList();

          setState(() {
            _santPolylines.add(
              Polyline(
                polylineId: PolylineId(
                  'sant_route_${origin.latitude}_${origin.longitude}',
                ),
                points: polylineCoordinates,
                width: 3,
                color: Colors.black,
              ),
            );
          });
        }
      }
    } catch (_) {}
  }

  // Filter Popup
  Future<void> _showFilterDialog() async {
    final samajList = utilProvider.samajList;
    final prefs = await SharedPreferences.getInstance();
    selectedSamajIds = prefs.getStringList("selectedSamaj") ?? [];
    final tempSelectedIds = Set<String>.from(selectedSamajIds);

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Filter Samaj'),
          content: SizedBox(
            width: double.maxFinite,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: samajList.map((samaj) {
                  return CheckboxListTile(
                    controlAffinity: ListTileControlAffinity.leading,
                    contentPadding: EdgeInsets.zero,
                    title: Text(samaj.samajName ?? 'N/A'),
                    value: tempSelectedIds.contains(samaj.samajId),
                    onChanged: (value) {
                      if (value == true) {
                        tempSelectedIds.add(samaj.samajId ?? '');
                      } else {
                        tempSelectedIds.remove(samaj.samajId);
                      }
                      (context as Element).markNeedsBuild();
                    },
                  );
                }).toList(),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                selectedSamajIds = tempSelectedIds.toList();
                await prefs.setStringList("selectedSamaj", selectedSamajIds);

                setState(() {
                  isLoading = true;
                  _markers.clear();
                  _santPolylines.clear();
                });

                Navigator.of(context).pop();
                setState(() => isLoading = true);
                await _initAsync();
                if (mounted) setState(() => isLoading = false);
              },
              child: Text('Apply'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _refreshIfFilterChanged() async {
    final prefs = await SharedPreferences.getInstance();
    final latestFilters = prefs.getStringList("selectedSamaj") ?? [];

    if (!listEquals(latestFilters, selectedSamajIds) && !isLoading) {
      selectedSamajIds = latestFilters;
      setState(() {
        isLoading = true;
        _markers.clear();
        _santPolylines.clear();
      });

      await _initAsync();
      if (mounted) setState(() => isLoading = false);
    }
  }

  Future<void> _restoreJourneyIfNeeded() async {
    final prefs = await SharedPreferences.getInstance();
    final journeyStarted = prefs.getBool('journeyStarted') ?? false;
    if (!journeyStarted) return;

    final destLat = prefs.getDouble('destination_lat');
    final destLng = prefs.getDouble('destination_lng');
    if (destLat == null || destLng == null) return;

    final destination = LatLng(destLat, destLng);
    _currentDestination = destination;
    isJourneyStarted = true;

    _markers.removeWhere((m) => m.markerId.value == 'user_destination');
    _markers.add(
      Marker(
        markerId: const MarkerId('user_destination'),
        position: destination,
        infoWindow: const InfoWindow(title: 'Your Destination'),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      ),
    );

    const String apiKey = 'AIzaSyBRfHrwA5qB4VynIyDqGIgx0NGJ0AJdtPM';
    final String url =
        'https://maps.googleapis.com/maps/api/directions/json?origin=${myLocation.latitude},${myLocation.longitude}&destination=${destination.latitude},${destination.longitude}&key=$apiKey';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if ((data['routes'] as List).isNotEmpty) {
          final points = data['routes'][0]['overview_polyline']['points'];
          final List<PointLatLng> result = _decodePoly(points);
          final List<LatLng> polylineCoordinates = result
              .map((p) => LatLng(p.latitude, p.longitude))
              .toList();

          _userPolylines
            ..removeWhere((p) => p.polylineId.value == 'user_route')
            ..add(const PolylineId('user_route') as Polyline);

          _userPolylines
            ..removeWhere((p) => p.polylineId.value == 'user_route')
            ..add(
              Polyline(
                polylineId: const PolylineId('user_route'),
                points: polylineCoordinates,
                width: 5,
                color: Colors.blueAccent,
              ),
            );

          setState(() {});
        }
      }
    } catch (_) {}
  }

  Future<void> _saveJourneyStart(LatLng destination) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('journeyStarted', true);
    await prefs.setDouble('destination_lat', destination.latitude);
    await prefs.setDouble('destination_lng', destination.longitude);
  }

  Future<void> _clearJourneyPersisted() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('journeyStarted');
    await prefs.remove('destination_lat');
    await prefs.remove('destination_lng');
  }

  Future<void> startOrStopJourney() async {
    final userDestinationMarker = _markers.firstWhere(
      (m) => m.markerId.value == 'user_destination',
      orElse: () => const Marker(markerId: MarkerId('none')),
    );

    if (!isJourneyStarted && userDestinationMarker.markerId.value == 'none') {
      toastMessage("Please select a destination first");
      return;
    }

    if (isJourneyStarted) {
      setState(() {
        isJourneyStarted = false;
        _userPolylines.clear();
        _markers.removeWhere((m) => m.markerId.value == 'user_destination');
        _currentDestination = null;
      });
      await _clearJourneyPersisted();
      toastMessage("Journey Ended Successfully");
      return;
    }

    setState(() {
      isJourneyStarted = true;
    });

    final destination = userDestinationMarker.position;
    const String apiKey = 'AIzaSyBRfHrwA5qB4VynIyDqGIgx0NGJ0AJdtPM';
    final String url =
        'https://maps.googleapis.com/maps/api/directions/json?origin=${myLocation.latitude},${myLocation.longitude}&destination=${destination.latitude},${destination.longitude}&key=$apiKey';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if ((data['routes'] as List).isNotEmpty) {
          final points = data['routes'][0]['overview_polyline']['points'];
          final List<PointLatLng> result = _decodePoly(points);
          final List<LatLng> polylineCoordinates = result
              .map((p) => LatLng(p.latitude, p.longitude))
              .toList();

          final newUserPolyline = Polyline(
            polylineId: const PolylineId('user_route'),
            points: polylineCoordinates,
            width: 5,
            color: Colors.blueAccent,
          );

          _userPolylines
            ..removeWhere((p) => p.polylineId.value == 'user_route')
            ..add(newUserPolyline);

          _currentDestination = destination;
          await _saveJourneyStart(destination);

          setState(() {});
        }
      }
    } catch (_) {}

    toastMessage("Journey Started Successfully");
  }

  bool _isFilterCheckRunning = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isFilterCheckRunning) {
      _isFilterCheckRunning = true;
      Future.microtask(() async {
        await _refreshIfFilterChanged();
        _isFilterCheckRunning = false;
      });
    }
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      scaffoldKey: Keys.scaffoldKey,
      drawer: AppDrawer(),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : (latitude == null || longitude == null)
          ? Center(
              child: Text(
                "Location permission is not allowed. Please enable it from Settings.",
                style: AppFonts.outfitBlack.copyWith(fontSize: 20),
                textAlign: TextAlign.center,
              ),
            )
          : Stack(
              children: [
                Column(
                  children: [
                    const SizedBox(height: 60),
                    Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            InkWell(
                              onTap: () {
                                Keys.scaffoldKey.currentState?.openDrawer();
                              },
                              child: const Icon(
                                Icons.menu,
                                size: 24,
                                color: Colors.white,
                              ),
                            ),
                            Image.asset(
                              AppLogos.homeLogo,
                              height: 50,
                              color: Colors.white,
                            ),
                            InkWell(
                              onTap: () {
                                _showFilterDialog();
                              },
                              child: Icon(
                                Icons.filter_alt_outlined,
                                color: Colors.white,
                                size: 24,
                              ),
                            ),
                          ],
                        ),
                        if (widget.isUser == false &&
                            widget.profileType != null)
                          Text(
                            widget.profileType!.toUpperCase(),
                            style: AppFonts.outfitBlack.copyWith(
                              fontSize: 14,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 30),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40),
                      child: _searchTextField(),
                    ),
                    const SizedBox(height: 30),
                    Expanded(
                      child: RepaintBoundary(
                        child: GoogleMap(
                          onMapCreated: (controller) {
                            _mapController.complete(controller);
                            _controller = controller;
                            // _controller?.animateCamera(
                            //   CameraUpdate.newLatLngZoom(myLocation, 15),
                            // );
                          },
                          initialCameraPosition: CameraPosition(
                            target: myLocation,
                            zoom: 15,
                          ),
                          zoomControlsEnabled: true,
                          compassEnabled: true,
                          myLocationEnabled: true,
                          myLocationButtonEnabled: true,
                          markers: _markers.toSet(),
                          circles: _circles,
                          polylines: {..._santPolylines, ..._userPolylines},
                          onTap: (pos) async {
                            if (isJourneyStarted) return;
                            setState(() {
                              _markers.removeWhere(
                                (m) => m.markerId.value == 'user_destination',
                              );
                              _markers.add(
                                Marker(
                                  markerId: const MarkerId('user_destination'),
                                  position: pos,
                                  infoWindow: const InfoWindow(
                                    title: 'Your Destination',
                                  ),
                                  icon: BitmapDescriptor.defaultMarkerWithHue(
                                    BitmapDescriptor.hueRed,
                                  ),
                                ),
                              );
                            });

                            _currentDestination = pos;
                            const String apiKey =
                                'AIzaSyBRfHrwA5qB4VynIyDqGIgx0NGJ0AJdtPM';
                            final String url =
                                'https://maps.googleapis.com/maps/api/directions/json?origin=${myLocation.latitude},${myLocation.longitude}&destination=${pos.latitude},${pos.longitude}&key=$apiKey';

                            try {
                              final response = await http.get(Uri.parse(url));
                              if (response.statusCode == 200) {
                                final data = json.decode(response.body);
                                if ((data['routes'] as List).isNotEmpty) {
                                  final points =
                                      data['routes'][0]['overview_polyline']['points'];
                                  final List<PointLatLng> result = _decodePoly(
                                    points,
                                  );
                                  final List<LatLng> polylineCoordinates =
                                      result
                                          .map(
                                            (p) =>
                                                LatLng(p.latitude, p.longitude),
                                          )
                                          .toList();

                                  setState(() {
                                    _userPolylines
                                      ..removeWhere(
                                        (p) =>
                                            p.polylineId.value == 'user_route',
                                      )
                                      ..add(
                                        Polyline(
                                          polylineId: const PolylineId(
                                            'user_route',
                                          ),
                                          points: polylineCoordinates,
                                          width: 5,
                                          color: Colors.blueAccent,
                                        ),
                                      );
                                  });
                                }
                              }
                            } catch (e) {
                              log("User route draw error: $e");
                            }
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 60),
                  ],
                ),
                Positioned(
                  bottom: 0,
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black12,
                          offset: Offset(0, -5),
                          blurRadius: 10,
                          spreadRadius: 2,
                        ),
                      ],
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(50),
                        topRight: Radius.circular(50),
                      ),
                    ),
                    child: Center(
                      child: ElevatedButton(
                        onPressed: startOrStopJourney,

                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.appOrange,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              isJourneyStarted
                                  ? 'Stop Journey'
                                  : 'Start Your Journey',
                              style: AppFonts.outfitBlack.copyWith(
                                color: Colors.white,
                                fontSize: 18,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Icon(Icons.navigation_outlined, size: 18),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  _searchTextField() => GestureDetector(
    onTap: () {
      setState(() {
        _markers.removeWhere((m) => m.markerId.value.startsWith('user_'));
      });

      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) => AddDirectionSearchBottomSheet(
          latitude: latitude,
          longitude: longitude,
          onPlaceSelected: (name, vicinity, lat, lng) {
            if (isJourneyStarted) return;
            final position = LatLng(lat, lng);
            setState(() {
              _markers.removeWhere((m) => m.markerId.value.startsWith('user_'));
              _markers.add(
                Marker(
                  markerId: MarkerId(name),
                  position: position,
                  infoWindow: InfoWindow(title: name, snippet: vicinity),
                ),
              );
            });

            // _controller?.animateCamera(
            //   CameraUpdate.newLatLngZoom(position, 15),
            // );
            getDirections(myLocation, position);
          },
        ),
      );
    },
    child: AppTextfield(
      controller: searchController,
      fillColor: Colors.white,
      hintText: "Search here..",
      isRequired: false,
      enabled: false,
    ),
  );
}

List<PointLatLng> _decodePoly(String polyline) {
  List<PointLatLng> points = [];
  int index = 0, len = polyline.length;
  int lat = 0, lng = 0;

  while (index < len) {
    int b, shift = 0, result = 0;
    do {
      b = polyline.codeUnitAt(index++) - 63;
      result |= (b & 0x1F) << shift;
      shift += 5;
    } while (b >= 0x20);
    int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
    lat += dlat;

    shift = 0;
    result = 0;
    do {
      b = polyline.codeUnitAt(index++) - 63;
      result |= (b & 0x1F) << shift;
      shift += 5;
    } while (b >= 0x20);
    int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
    lng += dlng;

    points.add(PointLatLng(lat / 1e5, lng / 1e5));
  }

  return points;
}

// const String apiKey = 'AIzaSyBRfHrwA5qB4VynIyDqGIgx0NGJ0AJdtPM';
