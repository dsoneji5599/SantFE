import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sant_app/models/family_model.dart';
import 'package:sant_app/provider/home_provider.dart';
import 'package:sant_app/screens/home/add_family_member_screen.dart';
import 'package:sant_app/themes/app_colors.dart';
import 'package:sant_app/themes/app_fonts.dart';
import 'package:sant_app/themes/app_images.dart';
import 'package:sant_app/widgets/app_drawer.dart';
import 'package:sant_app/widgets/app_scaffold.dart';
import 'package:sant_app/widgets/keys.dart';
import 'package:sant_app/widgets/app_navigator_animation.dart';

class MyFamilyScreen extends StatefulWidget {
  final String? profileType;
  final bool? isUser;

  const MyFamilyScreen({super.key, this.profileType, this.isUser});

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
        ? const Center(child: CircularProgressIndicator())
        : AppScaffold(
            scaffoldKey: Keys.scaffoldKey,
            drawer: const AppDrawer(),
            body: Selector<HomeProvider, List<FamilyModel>>(
              selector: (context, provider) => provider.familyList,
              builder: (context, familyList, child) {
                return Column(
                  children: [
                    const SizedBox(height: 60),

                    // AppBar
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        IconButton(
                          onPressed: () {
                            Keys.scaffoldKey.currentState?.openDrawer();
                          },
                          icon: const Icon(
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
                        const SizedBox(width: 24),
                      ],
                    ),
                    const SizedBox(height: 35),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 25),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: SizedBox(
                          width: 200,
                          child: InkWell(
                            onTap: () {
                              navigatorPush(
                                context,
                                const AddFamilyMemberScreen(),
                              );
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.white),
                                borderRadius: BorderRadius.circular(50),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.add_circle,
                                    color: Colors.white,
                                    size: 40,
                                  ),
                                  Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Text(
                                      "Add Family Member",
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
                    const SizedBox(height: 15),
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
                              padding: const EdgeInsets.only(bottom: 20),
                              separatorBuilder: (context, index) =>
                                  const SizedBox(height: 10),
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
    return InkWell(
      onTap: () {
        navigatorPush(
          context,
          AddFamilyMemberScreen(isDetail: true, family: family),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 25),
        padding: const EdgeInsets.fromLTRB(25, 20, 20, 25),
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
                const SizedBox(height: 20),
                Row(
                  children: [
                    Image.asset(AppIcons.samajIcon, height: 17),
                    const SizedBox(width: 10),
                    Text(
                      "Samaj: ",
                      style: AppFonts.outfitBlack.copyWith(fontSize: 16),
                    ),
                    Text(
                      family.gachh ?? 'N/A',
                      style: AppFonts.outfitBlack.copyWith(
                        color: AppColors.appGrey.withValues(alpha: 0.5),
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Image.asset(AppIcons.sampradayIcon, height: 15),
                    const SizedBox(width: 10),
                    Text(
                      "Sampraday: ",
                      style: AppFonts.outfitBlack.copyWith(fontSize: 16),
                    ),
                    Text(
                      family.gachh ?? 'N/A',
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
                  borderRadius: BorderRadius.circular(50),
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
            Positioned(
              bottom: 0,
              right: 0,
              child: Row(
                children: [
                  InkWell(
                    onTap: () {
                      navigatorPush(
                        context,
                        AddFamilyMemberScreen(isEdit: true, family: family),
                      );
                    },
                    child: Icon(Icons.edit, color: AppColors.appGrey),
                  ),
                  SizedBox(width: 10),
                  InkWell(
                    onTap: () async {
                      final confirm = await showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: const Text("Delete Family Member"),
                            content: const Text(
                              "Are you sure you want to delete this family member?",
                            ),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context, false);
                                },
                                child: const Text("Cancel"),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context, true);
                                },
                                child: const Text("Delete"),
                              ),
                            ],
                          );
                        },
                      );
                      if (confirm == true) {
                        Provider.of<HomeProvider>(
                          context,
                          listen: false,
                        ).removeFamilyMember(userFamilyId: family.userId ?? "");
                      }
                    },
                    child: Icon(Icons.delete, color: AppColors.appGrey),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
