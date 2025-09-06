import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sant_app/models/temple_model.dart';
import 'package:sant_app/provider/home_provider.dart';
import 'package:sant_app/screens/home/add_temple_screen.dart';
import 'package:sant_app/themes/app_fonts.dart';
import 'package:sant_app/themes/app_images.dart';
import 'package:sant_app/widgets/app_drawer.dart';
import 'package:sant_app/widgets/app_navigator_animation.dart';
import 'package:sant_app/widgets/app_scaffold.dart';
import 'package:sant_app/widgets/keys.dart';

class TempleScreen extends StatefulWidget {
  const TempleScreen({super.key});

  @override
  State<TempleScreen> createState() => _TempleScreenState();
}

class _TempleScreenState extends State<TempleScreen>
    with SingleTickerProviderStateMixin {
  late HomeProvider provider;
  bool isLoading = true;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    provider = Provider.of<HomeProvider>(context, listen: false);
    _initAsync().then((value) {
      setState(() {
        isLoading = false;
      });
    });
  }

  Future<void> _initAsync() async {
    await Future.wait([
      provider.getTempleList(filterType: 'all'),
      provider.getTempleList(filterType: 'my'),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? Center(child: CircularProgressIndicator())
        : AppScaffold(
            scaffoldKey: Keys.scaffoldKey,
            drawer: AppDrawer(),
            body: Column(
              children: [
                SizedBox(height: 60),

                // Appbar
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    InkWell(
                      onTap: () {
                        Keys.scaffoldKey.currentState?.openDrawer();
                      },
                      child: Icon(Icons.menu, size: 24, color: Colors.white),
                    ),
                    Image.asset(
                      AppLogos.homeLogo,
                      height: 50,
                      color: Colors.white,
                    ),
                    SizedBox(width: 24),
                  ],
                ),
                SizedBox(height: 30),
                Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: TabBar(
                        controller: _tabController,
                        indicatorColor: Colors.deepOrangeAccent,
                        labelColor: Colors.black,
                        dividerColor: Colors.transparent,
                        tabs: const [
                          Tab(text: 'All Temples'),
                          Tab(text: 'My Temples'),
                        ],
                      ),
                    ),
                    SizedBox(width: 30),
                    InkWell(
                      onTap: () {
                        navigatorPush(context, AddTempleScreen());
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
                                "Add Temple",
                                style: AppFonts.outfitBlack,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(width: 20),
                  ],
                ),
                SizedBox(height: 20),

                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildTempleList(
                        provider.templeListAll,
                        "No Temples Found",
                      ),
                      _buildTempleList(
                        provider.templeListMy,
                        "No My Temples Found",
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
  }

  Widget _buildTempleList(List<TempleModel> temples, String emptyText) {
    return temples.isEmpty
        ? Center(
            child: Text(
              emptyText,
              style: AppFonts.outfitBlack.copyWith(
                color: Colors.black,
                fontSize: 16,
              ),
            ),
          )
        : ListView.separated(
            itemCount: temples.length,
            padding: EdgeInsets.only(bottom: 20, left: 20, right: 20),
            separatorBuilder: (context, index) => SizedBox(height: 15),
            itemBuilder: (context, index) {
              final temple = temples[index];
              return TempleCard(temple: temple);
            },
          );
  }
}

class TempleCard extends StatelessWidget {
  final TempleModel temple;

  const TempleCard({super.key, required this.temple});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        navigatorPush(
          context,
          AddTempleScreen(
            isDetail: true,
            description: temple.description,
            imagePath: temple.imagePath,
            templeName: temple.name,
            templeType: temple.type,
          ),
        );
      },
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 8,
              spreadRadius: 2,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                image: DecorationImage(
                  image:
                      (temple.imagePath != null && temple.imagePath!.isNotEmpty)
                      ? NetworkImage(temple.imagePath!)
                      : AssetImage(AppImages.userSample) as ImageProvider,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          temple.name ?? 'N/A',
                          style: AppFonts.outfitBlack.copyWith(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(
                    temple.type ?? 'N/A',
                    style: AppFonts.outfitBlack.copyWith(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    temple.description ??
                        'This is a Tri murti temple which is located at gandhinagar to mahesana highway with a three temple inside it.',
                    style: AppFonts.outfitBlack.copyWith(
                      fontSize: 16,
                      color: Colors.grey[600],
                      height: 1.3,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
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
