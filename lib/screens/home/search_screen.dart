import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:provider/provider.dart';
import 'package:sant_app/provider/location_provider.dart';
import 'package:sant_app/themes/app_images.dart';
import 'package:sant_app/themes/app_colors.dart';
import 'package:sant_app/themes/app_fonts.dart';
import 'package:sant_app/utils/toast_bar.dart';
import 'package:sant_app/widgets/add_direction_search_bottom_sheet.dart';
import 'package:sant_app/widgets/app_scaffold.dart';
import 'package:sant_app/widgets/app_textfield.dart';
import 'package:sant_app/widgets/keys.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  late LocationProvider provider;
  bool isLoading = true;

  TextEditingController searchController = TextEditingController();

  double? latitude, longitude;
  LatLng myLocation = const LatLng(23.0225, 72.5714);
  final List<Marker> _markers = [];
  final Set<Circle> _circles = {};
  final Set<Polyline> _polylines = {};
  GoogleMapController? _controller;
  final Completer<GoogleMapController> _mapController = Completer();

  bool isJourneyStarted = false;
  LatLng? _currentDestination;

  bool _isFetchingDirections = false;

  @override
  void initState() {
    super.initState();
    provider = Provider.of<LocationProvider>(context, listen: false);
    _initAsync().then((_) {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    });

    _initLocationTracking();
  }

  Future<void> _initAsync() async {
    try {
      Position pos = await Geolocator.getCurrentPosition(
        forceAndroidLocationManager: true,
        desiredAccuracy: LocationAccuracy.high,
      );

      latitude = pos.latitude;
      longitude = pos.longitude;
      myLocation = LatLng(latitude!, longitude!);

      String city = await getCityFromCoordinates(latitude!, longitude!);
      await provider.getNearbySantList(
        data: {"city": city},
        offSet: 0,
        city: city,
      );
    } catch (e) {
      log("Error initializing nearby list: $e");
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
          _controller?.animateCamera(CameraUpdate.newLatLng(myLocation));
        }
      }
    });
  }

  Future<Position> getUserCurrentLocation() async {
    LocationPermission permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      toastMessage("Location permission denied");
      return Future.error("Location permission denied");
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
      log("Requesting directions: $url");
      final response = await http.get(Uri.parse(url));
      log("Directions API status: ${response.statusCode}");
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if ((data['routes'] as List).isNotEmpty) {
          final points = data['routes'][0]['overview_polyline']['points'];
          final List<PointLatLng> result = _decodePoly(points);
          final List<LatLng> polylineCoordinates = result
              .map((point) => LatLng(point.latitude, point.longitude))
              .toList();
          setState(() {
            _polylines.clear();
            _polylines.add(
              Polyline(
                polylineId: const PolylineId('route'),
                visible: true,
                points: polylineCoordinates,
                width: 5,
                color: Colors.blue,
              ),
            );
          });
        }
      }
    } catch (e) {
      log('Direction API error: $e');
    }
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? Center(child: CircularProgressIndicator())
        : AppScaffold(
            body: Stack(
              children: [
                Column(
                  children: [
                    const SizedBox(height: 60),
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
                        const SizedBox(width: 24),
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
                            _controller?.animateCamera(
                              CameraUpdate.newLatLngZoom(myLocation, 15),
                            );
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
                          polylines: _polylines,
                          onTap: (pos) {
                            setState(() {
                              _markers
                                ..removeWhere(
                                  (m) => m.markerId.value != 'myLocation',
                                )
                                ..add(
                                  Marker(
                                    markerId: MarkerId(pos.toString()),
                                    position: pos,
                                  ),
                                );
                              _circles.clear();
                            });

                            if (_currentDestination == null ||
                                _currentDestination != pos) {
                              _polylines.clear();
                              _currentDestination = pos;
                              getDirections(myLocation, pos);
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
                        onPressed: () {
                          if (_markers
                              .where((m) => m.markerId.value != 'myLocation')
                              .isEmpty) {
                            showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              backgroundColor: Colors.transparent,
                              builder: (context) =>
                                  AddDirectionSearchBottomSheet(
                                    latitude: latitude,
                                    longitude: longitude,
                                    onPlaceSelected:
                                        (name, vicinity, lat, lng) {
                                          final position = LatLng(lat, lng);
                                          setState(() {
                                            _markers
                                              ..clear()
                                              ..add(
                                                Marker(
                                                  markerId: MarkerId(name),
                                                  position: position,
                                                  infoWindow: InfoWindow(
                                                    title: name,
                                                    snippet: vicinity,
                                                  ),
                                                ),
                                              );
                                          });
                                          _controller?.animateCamera(
                                            CameraUpdate.newLatLngZoom(
                                              position,
                                              15,
                                            ),
                                          );
                                          if (_currentDestination == null ||
                                              _currentDestination != position) {
                                            _polylines.clear();
                                            _currentDestination = position;
                                            getDirections(myLocation, position);
                                          }
                                        },
                                  ),
                            );
                          } else {
                            final marker = _markers.firstWhere(
                              (m) => m.markerId.value != 'myLocation',
                            );
                            final destination = marker.position;

                            setState(() {
                              if (isJourneyStarted) {
                                isJourneyStarted = false;
                                _polylines.clear();
                                _markers.removeWhere(
                                  (m) => m.markerId.value != 'myLocation',
                                );
                                _currentDestination = null;
                                toastMessage("Journey Ended Successfully");
                              } else {
                                isJourneyStarted = true;
                                _currentDestination = destination;
                                getDirections(myLocation, destination);
                                toastMessage("Journey Started Successfully");
                              }
                            });
                          }
                        },
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
        _markers.clear();
      });
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) => AddDirectionSearchBottomSheet(
          latitude: latitude,
          longitude: longitude,
          onPlaceSelected: (name, vicinity, lat, lng) {
            final position = LatLng(lat, lng);
            setState(() {
              _markers
                ..clear()
                ..add(
                  Marker(
                    markerId: MarkerId(name),
                    position: position,
                    infoWindow: InfoWindow(title: name, snippet: vicinity),
                  ),
                );
            });
            _controller?.animateCamera(
              CameraUpdate.newLatLngZoom(position, 15),
            );
            if (isJourneyStarted) {
              _polylines.clear();
              getDirections(myLocation, position);
            }
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
