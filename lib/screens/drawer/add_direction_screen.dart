import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:sant_app/provider/location_provider.dart';
import 'package:sant_app/themes/app_colors.dart';
import 'package:sant_app/themes/app_fonts.dart';
import 'package:sant_app/widgets/add_direction_search_bottom_sheet.dart';
import 'package:sant_app/widgets/app_scaffold.dart';
import 'package:sant_app/widgets/app_textfield.dart';

class AddDirectionScreen extends StatefulWidget {
  const AddDirectionScreen({super.key});

  @override
  State<AddDirectionScreen> createState() => _AddDirectionScreenState();
}

class _AddDirectionScreenState extends State<AddDirectionScreen> {
  TextEditingController searchController = TextEditingController();

  double? latitude, longitude;
  LatLng myLocation = const LatLng(23.0225, 72.5714);
  final List<Marker> _markers = [];
  final Set<Circle> _circles = {};
  final Set<Polyline> _polylines = {};
  GoogleMapController? _controller;

  bool isLoading = false;
  bool hasStartedJourney = false;
  bool isRestingJourney = false;

  late LocationProvider locationProvider;

  @override
  void initState() {
    super.initState();
    isLoading = true;
    locationProvider = Provider.of<LocationProvider>(context, listen: false);

    locationProvider.getLiveSantJourneyProvider().then((journey) {
      if (journey != null) {
        final startLatLng = LatLng(
          journey.startLatitude ?? 0.0,
          journey.startLongitude ?? 0.0,
        );
        final endLatLng = LatLng(
          journey.endLatitude ?? 0.0,
          journey.endLongitude ?? 0.0,
        );

        setState(() {
          hasStartedJourney = true;
          if (journey.startLatitude != null &&
              journey.startLongitude != null &&
              journey.endLatitude != null &&
              journey.endLongitude != null) {
            _markers
              ..clear()
              ..add(
                Marker(
                  markerId: const MarkerId("end"),
                  position: endLatLng,
                  infoWindow: const InfoWindow(title: "Destination"),
                ),
              );
            getDirections(startLatLng, endLatLng);
          }
        });
      }
    });

    getUserCurrentLocation().then((value) {
      setState(() {
        latitude = value.latitude;
        longitude = value.longitude;
        myLocation = LatLng(latitude!, longitude!);
        isLoading = false;
        _controller?.animateCamera(CameraUpdate.newLatLngZoom(myLocation, 15));
      });
    });
  }

  void setLocationDetails({
    required String city,
    required String state,
    required String country,
  }) {
    currentCity = city;
    currentState = state;
    currentCountry = country;
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Future<Position> getUserCurrentLocation() async {
    await Geolocator.requestPermission();
    Position position = await Geolocator.getCurrentPosition();

    List<Placemark> placemarks = await placemarkFromCoordinates(
      position.latitude,
      position.longitude,
    );

    if (placemarks.isNotEmpty) {
      Placemark place = placemarks.first;
      setLocationDetails(
        city: place.locality ?? '',
        state: place.administrativeArea ?? '',
        country: place.country ?? '',
      );
    }

    return position;
  }

  Future<Map<String, String>> getAddressFromLatLng(
    double lat,
    double lng,
  ) async {
    const apiKey = 'AIzaSyBRfHrwA5qB4VynIyDqGIgx0NGJ0AJdtPM';
    final url =
        'https://maps.googleapis.com/maps/api/geocode/json?latlng=$lat,$lng&key=$apiKey';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      if (jsonData['results'] != null && jsonData['results'].isNotEmpty) {
        final components = jsonData['results'][0]['address_components'] as List;

        String city = '', state = '', country = '';

        for (var component in components) {
          final types = component['types'] as List;
          if (types.contains('locality')) {
            city = component['long_name'];
          } else if (types.contains('administrative_area_level_1')) {
            state = component['long_name'];
          } else if (types.contains('country')) {
            country = component['long_name'];
          }
        }

        return {
          'current_city': city,
          'current_state': state,
          'current_country': country,
        };
      }
    }

    return {'current_city': '', 'current_state': '', 'current_country': ''};
  }

  String? currentCity, currentState, currentCountry;

  Future<void> getDirections(LatLng origin, LatLng destination) async {
    setState(() {
      isLoading = true;
      _polylines.clear();
    });
    const String apiKey = 'AIzaSyBRfHrwA5qB4VynIyDqGIgx0NGJ0AJdtPM';
    final String url =
        'https://maps.googleapis.com/maps/api/directions/json?origin=${origin.latitude},${origin.longitude}&destination=${destination.latitude},${destination.longitude}&key=$apiKey';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final points = data['routes'][0]['overview_polyline']['points'];
        final List<PointLatLng> result = _decodePoly(points);
        final List<LatLng> polylineCoordinates = result
            .map((point) => LatLng(point.latitude, point.longitude))
            .toList();
        setState(() {
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
    } catch (e) {
      log('Direction API error: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      body: Stack(
        children: [
          Column(
            children: [
              const SizedBox(height: 50),
              // AppBar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: const Icon(
                        Icons.arrow_back_ios_new,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    Text(
                      "Add Direction",
                      style: AppFonts.outfitBlack.copyWith(
                        fontSize: 20,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 40),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              // Search TextField
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: _searchTextField(),
              ),
              const SizedBox(height: 30),
              // Map
              Expanded(
                child: RepaintBoundary(
                  child: GoogleMap(
                    onMapCreated: (c) => _controller = c,
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
                    onTap: (pos) async {
                      if (hasStartedJourney) return;
                      setState(() {
                        _markers
                          ..clear()
                          ..add(
                            Marker(
                              markerId: MarkerId(pos.toString()),
                              position: pos,
                            ),
                          );
                        _circles.clear();
                      });
                      await getDirections(myLocation, pos);
                    },
                  ),
                ),
              ),
              const SizedBox(height: 60),
            ],
          ),

          // Bottom Navigation Buttons
          Positioned(
            bottom: 20,
            child: Container(
              width: MediaQuery.of(context).size.width,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    offset: Offset(0, -5),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(50),
                  topRight: Radius.circular(50),
                ),
              ),
              child: (!hasStartedJourney)
                  ? Center(
                      child: ElevatedButton(
                        onPressed: () async {
                          if (_markers.isEmpty) {
                            // Show bottom sheet if location is not selected
                            showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              backgroundColor: Colors.transparent,
                              builder: (context) =>
                                  AddDirectionSearchBottomSheet(
                                    latitude: latitude,
                                    longitude: longitude,
                                    onPlaceSelected:
                                        (name, vicinity, lat, lng) async {
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
                                            _controller?.animateCamera(
                                              CameraUpdate.newLatLngZoom(
                                                position,
                                                15,
                                              ),
                                            );
                                          });
                                          final address =
                                              await getAddressFromLatLng(
                                                latitude!,
                                                longitude!,
                                              );

                                          Map<String, dynamic> data = {
                                            "start_latitude": latitude,
                                            "start_longitude": longitude,
                                            "end_latitude": position.latitude,
                                            "end_longitude": position.longitude,
                                            "start_date": DateTime.now()
                                                .toIso8601String(),
                                            "current_latitude": latitude,
                                            "current_longitude": longitude,
                                            "journey_status": "ongoing",
                                            "current_city":
                                                address['current_city'],
                                            "current_state":
                                                address['current_state'],
                                            "current_country":
                                                address['current_country'],
                                          };

                                          bool startedJourney =
                                              await locationProvider
                                                  .startJourneyProvider(
                                                    data: data,
                                                  );
                                          if (startedJourney) {
                                            locationProvider
                                                .getLiveSantJourneyProvider();
                                            setState(() {
                                              hasStartedJourney = true;
                                            });
                                            Navigator.pop(context);
                                            getDirections(myLocation, position);
                                          }
                                        },
                                  ),
                            );
                          } else {
                            // Location already selected, call API and show row of buttons
                            final marker = _markers.first;
                            final position = marker.position;
                            final address = await getAddressFromLatLng(
                              latitude!,
                              longitude!,
                            );

                            Map<String, dynamic> data = {
                              "start_latitude": latitude,
                              "start_longitude": longitude,
                              "end_latitude": position.latitude,
                              "end_longitude": position.longitude,
                              "start_date": DateTime.now().toIso8601String(),
                              "current_latitude": latitude,
                              "current_longitude": longitude,
                              "journey_status": "ongoing",
                              "current_city": address['current_city'],
                              "current_state": address['current_state'],
                              "current_country": address['current_country'],
                            };

                            bool updatedJourney = await locationProvider
                                .startJourneyProvider(data: data);
                            if (updatedJourney) {
                              locationProvider.getLiveSantJourneyProvider();
                              setState(() {
                                hasStartedJourney = true;
                              });
                              getDirections(myLocation, position);
                            }
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
                              'Start Your Journey',
                              style: AppFonts.outfitBlack.copyWith(
                                color: Colors.white,
                                fontSize: 18,
                              ),
                            ),
                            SizedBox(width: 8),
                            Icon(Icons.navigation_outlined, size: 18),
                          ],
                        ),
                      ),
                    )
                  : Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () async {
                                if (isRestingJourney) {
                                  final marker = _markers.first;
                                  final position = marker.position;
                                  final address = await getAddressFromLatLng(
                                    latitude!,
                                    longitude!,
                                  );

                                  Map<String, dynamic> data = {
                                    "start_latitude": latitude,
                                    "start_longitude": longitude,
                                    "end_latitude": position.latitude,
                                    "end_longitude": position.longitude,
                                    "start_date": DateTime.now()
                                        .toIso8601String(),
                                    "current_latitude": latitude,
                                    "current_longitude": longitude,
                                    "journey_status": "ongoing",
                                    "current_city": address['current_city'],
                                    "current_state": address['current_state'],
                                    "current_country":
                                        address['current_country'],
                                  };

                                  bool updatedJourney = await locationProvider
                                      .updateJourneyProvider(data: data);
                                  if (updatedJourney) {
                                    locationProvider
                                        .getLiveSantJourneyProvider();
                                    setState(() {
                                      isRestingJourney = false;
                                    });
                                    getDirections(myLocation, position);
                                  }
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: isRestingJourney
                                    ? AppColors.appOrange
                                    : AppColors.appOrange.withValues(
                                        alpha: 0.5,
                                      ),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                padding: EdgeInsets.symmetric(horizontal: 10),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'Start',
                                    style: AppFonts.outfitBlack.copyWith(
                                      color: Colors.white,
                                      fontSize: 18,
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  Icon(Icons.navigation_outlined, size: 18),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () async {
                                if (!isRestingJourney) {
                                  final marker = _markers.first;
                                  final position = marker.position;
                                  final address = await getAddressFromLatLng(
                                    latitude!,
                                    longitude!,
                                  );

                                  Map<String, dynamic> data = {
                                    "start_latitude": latitude,
                                    "start_longitude": longitude,
                                    "end_latitude": position.latitude,
                                    "end_longitude": position.longitude,
                                    "start_date": DateTime.now()
                                        .toIso8601String(),
                                    "current_latitude": latitude,
                                    "current_longitude": longitude,
                                    "current_city": address['current_city'],
                                    "current_state": address['current_state'],
                                    "current_country":
                                        address['current_country'],
                                    "journey_status": "resting",
                                  };

                                  bool updatedJourney = await locationProvider
                                      .updateJourneyProvider(data: data);
                                  if (updatedJourney) {
                                    locationProvider
                                        .getLiveSantJourneyProvider();
                                    setState(() {
                                      isRestingJourney = true;
                                    });
                                    getDirections(myLocation, position);
                                  }
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: isRestingJourney
                                    ? AppColors.appOrange.withValues(alpha: 0.5)
                                    : AppColors.appOrange,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                              ),
                              child: Text(
                                'Rest',
                                style: AppFonts.outfitBlack.copyWith(
                                  color: Colors.white,
                                  fontSize: 18,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            flex: 2,
                            child: ElevatedButton(
                              onPressed: () async {
                                final marker = _markers.first;
                                final position = marker.position;
                                final address = await getAddressFromLatLng(
                                  latitude!,
                                  longitude!,
                                );

                                Map<String, dynamic> data = {
                                  "start_latitude": latitude,
                                  "start_longitude": longitude,
                                  "end_latitude": position.latitude,
                                  "end_longitude": position.longitude,
                                  "start_date": DateTime.now()
                                      .toIso8601String(),
                                  "end_date": DateTime.now().toIso8601String(),
                                  "current_latitude": latitude,
                                  "current_longitude": longitude,
                                  "current_city": address['current_city'],
                                  "current_state": address['current_state'],
                                  "current_country": address['current_country'],
                                  "journey_status": "completed",
                                };

                                bool endedJourney = await locationProvider
                                    .updateJourneyProvider(data: data);
                                if (endedJourney) {
                                  locationProvider.getLiveSantJourneyProvider();
                                  setState(() {
                                    hasStartedJourney = false;
                                    isRestingJourney = false;
                                  });
                                  getDirections(myLocation, position);
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.appOrange,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                              ),
                              child: Text(
                                'Stop journey',
                                style: AppFonts.outfitBlack.copyWith(
                                  color: Colors.white,
                                  fontSize: 18,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
            ),
          ),

          // Loader
          if (isLoading)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: const Center(child: CircularProgressIndicator()),
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
            if (hasStartedJourney) return;
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
            getDirections(myLocation, position);
          },
        ),
      );
    },
    child: AppTextfield(
      controller: searchController,
      fillColor: Colors.white,
      hintText: "Search Temples..",
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
