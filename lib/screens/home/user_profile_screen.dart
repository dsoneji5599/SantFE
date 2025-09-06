import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sant_app/models/user_profile_model.dart';
import 'package:sant_app/provider/profile_provider.dart';
import 'package:sant_app/screens/home/update_user_profile.dart';
import 'package:sant_app/themes/app_images.dart';
import 'package:sant_app/themes/app_fonts.dart';
import 'package:sant_app/utils/extensions.dart';
import 'package:sant_app/widgets/app_drawer.dart';
import 'package:sant_app/widgets/app_navigator_animation.dart';
import 'package:sant_app/widgets/app_scaffold.dart';
import 'package:sant_app/widgets/keys.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      scaffoldKey: Keys.scaffoldKey,
      drawer: AppDrawer(),
      body: Selector<UserProfileProvider, UserProfileModel?>(
        selector: (p0, p1) => p1.userProfileModel,
        builder: (context, value, child) {
          return SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(height: 50),

                // AppBar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      InkWell(
                        onTap: () {
                          Keys.scaffoldKey.currentState?.openDrawer();
                        },
                        child: Icon(Icons.menu, size: 24, color: Colors.white),
                      ),
                      Text(
                        value?.name ?? "Profile",
                        style: AppFonts.outfitBlack.copyWith(
                          fontSize: 20,
                          color: Colors.white,
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          navigatorPush(context, UpdateUserProfileScreen());
                        },
                        child: Icon(Icons.edit, color: Colors.white, size: 20),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                Stack(
                  children: [
                    Container(
                      color: Colors.transparent,
                      height: 200,
                      width: double.infinity,
                    ),
                    CachedNetworkImage(
                      imageUrl: value?.profileImage ?? '',
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.contain,
                      errorWidget: (context, url, error) => Container(
                        color: Colors.grey,
                        height: 200,
                        width: double.infinity,
                        child: Icon(
                          Icons.person,
                          size: 50,
                          color: Colors.grey.shade300,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 5),

                Container(
                  margin: EdgeInsets.symmetric(vertical: 22, horizontal: 34),
                  padding: EdgeInsets.all(24).copyWith(top: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 10,
                        spreadRadius: 5,
                        offset: Offset(0, 1),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "BASIC INFO",
                        style: AppFonts.outfitBlack.copyWith(
                          color: Color(0xFF9C9C9C),
                          fontSize: 16,
                        ),
                      ),
                      SizedBox(height: 10),
                      Column(
                        children:
                            [
                                  // Phone Field
                                  _infoRow(
                                    AppIcons.phone,
                                    "Phone Number",
                                    value?.name ?? "N/A",
                                  ),

                                  // Email Field
                                  _infoRow(
                                    AppIcons.email,
                                    "Email",
                                    value?.email ?? "N/A",
                                  ),

                                  // Date of Birth Field
                                  _infoRow(
                                    AppIcons.date,
                                    "Date of Birth",
                                    value?.dob?.toYYYYMMDD().toString() ??
                                        "N/A",
                                  ),

                                  // City Field
                                  _infoRow(
                                    AppIcons.location,
                                    "City",
                                    value?.cityName ?? "N/A",
                                  ),

                                  // District Field
                                  _infoRow(
                                    AppIcons.location,
                                    "District",
                                    value?.districtName ?? "N/A",
                                  ),

                                  // State Field
                                  _infoRow(
                                    AppIcons.location,
                                    "State",
                                    value?.stateName ?? "N/A",
                                  ),

                                  // Country Field
                                  _infoRow(
                                    AppIcons.location,
                                    "Country",
                                    value?.countryName ?? "N/A",
                                  ),

                                  // Samaj Field
                                  _infoRow(
                                    AppIcons.samajIcon,
                                    "Samaj",
                                    value?.samajName ?? "N/A",
                                  ),
                                ]
                                .map(
                                  (e) => Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding: EdgeInsets.only(
                                          bottom: 5,
                                          top: 5,
                                        ),
                                        child: e,
                                      ),
                                      Divider(color: Colors.black12),
                                    ],
                                  ),
                                )
                                .toList(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  _infoRow(String icon, String key, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Image.asset(icon, height: 15, width: 15),
        SizedBox(width: 10),
        Text(
          "$key : ",
          style: AppFonts.outfitBlack.copyWith(
            color: Color(0xFF4D4D4D),
            fontSize: 16,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: AppFonts.outfitBlack.copyWith(
              color: Color(0xFFB1B1B1),
              fontSize: 16,
            ),
          ),
        ),
      ],
    );
  }
}
