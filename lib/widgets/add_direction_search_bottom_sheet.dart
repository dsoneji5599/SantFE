import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:sant_app/widgets/app_textfield.dart';

class AddDirectionSearchBottomSheet extends StatefulWidget {
  final double? latitude;
  final double? longitude;
  final void Function(String name, String vicinity, double lat, double lng)
  onPlaceSelected;

  const AddDirectionSearchBottomSheet({
    super.key,
    this.latitude,
    this.longitude,
    required this.onPlaceSelected,
  });

  @override
  State<AddDirectionSearchBottomSheet> createState() =>
      _AddDirectionSearchBottomSheetState();
}

class _AddDirectionSearchBottomSheetState
    extends State<AddDirectionSearchBottomSheet> {
  TextEditingController searchController = TextEditingController();
  bool isLoading = false;
  List<dynamic> temples = [];

  Future<void> fetchTemples([String query = "temple"]) async {
    setState(() {
      isLoading = true;
      temples.clear();
    });

    final apiKey = 'AIzaSyBRfHrwA5qB4VynIyDqGIgx0NGJ0AJdtPM';
    final url =
        'https://maps.googleapis.com/maps/api/place/textsearch/json?query=$query+hindu+temple&key=$apiKey';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        temples = data['results'] ?? [];
      });
    } else {
      // Handle error or show message if needed
    }

    setState(() {
      isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    fetchTemples();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.5,
      minChildSize: 0.3,
      maxChildSize: 0.9,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              AppTextfield(
                controller: searchController,
                hintText: "Search Temples...",
                suffix: IconButton(
                  icon: Icon(Icons.search),
                  onPressed: () => fetchTemples(searchController.text.trim()),
                ),
                onSubmitted: (value) => fetchTemples(value.trim()),
              ),
              SizedBox(height: 10),
              if (isLoading)
                Expanded(child: Center(child: CircularProgressIndicator()))
              else
                Expanded(
                  child: ListView.builder(
                    controller: scrollController,
                    itemCount: temples.length,
                    itemBuilder: (ctx, i) {
                      final temple = temples[i];
                      final name = temple['name'] ?? '';
                      final vicinity = temple['formatted_address'] ?? '';
                      final loc = temple['geometry']['location'];
                      final lat = loc['lat'];
                      final lng = loc['lng'];

                      return ListTile(
                        title: Text(name),
                        subtitle: Text(vicinity),
                        onTap: () {
                          widget.onPlaceSelected(name, vicinity, lat, lng);
                          Navigator.pop(context);
                        },
                      );
                    },
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
