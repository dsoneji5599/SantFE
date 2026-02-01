import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sant_app/models/sant_profile_model.dart';
import 'package:sant_app/models/user_profile_model.dart';
import 'package:sant_app/provider/profile_provider.dart';
import 'package:sant_app/screens/home/update_user_profile.dart';
import 'package:sant_app/themes/app_colors.dart';
import 'package:sant_app/themes/app_images.dart';
import 'package:sant_app/themes/app_fonts.dart';
import 'package:sant_app/utils/extensions.dart';
import 'package:sant_app/utils/my_shareprefernce.dart';
import 'package:sant_app/widgets/app_drawer.dart';
import 'package:sant_app/widgets/app_navigator_animation.dart';
import 'package:sant_app/widgets/app_scaffold.dart';
import 'package:sant_app/widgets/keys.dart';

class UserProfileScreen extends StatefulWidget {
  final String? profileType;
  final bool? isUser;

  const UserProfileScreen({super.key, this.profileType, this.isUser});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  bool isUser = true;

  @override
  void initState() {
    super.initState();
    _initUserStatus();
  }

  void _initUserStatus() async {
    isUser = await MySharedPreferences.instance.getBooleanValue("isUser");
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (isUser == true) {
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
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            IconButton(
                              onPressed: () {
                                Keys.scaffoldKey.currentState?.openDrawer();
                              },
                              icon: Icon(
                                Icons.menu,
                                size: 24,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              value?.name ?? "Profile",
                              style: AppFonts.outfitBlack.copyWith(
                                fontSize: 20,
                                color: Colors.white,
                              ),
                            ),
                            IconButton(
                              onPressed: () {
                                navigatorPush(
                                  context,
                                  UpdateUserProfileScreen(isUser: isUser),
                                );
                              },
                              icon: Icon(
                                Icons.edit,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ],
                        ),
                        if (widget.isUser == false &&
                            widget.profileType != null)
                          Text(
                            widget.profileType!.toUpperCase(),
                            style: AppFonts.outfitBlack.copyWith(
                              fontSize: 14,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
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
                        SizedBox(height: 15),
                        Column(
                          children:
                              [
                                    // Phone Field
                                    _infoRow(
                                      image: AppIcons.phone,
                                      key: "Phone Number",
                                      value: value?.mobile ?? "N/A",
                                    ),

                                    // Email Field
                                    _infoRow(
                                      image: AppIcons.email,
                                      key: "Email",
                                      value: value?.email ?? "N/A",
                                    ),

                                    // Date of Birth Field
                                    _infoRow(
                                      image: AppIcons.date,
                                      key: "Date of Birth",
                                      value:
                                          value?.dob?.toYYYYMMDD().toString() ??
                                          "N/A",
                                    ),

                                    // City Field
                                    _infoRow(
                                      image: AppIcons.location,
                                      key: "City",
                                      value: value?.cityName ?? "N/A",
                                    ),

                                    // District Field
                                    _infoRow(
                                      image: AppIcons.location,
                                      key: "District",
                                      value: value?.districtName ?? "N/A",
                                    ),

                                    // State Field
                                    _infoRow(
                                      image: AppIcons.location,
                                      key: "State",
                                      value: value?.stateName ?? "N/A",
                                    ),

                                    // Country Field
                                    _infoRow(
                                      image: AppIcons.location,
                                      key: "Country",
                                      value: value?.countryName ?? "N/A",
                                    ),

                                    // Samaj Field
                                    _infoRow(
                                      image: AppIcons.samajIcon,
                                      key: "Samaj",
                                      value: value?.samajName ?? "N/A",
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
    } else {
      return AppScaffold(
        scaffoldKey: Keys.scaffoldKey,
        drawer: AppDrawer(),
        body: Selector<UserProfileProvider, SantProfileModel?>(
          selector: (p0, p1) => p1.santProfileModel,
          builder: (context, value, child) {
            return SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(height: 50),

                  // AppBar
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            IconButton(
                              onPressed: () {
                                Keys.scaffoldKey.currentState?.openDrawer();
                              },
                              icon: Icon(
                                Icons.menu,
                                size: 24,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              value?.name ?? "Profile",
                              style: AppFonts.outfitBlack.copyWith(
                                fontSize: 20,
                                color: Colors.white,
                              ),
                            ),
                            IconButton(
                              onPressed: () {
                                navigatorPush(
                                  context,
                                  UpdateUserProfileScreen(isUser: isUser),
                                );
                              },
                              icon: Icon(
                                Icons.edit,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ],
                        ),
                        if (widget.isUser == false &&
                            widget.profileType != null)
                          Text(
                            widget.profileType!.toUpperCase(),
                            style: AppFonts.outfitBlack.copyWith(
                              fontSize: 14,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
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
                        SizedBox(height: 15),
                        Column(
                          children:
                              [
                                    // Salutation Field
                                    _infoRow(
                                      icon: Icons.handshake,
                                      key: "Salutation",
                                      value: value?.salutation ?? "N/A",
                                    ),

                                    // Samaj Field
                                    _infoRow(
                                      image: AppIcons.samajIcon,
                                      key: "Samaj",
                                      value: value?.samajName ?? "N/A",
                                    ),

                                    // Sampraday Field
                                    _infoRow(
                                      image: AppIcons.sampradayIcon,
                                      key: "Sampraday",
                                      value: value?.sampraday ?? "N/A",
                                    ),

                                    // Gender Field
                                    _infoRow(
                                      icon: Icons.person,
                                      key: "Gender",
                                      value: value?.gender ?? "N/A",
                                    ),

                                    // Date of Birth Field
                                    _infoRow(
                                      icon: Icons.date_range_rounded,
                                      key: "Date Of Birth",
                                      value:
                                          value?.dob?.toDDMMYYYY().toString() ??
                                          "N/A",
                                    ),

                                    // Mobile Number Field
                                    _infoRow(
                                      image: AppIcons.phone,
                                      key: "Mobile Number",
                                      value: value?.mobile ?? "N/A",
                                    ),

                                    // Upadhi Field
                                    _infoRow(
                                      icon: Icons.back_hand_outlined,
                                      key: "Upadhi",
                                      value: value?.upadhi ?? "N/A",
                                    ),

                                    // Sangh Field
                                    _infoRow(
                                      icon: Icons.back_hand,
                                      key: "Sangh",
                                      value: value?.sangh ?? "N/A",
                                    ),

                                    // Email Field
                                    _infoRow(
                                      image: AppIcons.email,
                                      key: "Email",
                                      value: value?.email ?? "N/A",
                                    ),

                                    // Place of Diksha Field
                                    _infoRow(
                                      image: AppIcons.location,
                                      key: "Place of Diksha",
                                      value: value?.dikshaPlace ?? "N/A",
                                    ),

                                    // Date of Diksha Field
                                    _infoRow(
                                      image: AppIcons.date,
                                      key: "Date of Diksha",
                                      value:
                                          value?.dikshaDate
                                              ?.toDDMMYYYY()
                                              .toString() ??
                                          "N/A",
                                    ),

                                    // Tapasya Details Field
                                    _infoRow(
                                      icon: Icons.list,
                                      key: "Tapasya Details",
                                      value:
                                          value?.tapasyaDetails ??
                                          "You can add details here You can add details hereYou can add details hereYou can add details here",
                                    ),

                                    // Knowledge Details Field
                                    _infoRow(
                                      icon: Icons.kitchen_outlined,
                                      key: "Knowledge Details",
                                      value:
                                          value?.knowledgeDetails ??
                                          "You can add details here You can add details hereYou can add details hereYou can add details here",
                                    ),

                                    // Event and Vihar Details Field
                                    _infoRow(
                                      image: AppIcons.date,
                                      key: "Event and Vihar Details",
                                      value:
                                          value?.viharDetails ??
                                          "You can add details here You can add details hereYou can add details here",
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
  }

  Widget _infoRow({
    String? image,
    required String key,
    required String value,
    IconData? icon,
  }) {
    return Row(
      children: [
        if (image != null) Image.asset(image, height: 16, width: 16),
        if (icon != null) Icon(icon, size: 16, color: AppColors.appOrange),
        SizedBox(width: 10),

        Expanded(
          child: RichText(
            text: TextSpan(
              style: AppFonts.outfitBlack.copyWith(fontSize: 16),
              children: [
                TextSpan(
                  text: "$key : ",
                  style: TextStyle(color: Color(0xFF4D4D4D)),
                ),
                TextSpan(
                  text: value,
                  style: TextStyle(color: Color(0xFFB1B1B1)),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
