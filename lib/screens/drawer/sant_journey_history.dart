import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:provider/provider.dart';
import 'package:sant_app/models/sant_journey_history.dart';
import 'package:sant_app/provider/location_provider.dart';
import 'package:sant_app/screens/detail_screens/journey_history_detail.dart';
import 'package:sant_app/themes/app_colors.dart';
import 'package:sant_app/themes/app_fonts.dart';
import 'package:sant_app/themes/app_images.dart';
import 'package:sant_app/utils/extensions.dart';
import 'package:sant_app/widgets/app_navigator_animation.dart';
import 'package:sant_app/widgets/app_scaffold.dart';

class SantJourneyHistoryScreen extends StatefulWidget {
  const SantJourneyHistoryScreen({super.key});

  @override
  State<SantJourneyHistoryScreen> createState() =>
      _SantJourneyHistoryScreenState();
}

class _SantJourneyHistoryScreenState extends State<SantJourneyHistoryScreen> {
  late final LocationProvider _provider;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _provider = Provider.of<LocationProvider>(context, listen: false);
    _initialize();
  }

  Future<void> _initialize() async {
    await _provider.getSantHistoryList();
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      body: Selector<LocationProvider, List<SantJourneyHistoryModel>>(
        selector: (_, provider) => provider.historyList,
        builder: (_, historyList, __) {
          if (_isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
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
                    const SizedBox(
                      width: 24,
                    ), // To balance spacing with back icon
                  ],
                ),
              ),

              const SizedBox(height: 35),

              Expanded(
                child: historyList.isEmpty
                    ? const Center(child: Text("No Journey History found"))
                    : ListView.separated(
                        padding: const EdgeInsets.only(bottom: 40),
                        itemCount: historyList.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 14),
                        itemBuilder: (_, index) {
                          final history = historyList[index];
                          return JourneyHistoryCard(history: history);
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class JourneyHistoryCard extends StatefulWidget {
  final SantJourneyHistoryModel history;

  const JourneyHistoryCard({super.key, required this.history});

  @override
  State<JourneyHistoryCard> createState() => _JourneyHistoryCardState();
}

class _JourneyHistoryCardState extends State<JourneyHistoryCard> {
  String? _locationName;
  String? _locationNameEnd;

  @override
  void initState() {
    super.initState();
    _fetchAddress();
  }

  Future<void> _fetchAddress() async {
    try {
      final startLat =
          double.tryParse(widget.history.startLatitude?.toString() ?? '0') ?? 0;
      final startLng =
          double.tryParse(widget.history.startLongitude?.toString() ?? '0') ??
          0;

      final endLat =
          double.tryParse(widget.history.endLatitude?.toString() ?? '0') ?? 0;
      final endLng =
          double.tryParse(widget.history.endLongitude?.toString() ?? '0') ?? 0;

      String getBestPlacemarkAddress(List<Placemark> placemarks) {
        if (placemarks.isEmpty) return "Unknown location";

        // Try to find placemark with both locality and subLocality non-empty
        for (final place in placemarks) {
          if ((place.locality?.isNotEmpty ?? false) &&
              (place.subLocality?.isNotEmpty ?? false)) {
            return "${place.locality}, ${place.subLocality}";
          }
        }

        // If none with both, find one with just locality
        for (final place in placemarks) {
          if (place.locality?.isNotEmpty ?? false) {
            if (place.subLocality?.isNotEmpty ?? false) {
              return "${place.locality}, ${place.subLocality}";
            }
            return place.locality!;
          }
        }

        // Fallback: use administrativeArea + locality if possible
        for (final place in placemarks) {
          if ((place.administrativeArea?.isNotEmpty ?? false) &&
              (place.locality?.isNotEmpty ?? false)) {
            return "${place.administrativeArea}, ${place.locality}";
          }
        }

        // Last fallback: just admin area or unknown
        final first = placemarks.first;
        if (first.administrativeArea?.isNotEmpty ?? false) {
          return first.administrativeArea!;
        }

        return "Unknown location";
      }

      String startLocation = "Unknown location";
      String endLocation = "Unknown location";

      if (startLat != 0 && startLng != 0) {
        final startPlacemarks = await placemarkFromCoordinates(
          startLat,
          startLng,
        );
        startLocation = getBestPlacemarkAddress(startPlacemarks);
      }

      if (endLat != 0 && endLng != 0) {
        final endPlacemarks = await placemarkFromCoordinates(endLat, endLng);
        endLocation = getBestPlacemarkAddress(endPlacemarks);
      }

      setState(() {
        _locationName = startLocation;
        _locationNameEnd = endLocation;
      });
    } catch (e) {
      log("Error fetching address: $e");
      setState(() {
        _locationName = "Unknown location";
        _locationNameEnd = "Unknown location";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        navigatorPush(
          context,
          JourneyHistoryDetailScreen(
            startLatitude: widget.history.startLatitude ?? 00,
            startLongitude: widget.history.startLongitude ?? 00,
            endLatitude: widget.history.endLatitude ?? 00,
            endLongitude: widget.history.endLongitude ?? 00,
            startLocationName: _locationName,
            endLocationName: _locationNameEnd,
            startDate: widget.history.startDate!.toDDMMYYYYDash(),
            endDate: widget.history.endDate!.toDDMMYYYYDash(),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 25),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(25),
              blurRadius: 8,
              spreadRadius: 2,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ListTile(
          leading: IntrinsicWidth(
            child: Align(
              alignment: Alignment.center,
              child: SizedBox(
                width: 200,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Image.asset(AppIcons.location, height: 20, width: 16),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        _locationNameEnd ?? "N/A",
                        style: AppFonts.outfitBlack.copyWith(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.calendar_month_outlined, color: AppColors.appOrange),
              const SizedBox(width: 10),
              Text(
                widget.history.startDate?.toDDMMYYYY() ?? "N/A",
                style: AppFonts.outfitBlack,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
