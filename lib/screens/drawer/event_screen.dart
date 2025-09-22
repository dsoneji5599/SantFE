import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sant_app/models/event_model.dart';
import 'package:sant_app/provider/home_provider.dart';
import 'package:sant_app/screens/home/add_event_screen.dart';
import 'package:sant_app/themes/app_fonts.dart';
import 'package:sant_app/themes/app_images.dart';
import 'package:sant_app/utils/extensions.dart';
import 'package:sant_app/utils/my_shareprefernce.dart';
import 'package:sant_app/widgets/app_navigator_animation.dart';
import 'package:sant_app/widgets/app_scaffold.dart';

class EventScreen extends StatefulWidget {
  const EventScreen({super.key});

  @override
  State<EventScreen> createState() => _EventScreenState();
}

class _EventScreenState extends State<EventScreen> {
  late HomeProvider provider;
  bool isLoading = true;
  bool? isUser;

  @override
  void initState() {
    super.initState();
    provider = Provider.of<HomeProvider>(context, listen: false);
    _initAsync().then((value) {
      setState(() {
        isLoading = false;
      });
    });
  }

  Future<void> _initAsync() async {
    await provider.getEventList();
    isUser = await MySharedPreferences.instance.getBooleanValue("isUser");
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? Center(child: CircularProgressIndicator())
        : AppScaffold(
            body: Selector<HomeProvider, List<EventModel>>(
              selector: (context, provider) => provider.eventList,
              builder: (context, eventList, child) {
                return Column(
                  children: [
                    SizedBox(height: 60),

                    // AppBar
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        InkWell(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: Icon(
                            Icons.arrow_back_ios,
                            size: 24,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          "Events",
                          style: AppFonts.outfitBlack.copyWith(
                            fontSize: 20,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(width: 24),
                      ],
                    ),

                    SizedBox(height: 35),

                    if (isUser == false)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 25),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: SizedBox(
                            width: 150,
                            child: InkWell(
                              onTap: () {
                                navigatorPush(
                                  context,
                                  AddEventScreen(isDetail: false, eventId: ""),
                                );
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.white),
                                  borderRadius: BorderRadius.circular(50),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.add_circle,
                                      color: Colors.white,
                                      size: 40,
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(
                                        "Add Event",
                                        style: AppFonts.outfitBlack,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),

                    SizedBox(height: 15),

                    Expanded(
                      child: eventList.isEmpty
                          ? Center(child: Text("No Events found"))
                          : ListView.separated(
                              itemCount: eventList.length,
                              padding: EdgeInsets.only(bottom: 20),
                              separatorBuilder: (context, index) =>
                                  SizedBox(height: 10),
                              itemBuilder: (context, index) {
                                final event = eventList[index];
                                return EventCard(event: event);
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

class EventCard extends StatelessWidget {
  final EventModel event;
  final bool isMyEvent;

  const EventCard({super.key, required this.event, this.isMyEvent = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 25),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            spreadRadius: 2,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              InkWell(
                onTap: () {
                  navigatorPush(
                    context,
                    AddEventScreen(
                      description: event.description,
                      eventDate: event.eventDate?.toDDMMYYYY().toString(),
                      eventName: event.name,
                      imagePath: event.imagePath,
                      isDetail: true,
                      eventId: event.eventId ?? "N/A",
                    ),
                  );
                },
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    image: DecorationImage(
                      image:
                          (event.imagePath != null &&
                              event.imagePath!.isNotEmpty)
                          ? NetworkImage(event.imagePath!)
                          : AssetImage(AppImages.userSample) as ImageProvider,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: -30,
                right: 10,
                left: 10,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    textStyle: TextStyle(fontSize: 12),
                    backgroundColor: Colors.white,
                  ),
                  onPressed: () {
                    log("Edit button clicked");
                    navigatorPush(
                      context,
                      AddEventScreen(
                        description: event.description,
                        eventDate: event.eventDate?.toDDMMYYYY().toString(),
                        eventName: event.name,
                        imagePath: event.imagePath,
                        isDetail: false,
                        isEdit: true,
                        eventId: event.eventId ?? "N/A",
                      ),
                    );
                  },
                  child: Text("Edit", style: AppFonts.outfitBlack),
                ),
              ),
            ],
          ),
          SizedBox(width: 16),
          Expanded(
            child: InkWell(
              onTap: () {
                navigatorPush(
                  context,
                  AddEventScreen(
                    description: event.description,
                    eventDate: event.eventDate?.toDDMMYYYY().toString(),
                    eventName: event.name,
                    imagePath: event.imagePath,
                    isDetail: true,
                    eventId: event.eventId ?? "N/A",
                  ),
                );
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.name ?? 'N/A',
                    style: AppFonts.outfitBlack.copyWith(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.event, size: 16, color: Colors.orange),
                      SizedBox(width: 6),
                      Text(
                        event.eventDate?.toDDMMYYYY().toString() ?? 'N/A',
                        style: AppFonts.outfitBlack.copyWith(fontSize: 16),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(
                    event.description ??
                        'Satya narayan katch sanje 4 vage chalu tahse ane sathe rate jamva nu pn ...',
                    style: AppFonts.outfitBlack.copyWith(
                      fontSize: 14,
                      color: Colors.grey[600],
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
