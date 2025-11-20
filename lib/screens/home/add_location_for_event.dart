import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:sant_app/widgets/app_scaffold.dart';
import 'package:sant_app/widgets/app_textfield.dart';
import 'package:sant_app/themes/app_fonts.dart';
import 'package:sant_app/themes/app_colors.dart';
import 'package:sant_app/widgets/event_location_search_sheet.dart';

class AddLocationForEvent extends StatefulWidget {
  final double? initialLat;
  final double? initialLng;
  final bool isViewOnly;

  const AddLocationForEvent({
    super.key,
    this.initialLat,
    this.initialLng,
    this.isViewOnly = false,
  });

  @override
  State<AddLocationForEvent> createState() => _AddLocationForEventState();
}

class _AddLocationForEventState extends State<AddLocationForEvent> {
  TextEditingController searchController = TextEditingController();

  LatLng? selectedPos;
  GoogleMapController? mapController;

  double? currentLat;
  double? currentLng;

  @override
  void initState() {
    super.initState();
    _getUserLocation();
  }

  Future<void> _getUserLocation() async {
    await Geolocator.requestPermission();
    final pos = await Geolocator.getCurrentPosition();

    setState(() {
      currentLat = pos.latitude;
      currentLng = pos.longitude;
    });
  }

  Future<String> _getAddress(double lat, double lng) async {
    const apiKey = "AIzaSyBRfHrwA5qB4VynIyDqGIgx0NGJ0AJdtPM";

    final url =
        "https://maps.googleapis.com/maps/api/geocode/json?latlng=$lat,$lng&key=$apiKey";

    final response = await http.get(Uri.parse(url));
    final body = json.decode(response.body);

    if (body["results"] != null && body["results"].isNotEmpty) {
      return body["results"][0]["formatted_address"] ?? "";
    }
    return "";
  }

  void _confirmLocation() async {
    if (selectedPos == null) return;

    String address = await _getAddress(
      selectedPos!.latitude,
      selectedPos!.longitude,
    );

    Navigator.pop(context, {
      "lat": selectedPos!.latitude,
      "lng": selectedPos!.longitude,
      "address": address,
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      body: currentLat == null
          ? const Center(child: CircularProgressIndicator())
          : Stack(
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
                            onPressed: () => Navigator.pop(context),
                            icon: const Icon(
                              Icons.arrow_back_ios_new,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                          Text(
                            "Select Location",
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

                    // Search Bar
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40),
                      child: GestureDetector(
                        onTap: () {
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            backgroundColor: Colors.transparent,
                            builder: (context) {
                              return EventLocationSearchSheet(
                                currentLat: currentLat,
                                currentLng: currentLng,
                                onSelect: (name, lat, lng) {
                                  final pos = LatLng(lat, lng);
                                  setState(() {
                                    selectedPos = pos;
                                    searchController.text = name;
                                  });
                                  mapController?.animateCamera(
                                    CameraUpdate.newLatLngZoom(pos, 15),
                                  );
                                },
                              );
                            },
                          );
                        },
                        child: AppTextfield(
                          controller: searchController,
                          hintText: "Search places...",
                          enabled: false,
                          fillColor: Colors.white,
                          isRequired: false,
                        ),
                      ),
                    ),

                    const SizedBox(height: 30),

                    // Map
                    Expanded(
                      child: GoogleMap(
                        onMapCreated: (c) => mapController = c,
                        initialCameraPosition: CameraPosition(
                          target:
                              widget.initialLat != null &&
                                  widget.initialLng != null
                              ? LatLng(widget.initialLat!, widget.initialLng!)
                              : LatLng(currentLat!, currentLng!),
                          zoom: 15,
                        ),
                        myLocationEnabled: true,
                        myLocationButtonEnabled: true,
                        markers: {
                          if (selectedPos != null)
                            Marker(
                              markerId: MarkerId("selected"),
                              position: selectedPos!,
                            ),
                          if (selectedPos == null &&
                              widget.initialLat != null &&
                              widget.initialLng != null)
                            Marker(
                              markerId: MarkerId("initial"),
                              position: LatLng(
                                widget.initialLat!,
                                widget.initialLng!,
                              ),
                            ),
                        },
                        onTap: widget.isViewOnly
                            ? null
                            : (pos) {
                                setState(() => selectedPos = pos);
                              },
                      ),
                    ),

                    const SizedBox(height: 70),
                  ],
                ),

                // Bottom Confirm / Update Button
                if (!widget.isViewOnly)
                  Positioned(
                    bottom: 0,
                    child: Container(
                      height: 90,
                      width: MediaQuery.of(context).size.width,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(50),
                          topRight: Radius.circular(50),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            offset: const Offset(0, -3),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: Center(
                        child: ElevatedButton(
                          onPressed: _confirmLocation,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.appOrange,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 30,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                widget.initialLat != null &&
                                        widget.initialLng != null
                                    ? "Update Location"
                                    : "Confirm Location",
                                style: AppFonts.outfitBlack.copyWith(
                                  fontSize: 18,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Icon(Icons.check_circle_outline, size: 20),
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
}
