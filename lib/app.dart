import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:sant_app/provider/profile_provider.dart';
import 'package:sant_app/repositories/firebase_api.dart';
import 'package:sant_app/screens/auth/onboarding_screen.dart';
import 'package:sant_app/screens/home/event_screen.dart';
import 'package:sant_app/screens/home/home_screen.dart';
import 'package:sant_app/screens/home/my_family_screen.dart';
import 'package:sant_app/screens/home/user_profile_screen.dart';
import 'package:sant_app/screens/home/saved_screen.dart';
import 'package:sant_app/screens/home/search_screen.dart';
import 'package:sant_app/screens/home/temple_screen.dart';
import 'package:sant_app/themes/app_colors.dart';
import 'package:sant_app/themes/app_fonts.dart';
import 'package:sant_app/widgets/app_navigator_animation.dart';
import 'package:sant_app/widgets/keys.dart';

class App extends StatefulWidget {
  final int myIndex;
  const App({super.key, this.myIndex = 0});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  late int myIndex;
  late PageController _pageController;
  late UserProfileProvider profileProvider;
  ScrollController scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    profileProvider = Provider.of<UserProfileProvider>(context, listen: false);
    profileProvider.getProfile();

    myIndex = widget.myIndex;
    _pageController = PageController(initialPage: myIndex);
  }

  void onCallSavedHomes() {
    setState(() {
      myIndex = 1;
    });
    _pageController.jumpToPage(myIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> screens = [
      const HomeScreen(),
      const SearchScreen(),
      const TempleScreen(),
      const SavedScreen(),
      const MyFamilyScreen(),
      const UserProfileScreen(),
    ];

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (!didPop) {
          if (myIndex != 0) {
            setState(() {
              myIndex = 0;
            });
            _pageController.jumpToPage(0);
          } else if (myIndex == 0) {
            SystemNavigator.pop();
          } else {
            setState(() {
              myIndex = 0;
            });
            Navigator.of(context).maybePop();
          }
        }
      },
      child: Scaffold(
        drawer: Drawer(
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
                                    borderRadius: BorderRadiusGeometry.circular(
                                      50,
                                    ),
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
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
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
                            leading: Icon(
                              Icons.event,
                              color: AppColors.appOrange,
                            ),
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
                            navigatorPushReplacement(
                              context,
                              OnboardingScreen(),
                            );
                          });
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),

        body: PageView(
          physics: const NeverScrollableScrollPhysics(),
          controller: _pageController,
          children: screens,
        ),
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(
                color: AppColors.appGrey.withValues(alpha: 0.5),
                width: 0.5,
              ),
            ),
          ),
          child: BottomNavigationBar(
            backgroundColor: Colors.white,
            selectedItemColor: AppColors.appOrange,
            unselectedItemColor: AppColors.appGrey,
            selectedLabelStyle: AppFonts.outfitBlack,
            type: BottomNavigationBarType.fixed,
            currentIndex: myIndex,
            iconSize: 30,
            onTap: (index) async {
              setState(() {
                myIndex = index;
              });
              _pageController.jumpToPage(myIndex);
            },
            items: [
              BottomNavigationBarItem(
                icon: Icon(Icons.home_outlined),
                label: "Home",
                activeIcon: Icon(Icons.home_outlined),
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.search),
                label: "Search",
                activeIcon: Icon(Icons.search),
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.temple_hindu_outlined),
                label: "Temple",
                activeIcon: Icon(Icons.temple_hindu),
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.bookmark_outline),
                label: "Saved",
                activeIcon: Icon(Icons.bookmark_outline),
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.people_outline),
                label: "My Family",
                activeIcon: Icon(Icons.people_outline),
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person_outline),
                label: "Profile",
                activeIcon: Icon(Icons.person_outline),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
