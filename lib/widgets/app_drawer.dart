import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sant_app/provider/profile_provider.dart';
import 'package:sant_app/repositories/firebase_api.dart';
import 'package:sant_app/screens/auth/onboarding_screen.dart';
import 'package:sant_app/screens/home/event_screen.dart';
import 'package:sant_app/themes/app_colors.dart';
import 'package:sant_app/themes/app_fonts.dart';
import 'package:sant_app/widgets/app_navigator_animation.dart';
import 'package:sant_app/widgets/keys.dart';

class AppDrawer extends StatefulWidget {
  const AppDrawer({super.key});

  @override
  State<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Consumer<UserProfileProvider>(
        builder: (context, profileProvider, child) {
          final profile = profileProvider.userProfileModel;
          return Container(
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.appOrange, Colors.white, Colors.white],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 150,
                horizontal: 15,
              ).copyWith(bottom: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    children: [
                      ListTile(
                        title: Row(
                          children: [
                            SizedBox(
                              height: 55,
                              width: 55,
                              child: ClipRRect(
                                borderRadius: BorderRadiusGeometry.circular(50),
                                child: CachedNetworkImage(
                                  imageUrl: profile?.profileImage ?? 'N/A',
                                  fit: BoxFit.cover,
                                  errorWidget: (context, url, error) =>
                                      SizedBox(
                                        width: double.infinity,
                                        child: Icon(
                                          Icons.person,
                                          size: 50,
                                          color: Colors.grey.shade300,
                                        ),
                                      ),
                                ),
                              ),
                            ),
                            SizedBox(width: 13),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  profile?.name ?? "N/A",
                                  style: AppFonts.outfitBlack.copyWith(
                                    fontSize: 16,
                                  ),
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.location_pin,
                                      size: 15,
                                      color: Colors.black54,
                                    ),
                                    Text(
                                      profile?.stateName ?? "N/A",
                                      style: AppFonts.outfitBlack.copyWith(
                                        fontSize: 16,
                                        color: Colors.black54,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 50),
                      ListTile(
                        leading: Icon(Icons.event, color: AppColors.appOrange),
                        trailing: Icon(
                          Icons.arrow_forward_ios,
                          color: AppColors.appGrey.withValues(alpha: 0.5),
                        ),
                        title: Text('Events'),
                        onTap: () {
                          Keys.scaffoldKey.currentState?.closeDrawer();
                          navigatorPush(context, EventScreen());
                        },
                      ),
                    ],
                  ),

                  ListTile(
                    leading: Icon(Icons.logout, color: AppColors.appOrange),
                    trailing: Icon(
                      Icons.arrow_forward_ios,
                      color: AppColors.appGrey.withValues(alpha: 0.5),
                    ),
                    title: Text('Sign Out'),
                    onTap: () {
                      signOut().then((value) {
                        navigatorPushReplacement(context, OnboardingScreen());
                      });
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
