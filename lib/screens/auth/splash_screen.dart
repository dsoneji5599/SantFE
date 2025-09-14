import 'package:flutter/material.dart';
import 'package:sant_app/app.dart';
import 'package:sant_app/screens/auth/onboarding_screen.dart';
import 'package:sant_app/themes/app_images.dart';
import 'package:sant_app/utils/my_shareprefernce.dart';
import 'package:sant_app/widgets/app_navigator_animation.dart';
import 'package:sant_app/widgets/app_scaffold.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 1)).then((value) => redirect());
  }

  Future<void> redirect() async {
    final isUser = await MySharedPreferences.instance.getBooleanValue("isUser");

    final value = await MySharedPreferences.instance.getStringValue(
      "access_token",
    );

    if (!mounted) return;

    navigatorPushReplacement(
      context,
      value == null ? OnboardingScreen() : App(isUser: isUser),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      body: Center(
        child: CircleAvatar(
          radius: 144,
          backgroundColor: Color(0xFFF3821E),
          child: Image(
            image: AssetImage(AppLogos.appLogo),
            height: 171,
            width: 140,
            fit: BoxFit.fill,
          ),
        ),
      ),
    );
  }
}
