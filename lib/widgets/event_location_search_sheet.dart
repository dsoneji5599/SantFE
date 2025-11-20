import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class EventLocationSearchSheet extends StatefulWidget {
  final Function(String name, double lat, double lng) onSelect;

  final double? currentLat;
  final double? currentLng;

  const EventLocationSearchSheet({
    super.key,
    required this.onSelect,
    this.currentLat,
    this.currentLng,
  });

  @override
  State<EventLocationSearchSheet> createState() =>
      _EventLocationSearchSheetState();
}

class _EventLocationSearchSheetState extends State<EventLocationSearchSheet> {
  TextEditingController searchController = TextEditingController();

  List<dynamic> places = [];
  List<dynamic> nearbyPlaces = [];

  bool isSearching = false;
  bool isNearbyLoading = true;

  final String apiKey = "AIzaSyBRfHrwA5qB4VynIyDqGIgx0NGJ0AJdtPM";

  @override
  void initState() {
    super.initState();
    _loadNearbyPlaces();
  }

  /// 🔍 Search Autocomplete
  void _searchPlaces(String query) async {
    if (query.isEmpty) {
      setState(() {
        isSearching = false;
        places = [];
      });
      return;
    }

    setState(() => isSearching = true);

    final url =
        "https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$query&key=$apiKey&components=country:in";

    final res = await http.get(Uri.parse(url));
    final data = json.decode(res.body);

    setState(() => places = data["predictions"] ?? []);
  }

  /// 📌 Fetch nearby places using Google Nearby Search API
  Future<void> _loadNearbyPlaces() async {
    if (widget.currentLat == null || widget.currentLng == null) return;

    final url =
        "https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=${widget.currentLat},${widget.currentLng}&radius=1500&type=point_of_interest&key=$apiKey";

    final res = await http.get(Uri.parse(url));
    final data = json.decode(res.body);

    setState(() {
      nearbyPlaces = data["results"] ?? [];
      isNearbyLoading = false;
    });
  }

  /// 👉 Get LatLng from placeId
  Future<void> _selectPlace(String placeId) async {
    final url =
        "https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&key=$apiKey";

    final res = await http.get(Uri.parse(url));
    final data = json.decode(res.body);

    final result = data["result"];
    final loc = result["geometry"]["location"];

    widget.onSelect(result["name"] ?? "", loc["lat"], loc["lng"]);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 20, left: 20, right: 20),
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
      ),
      child: Column(
        children: [
          // Sheet Handle
          Container(
            width: 40,
            height: 5,
            decoration: BoxDecoration(
              color: Colors.grey.shade400,
              borderRadius: BorderRadius.circular(10),
            ),
          ),

          const SizedBox(height: 20),

          // SEARCH BAR
          TextField(
            controller: searchController,
            onChanged: _searchPlaces,
            decoration: InputDecoration(
              hintText: "Search places...",
              filled: true,
              fillColor: Colors.grey.shade200,
              prefixIcon: const Icon(Icons.search),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),

          const SizedBox(height: 20),

          // LISTS
          Expanded(
            child: isSearching
                ? _buildSearchResults()
                : _buildNearbySuggestions(),
          ),
        ],
      ),
    );
  }

  /// 🔍 Search Results UI
  Widget _buildSearchResults() {
    return ListView.builder(
      itemCount: places.length,
      itemBuilder: (context, i) {
        final place = places[i];
        return ListTile(
          leading: const Icon(Icons.location_on_outlined, color: Colors.red),
          title: Text(place["description"] ?? ""),
          onTap: () => _selectPlace(place["place_id"].toString()),
        );
      },
    );
  }

  /// 📌 Nearby Suggested Places UI
  Widget _buildNearbySuggestions() {
    if (isNearbyLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Nearby places",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 10),

        Expanded(
          child: ListView.builder(
            itemCount: nearbyPlaces.length,
            itemBuilder: (context, i) {
              final p = nearbyPlaces[i];

              final name = p["name"] ?? "";
              final lat = p["geometry"]["location"]["lat"];
              final lng = p["geometry"]["location"]["lng"];
              final vicinity = p["vicinity"] ?? "";

              return ListTile(
                leading: const Icon(
                  Icons.place_rounded,
                  color: Colors.blueAccent,
                ),
                title: Text(name),
                subtitle: Text(vicinity),
                onTap: () => widget.onSelect(name, lat, lng),
              );
            },
          ),
        ),
      ],
    );
  }
}
