import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sant_app/models/sant_list_model.dart';
import 'package:sant_app/provider/sant_provider.dart';
import 'package:sant_app/provider/util_provider.dart';
import 'package:sant_app/screens/detail_screens/sant_detail_screen.dart';
import 'package:sant_app/themes/app_colors.dart';
import 'package:sant_app/themes/app_fonts.dart';
import 'package:sant_app/themes/app_images.dart';
import 'package:sant_app/utils/toast_bar.dart';
import 'package:sant_app/widgets/app_drawer.dart';
import 'package:sant_app/widgets/app_navigator_animation.dart';
import 'package:sant_app/widgets/app_scaffold.dart';
import 'package:sant_app/widgets/keys.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late SantProvider provider;
  late UtilProvider utilProvider;
  bool isLoading = true;

  List<String> selectedSamajIds = [];

  Future<void> _showFilterDialog() async {
    final samajList = utilProvider.samajList;
    final tempSelectedIds = Set<String>.from(selectedSamajIds);

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Filter Samaj'),
          content: SizedBox(
            width: double.maxFinite,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: samajList.map((samaj) {
                  return CheckboxListTile(
                    controlAffinity: ListTileControlAffinity.leading,
                    contentPadding: EdgeInsets.zero,
                    title: Text(samaj.samajName ?? 'N/A'),
                    value: tempSelectedIds.contains(samaj.samajId),
                    onChanged: (value) {
                      if (value == true) {
                        tempSelectedIds.add(samaj.samajId ?? '');
                      } else {
                        tempSelectedIds.remove(samaj.samajId);
                      }
                      (context as Element).markNeedsBuild();
                    },
                  );
                }).toList(),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                selectedSamajIds = tempSelectedIds.toList();
                
                final prefs = await SharedPreferences.getInstance();
                await prefs.setStringList("selectedSamaj", selectedSamajIds);

                Map<String, dynamic> body = {};
                if (selectedSamajIds.isNotEmpty) {
                  body["samaj"] = selectedSamajIds;
                }

                await provider.getSantList(data: body, offSet: 0);
                Navigator.of(context).pop();
              },
              child: Text('Apply'),
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    utilProvider = Provider.of<UtilProvider>(context, listen: false);
    provider = Provider.of<SantProvider>(context, listen: false);

    _initAsync().then((value) async {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      selectedSamajIds = prefs.getStringList("selectedSamaj") ?? [];
      Map<String, dynamic> body = {};
      if (selectedSamajIds.isNotEmpty) {
        body["samaj"] = selectedSamajIds;
      }
      await provider.getSantList(data: body, offSet: 0);
      setState(() {
        isLoading = false;
      });
    });
  }

  Future<void> _initAsync() async {
    await provider.getSantList(data: {}, offSet: 0);
    await utilProvider.getSamaj();
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? Center(child: CircularProgressIndicator())
        : AppScaffold(
            scaffoldKey: Keys.scaffoldKey,
            drawer: AppDrawer(),
            body: Selector<SantProvider, List<SantListModel>>(
              selector: (context, provider) => provider.santList,
              builder: (context, santList, child) {
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
                        InkWell(
                          onTap: () {
                            _showFilterDialog();
                          },
                          child: Icon(
                            Icons.filter_alt_outlined,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 35),

                    Expanded(
                      child: santList.isEmpty
                          ? Center(child: Text("No Sant found"))
                          : ListView.separated(
                              itemCount: santList.length,
                              padding: EdgeInsets.only(bottom: 20),
                              separatorBuilder: (context, index) =>
                                  SizedBox(height: 10),
                              itemBuilder: (context, index) {
                                final sant = santList[index];
                                return SantCard(sant: sant, provider: provider);
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

class SantCard extends StatelessWidget {
  final SantListModel sant;
  final SantProvider provider;

  const SantCard({super.key, required this.sant, required this.provider});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        navigatorPush(context, SantDetailScreen(sant: sant));
      },
      child: Container(
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
                  sant.name ?? 'N/A',
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
                      sant.samajName ?? 'N/A',
                      style: AppFonts.outfitBlack.copyWith(
                        fontSize: 16,
                        color: AppColors.appGrey.withValues(alpha: 0.5),
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
                      sant.sampraday ?? 'N/A',
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
                    imageUrl: sant.profileImage ?? 'N/A',
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
              bottom: -10,
              right: 0,
              child: IconButton(
                onPressed: () async {
                  if (sant.isBookmarked == false) {
                    bool success = await context
                        .read<SantProvider>()
                        .addBookmark(santId: sant.saintId ?? "");

                    if (success) {
                      await provider.getSantList(data: {}, offSet: 0);
                    }
                  } else if (sant.isBookmarked != false) {
                    toastMessage("Remove Bookmark from Sant Tab");
                    // bool
                    // success = await context.read<SantProvider>().removeBookmark(
                    //   bookmarkId:
                    //       sant.saintId ?? // TODO: Have to Add bookmark_id for removing sant
                    //       "",
                    // );

                    // if (success) {
                    //   await provider.getSantList();
                    // }
                  }
                },
                icon: Icon(
                  sant.isBookmarked == true
                      ? Icons.bookmark
                      : Icons.bookmark_outline,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
