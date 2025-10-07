import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sant_app/models/family_model.dart';
import 'package:sant_app/provider/home_provider.dart';
import 'package:sant_app/themes/app_colors.dart';
import 'package:sant_app/themes/app_fonts.dart';
import 'package:sant_app/themes/app_images.dart';
import 'package:sant_app/widgets/app_drawer.dart';
import 'package:sant_app/widgets/app_scaffold.dart';
import 'package:sant_app/widgets/keys.dart';

class MyFamilyScreen extends StatefulWidget {
  const MyFamilyScreen({super.key});

  @override
  State<MyFamilyScreen> createState() => _MyFamilyScreenState();
}

class _MyFamilyScreenState extends State<MyFamilyScreen> {
  late HomeProvider provider;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    provider = Provider.of<HomeProvider>(context, listen: false);
    _initAsync().then((_) {
      setState(() {
        isLoading = false;
      });
    });
  }

  Future<void> _initAsync() async {
    await provider.getFamilyList();
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? Center(child: CircularProgressIndicator())
        : AppScaffold(
            scaffoldKey: Keys.scaffoldKey,
            drawer: AppDrawer(),
            body: Selector<HomeProvider, List<FamilyModel>>(
              selector: (context, provider) => provider.familyList,
              builder: (context, familyList, child) {
                return Column(
                  children: [
                    SizedBox(height: 60),

                    // AppBar
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        InkWell(
                          onTap: () {
                            Keys.scaffoldKey.currentState?.openDrawer();
                          },
                          child: Icon(
                            Icons.menu,
                            size: 24,
                            color: Colors.white,
                          ),
                        ),
                        Image.asset(
                          AppLogos.homeLogo,
                          height: 50,
                          color: Colors.white,
                        ),
                        SizedBox(width: 24),
                      ],
                    ),

                    SizedBox(height: 35),

                    Expanded(
                      child: familyList.isEmpty
                          ? Center(
                              child: Text(
                                "No Family Members found",
                                style: AppFonts.outfitBlack.copyWith(
                                  fontSize: 20,
                                ),
                              ),
                            )
                          : ListView.separated(
                              itemCount: familyList.length,
                              padding: EdgeInsets.only(bottom: 20),
                              separatorBuilder: (context, index) =>
                                  SizedBox(height: 10),
                              itemBuilder: (context, index) {
                                final family = familyList[index];
                                return FamilyCard(family: family);
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

class FamilyCard extends StatelessWidget {
  final FamilyModel family;

  const FamilyCard({super.key, required this.family});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 25),
      padding: EdgeInsets.fromLTRB(25, 20, 20, 25),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Colors.white,
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 6, spreadRadius: 3),
        ],
      ),
      child: Stack(
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                family.name ?? 'N/A',
                style: AppFonts.outfitBlack.copyWith(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 20),
              Row(
                children: [
                  Image.asset(AppIcons.samajIcon, height: 17),
                  SizedBox(width: 10),
                  Text(
                    "Samaj: ",
                    style: AppFonts.outfitBlack.copyWith(fontSize: 16),
                  ),
                  Text(
                    family.name ?? 'N/A',
                    style: AppFonts.outfitBlack.copyWith(
                      color: AppColors.appGrey.withValues(alpha: 0.5),
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10),
              Row(
                children: [
                  Image.asset(AppIcons.sampradayIcon, height: 15),
                  SizedBox(width: 10),
                  Text(
                    "Sampraday: ",
                    style: AppFonts.outfitBlack.copyWith(fontSize: 16),
                  ),
                  Text(
                    family.spouseName ?? 'N/A',
                    style: AppFonts.outfitBlack.copyWith(
                      color: AppColors.appGrey.withValues(alpha: 0.5),
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ],
          ),
          Positioned(
            top: 0,
            right: 0,
            child: SizedBox(
              height: 60,
              width: 60,
              child: ClipRRect(
                borderRadius: BorderRadiusGeometry.circular(50),
                child: CachedNetworkImage(
                  imageUrl: family.profileImage ?? 'N/A',
                  fit: BoxFit.cover,
                  errorWidget: (context, url, error) => SizedBox(
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
          ),
        ],
      ),
    );
  }
}
