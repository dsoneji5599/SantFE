import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:sant_app/models/sant_journey_history.dart';
import 'package:sant_app/provider/location_provider.dart';
import 'package:sant_app/themes/app_fonts.dart';
import 'package:sant_app/themes/app_images.dart';
import 'package:sant_app/widgets/app_scaffold.dart';

class JourneyHistoryDetailScreen extends StatefulWidget {
  final double startLatitude;
  final double startLongitude;
  final double endLatitude;
  final double endLongitude;
  final String? startLocationName;
  final String? endLocationName;
  final String startDate;
  final String endDate;

  const JourneyHistoryDetailScreen({
    super.key,
    required this.startLatitude,
    required this.startLongitude,
    required this.endLatitude,
    required this.endLongitude,
    required this.startLocationName,
    required this.endLocationName,
    required this.startDate,
    required this.endDate,
  });

  @override
  State<JourneyHistoryDetailScreen> createState() =>
      _JourneyHistoryDetailScreenState();
}

class _JourneyHistoryDetailScreenState
    extends State<JourneyHistoryDetailScreen> {
  late GoogleMapController _mapController;

  Set<Marker> _markers = {};
  Set<Polyline> polylines = {};
  bool isLoading = false;

  @override
  void initState() {
    super.initState();

    final startLatLng = LatLng(widget.startLatitude, widget.startLongitude);
    final endLatLng = LatLng(widget.endLatitude, widget.endLongitude);

    _markers = {
      Marker(
        markerId: const MarkerId('start'),
        position: startLatLng,
        infoWindow: InfoWindow(title: widget.startLocationName ?? 'Start'),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
      ),
      Marker(
        markerId: const MarkerId('end'),
        position: endLatLng,
        infoWindow: InfoWindow(title: widget.endLocationName ?? 'End'),
        icon: BitmapDescriptor.defaultMarker,
      ),
    };

    getDirections(startLatLng, endLatLng);
  }

  Future<void> getDirections(LatLng origin, LatLng destination) async {
    setState(() {
      isLoading = true;
      polylines.clear();
    });

    const String apiKey = 'AIzaSyBRfHrwA5qB4VynIyDqGIgx0NGJ0AJdtPM';

    final String url =
        'https://maps.googleapis.com/maps/api/directions/json?origin=${origin.latitude},${origin.longitude}&destination=${destination.latitude},${destination.longitude}&key=$apiKey';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if ((data['routes'] as List).isNotEmpty) {
          final points =
              data['routes'][0]['overview_polyline']['points'] as String;
          final List<PointLatLng> result = _decodePoly(points);

          final List<LatLng> polylineCoordinates = result
              .map((point) => LatLng(point.latitude, point.longitude))
              .toList();

          setState(() {
            polylines.add(
              Polyline(
                polylineId: const PolylineId('route'),
                visible: true,
                points: polylineCoordinates,
                width: 5,
                color: Colors.blue,
              ),
            );
          });
        } else {
          log('No routes found');
        }
      } else {
        log('Failed to fetch directions: ${response.statusCode}');
      }
    } catch (e) {
      log('Direction API error: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  // Polyline decoding function based on Google's polyline algorithm
  List<PointLatLng> _decodePoly(String poly) {
    List<PointLatLng> points = [];
    int index = 0, len = poly.length;
    int lat = 0, lng = 0;

    while (index < len) {
      int b, shift = 0, result = 0;

      do {
        b = poly.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);

      int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lat += dlat;

      shift = 0;
      result = 0;

      do {
        b = poly.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);

      int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lng += dlng;

      points.add(PointLatLng(lat / 1E5, lng / 1E5));
    }
    return points;
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;

    // Calculate LatLngBounds to include both start and end points with padding
    LatLngBounds bounds;
    if (widget.startLatitude > widget.endLatitude &&
        widget.startLongitude > widget.endLongitude) {
      bounds = LatLngBounds(
        southwest: LatLng(widget.endLatitude, widget.endLongitude),
        northeast: LatLng(widget.startLatitude, widget.startLongitude),
      );
    } else if (widget.startLongitude > widget.endLongitude) {
      bounds = LatLngBounds(
        southwest: LatLng(widget.startLatitude, widget.endLongitude),
        northeast: LatLng(widget.endLatitude, widget.startLongitude),
      );
    } else if (widget.startLatitude > widget.endLatitude) {
      bounds = LatLngBounds(
        southwest: LatLng(widget.endLatitude, widget.startLongitude),
        northeast: LatLng(widget.startLatitude, widget.endLongitude),
      );
    } else {
      bounds = LatLngBounds(
        southwest: LatLng(widget.startLatitude, widget.startLongitude),
        northeast: LatLng(widget.endLatitude, widget.endLongitude),
      );
    }

    _mapController.animateCamera(CameraUpdate.newLatLngBounds(bounds, 50));
  }

  @override
  Widget build(BuildContext context) {
    final initialCameraPosition = CameraPosition(
      target: LatLng(
        (widget.startLatitude + widget.endLatitude) / 2,
        (widget.startLongitude + widget.endLongitude) / 2,
      ),
      zoom: 10,
    );

    return AppScaffold(
      body: Selector<LocationProvider, List<SantJourneyHistoryModel>>(
        selector: (_, provider) => provider.historyList,
        builder: (_, historyList, __) {
          return Column(
            children: [
              const SizedBox(height: 60),

              // AppBar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    InkWell(
                      onTap: () => Navigator.pop(context),
                      child: const Icon(
                        Icons.arrow_back_ios,
                        size: 24,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      "Journey History",
                      style: AppFonts.outfitBlack.copyWith(
                        fontSize: 20,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 24), // balance spacing
                  ],
                ),
              ),

              const SizedBox(height: 35),

              Expanded(
                child: Stack(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 50),
                      child: GoogleMap(
                        initialCameraPosition: initialCameraPosition,
                        markers: _markers,
                        polylines: polylines,
                        onMapCreated: _onMapCreated,
                        myLocationEnabled: false,
                        myLocationButtonEnabled: false,
                      ),
                    ),

                    if (isLoading)
                      const Center(child: CircularProgressIndicator()),

                    // Info card over the map
                    Positioned(
                      top: 0,
                      left: 25,
                      right: 25,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 16,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 10,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Center(
                              child: Text(
                                widget.endLocationName ?? 'Unknown',
                                style: AppFonts.outfitBlack.copyWith(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            const SizedBox(height: 18),
                            Row(
                              children: [
                                Image.asset(
                                  AppIcons.fromLocation,
                                  height: 16,
                                  width: 13,
                                ),
                                SizedBox(width: 10),
                                RichText(
                                  text: TextSpan(
                                    text: "From: ",
                                    style: AppFonts.outfitBlack.copyWith(
                                      fontSize: 16,
                                    ),
                                    children: [
                                      TextSpan(
                                        text:
                                            widget.startLocationName ??
                                            'Unknown',
                                        style: AppFonts.outfitBlack.copyWith(
                                          fontSize: 16,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                Image.asset(
                                  AppIcons.toLocation,
                                  height: 16,
                                  width: 13,
                                ),
                                SizedBox(width: 10),
                                RichText(
                                  text: TextSpan(
                                    text: "To: ",
                                    style: AppFonts.outfitBlack.copyWith(
                                      fontSize: 16,
                                    ),
                                    children: [
                                      TextSpan(
                                        text:
                                            widget.endLocationName ?? 'Unknown',
                                        style: AppFonts.outfitBlack.copyWith(
                                          fontSize: 16,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 18),

                            Row(
                              children: [
                                Image.asset(AppIcons.fromDate, height: 16),
                                SizedBox(width: 10),
                                RichText(
                                  text: TextSpan(
                                    text: "Start date: ",
                                    style: AppFonts.outfitBlack.copyWith(
                                      fontSize: 16,
                                    ),
                                    children: [
                                      TextSpan(
                                        text: widget.startDate,
                                        style: AppFonts.outfitBlack.copyWith(
                                          fontSize: 16,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                Image.asset(AppIcons.toDate, height: 16),
                                SizedBox(width: 10),
                                RichText(
                                  text: TextSpan(
                                    text: "End date: ",
                                    style: AppFonts.outfitBlack.copyWith(
                                      fontSize: 16,
                                    ),
                                    children: [
                                      TextSpan(
                                        text: widget.endDate,
                                        style: AppFonts.outfitBlack.copyWith(
                                          fontSize: 16,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// Helper class for decoded polyline points
class PointLatLng {
  final double latitude;
  final double longitude;
  PointLatLng(this.latitude, this.longitude);
}
