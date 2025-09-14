import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:sant_app/themes/app_images.dart';
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
  TextEditingController searchController = TextEditingController();

  double? latitude, longitude;
  LatLng myLocation = const LatLng(23.0225, 72.5714);
  final List<Marker> _markers = [];
  final Set<Circle> _circles = {};
  GoogleMapController? _controller;

  @override
  void initState() {
    super.initState();
    getUserCurrentLocation().then((value) {
      setState(() {
        latitude = value.latitude;
        longitude = value.longitude;
        myLocation = LatLng(latitude!, longitude!);

        _controller?.animateCamera(CameraUpdate.newLatLngZoom(myLocation, 15));
      });
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Future<Position> getUserCurrentLocation() async {
    await Geolocator.requestPermission().then((value) {}).onError((
      e,
      stackTrace,
    ) {
      log(e.toString());
    });
    return await Geolocator.getCurrentPosition();
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  InkWell(
                    onTap: () {
                      Keys.scaffoldKey.currentState?.openDrawer();
                    },
                    child: Icon(Icons.menu, size: 24, color: Colors.white),
                  ),
                  Image.asset(
                    AppLogos.homeLogo,
                    height: 50,
                    color: Colors.white,
                  ),
                  SizedBox(width: 24),
                ],
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
                    onTap: (pos) {
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
                    },
                  ),
                ),
              ),
            ],
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
