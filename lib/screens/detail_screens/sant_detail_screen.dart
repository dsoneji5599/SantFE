import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:sant_app/models/sant_list_model.dart';
import 'package:sant_app/themes/app_colors.dart';
import 'package:sant_app/themes/app_images.dart';
import 'package:sant_app/themes/app_fonts.dart';
import 'package:sant_app/utils/extensions.dart';
import 'package:sant_app/widgets/app_scaffold.dart';

class SantDetailScreen extends StatelessWidget {
  final SantListModel sant;

  const SantDetailScreen({super.key, required this.sant});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 60),

            // AppBar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  InkWell(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Icon(
                      Icons.arrow_back_ios,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  Text(
                    sant.name ?? "Sant Detail",
                    style: AppFonts.outfitBlack.copyWith(
                      fontSize: 20,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(width: 24),
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
                sant.profileImage != null && sant.profileImage!.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: sant.profileImage!,
                        height: 200,
                        width: double.infinity,
                        fit: BoxFit.contain,
                        errorWidget: (context, url, error) => _defaultImage(),
                      )
                    : _defaultImage(),
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
                              _infoRow(
                                icon: Icons.handshake,
                                key: "Salutation",
                                value: sant.salutation ?? "N/A",
                              ),
                              _infoRow(
                                image: AppIcons.samajIcon,
                                key: "Samaj",
                                value: sant.samajName ?? "N/A",
                              ),
                              _infoRow(
                                image: AppIcons.sampradayIcon,
                                key: "Sampraday",
                                value: sant.samajName ?? "N/A",
                              ),
                              _infoRow(
                                icon: Icons.person,
                                key: "Gender",
                                value: sant.gender ?? "N/A",
                              ),
                              _infoRow(
                                icon: Icons.date_range_rounded,
                                key: "Date Of Birth ",
                                value:
                                    sant.dob?.toDDMMYYYY().toString() ?? "N/A",
                              ),
                              _infoRow(
                                image: AppIcons.phone,
                                key: "Mobile Number",
                                value: sant.mobile ?? "N/A",
                              ),
                              _infoRow(
                                icon: Icons.back_hand_outlined,
                                key: "Upadhi",
                                value: sant.upadhi ?? "N/A",
                              ),
                              _infoRow(
                                icon: Icons.back_hand,
                                key: "Sangh",
                                value: sant.samajName ?? "N/A",
                              ),
                              _infoRow(
                                image: AppIcons.email,
                                key: "Email",
                                value: sant.email ?? "N/A",
                              ),
                              _infoRow(
                                image: AppIcons.location,
                                key: "Place of Diksha",
                                value: sant.dikshaPlace ?? "N/A",
                              ),
                              _infoRow(
                                image: AppIcons.date,
                                key: "Date of Diksha",
                                value:
                                    sant.dikshaDate?.toDDMMYYYY().toString() ??
                                    "N/A",
                              ),
                              _infoRow(
                                icon: Icons.list,
                                key: "Tapasya Details",
                                value: sant.tapasyaDetails ?? "N/A",
                              ),
                              _infoRow(
                                icon: Icons.kitchen_outlined,
                                key: "Knowledge Details",
                                value: sant.knowledgeDetails ?? "N/A",
                              ),
                              _infoRow(
                                image: AppIcons.date,
                                key: "Event and Vihar Details",
                                value: sant.viharDetails ?? "N/A",
                              ),
                            ]
                            .map(
                              (e) => Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: EdgeInsets.only(bottom: 5, top: 5),
                                    child: e,
                                  ),
                                  Divider(color: Colors.black12),
                                ],
                              ),
                            )
                            .toList(),
                  ),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextButton(
                        onPressed: () {},
                        child: Text(
                          "VIEW LOCATION",
                          style: AppFonts.outfitBlack.copyWith(
                            color: AppColors.black.withValues(alpha: 0.5),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _defaultImage() {
    return Container(
      color: Colors.grey,
      height: 200,
      width: double.infinity,
      child: Icon(Icons.person, size: 50, color: Colors.grey.shade300),
    );
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
        Text(
          "$key : ",
          style: AppFonts.outfitBlack.copyWith(
            color: Color(0xFF4D4D4D),
            fontSize: 16,
          ),
        ),
        Flexible(
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
