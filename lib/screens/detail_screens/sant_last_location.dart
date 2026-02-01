import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:sant_app/themes/app_fonts.dart';
import 'package:sant_app/widgets/app_scaffold.dart';

class SantLastLocation extends StatefulWidget {
  final double lastLocationLatitude;
  final double lastLocationLongitude;

  const SantLastLocation({
    super.key,
    required this.lastLocationLatitude,
    required this.lastLocationLongitude,
  });

  @override
  State<SantLastLocation> createState() => _SantLastLocationState();
}

class _SantLastLocationState extends State<SantLastLocation> {
  GoogleMapController? _mapController;

  late final Set<Marker> _markers;

  @override
  void initState() {
    super.initState();

    final lastLatLng = LatLng(
      widget.lastLocationLatitude,
      widget.lastLocationLongitude,
    );

    _markers = {
      Marker(
        markerId: const MarkerId('last_location'),
        position: lastLatLng,
        infoWindow: const InfoWindow(title: 'Last Location'),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      ),
    };
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;

    _mapController!.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: LatLng(
            widget.lastLocationLatitude,
            widget.lastLocationLongitude,
          ),
          zoom: 15,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      body: Column(
        children: [
          const SizedBox(height: 60),

          // AppBar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(
                    Icons.arrow_back_ios,
                    size: 24,
                    color: Colors.white,
                  ),
                ),
                Text(
                  "Sant Last Location",
                  style: AppFonts.outfitBlack.copyWith(
                    fontSize: 20,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 24),
              ],
            ),
          ),

          const SizedBox(height: 20),

          Expanded(
            child: GoogleMap(
              initialCameraPosition: CameraPosition(
                target: LatLng(
                  widget.lastLocationLatitude,
                  widget.lastLocationLongitude,
                ),
                zoom: 15,
              ),
              markers: _markers,
              onMapCreated: _onMapCreated,
              myLocationEnabled: false,
              myLocationButtonEnabled: false,
              zoomControlsEnabled: true,
              compassEnabled: true,
            ),
          ),
        ],
      ),
    );
  }
}
