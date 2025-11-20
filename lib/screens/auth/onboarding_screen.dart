import 'package:flutter/material.dart';
import 'package:sant_app/screens/auth/login_screen.dart';
import 'package:sant_app/themes/app_colors.dart';
import 'package:sant_app/themes/app_fonts.dart';
import 'package:sant_app/themes/app_images.dart';
import 'package:sant_app/widgets/app_button.dart';
import 'package:sant_app/widgets/app_navigator_animation.dart';
import 'package:sant_app/widgets/app_scaffold.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 50),

            SizedBox(height: 100),

            // Logo
            CircleAvatar(
              radius: 144,
              backgroundColor: Color(0xFFF3821E),
              child: Image(
                image: AssetImage(AppLogos.appLogo),
                height: 171,
                width: 140,
                fit: BoxFit.fill,
              ),
            ),

            SizedBox(height: 60),

            // Sign In as User Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 50),
              child: AppButton(
                onTap: () {
                  navigatorPush(context, LoginScreen(isUser: true));
                },
                text: 'Sign In as User',
              ),
            ),

            SizedBox(height: 33),

            // Divider
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 50),
              child: Row(
                children: [
                  Expanded(
                    child: Divider(
                      thickness: 1,
                      color: AppColors.black.withValues(alpha: 0.5),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Text(
                      "Or",
                      style: AppFonts.outfitBlack.copyWith(
                        color: AppColors.black.withValues(alpha: 0.5),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Divider(
                      thickness: 1,
                      color: AppColors.black.withValues(alpha: 0.5),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 33),

            // Sign In as Sant Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 50),
              child: AppButton(
                onTap: () {
                  navigatorPush(context, LoginScreen(isUser: false));
                },
                text: 'Sign In as Sant',
              ),
            ),

            SizedBox(height: 100),
          ],
        ),
      ),
    );
  }
}
