import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:sant_app/repositories/firebase_api.dart';
import 'package:sant_app/screens/auth/otp_screen.dart';
import 'package:sant_app/themes/app_fonts.dart';
import 'package:sant_app/utils/toast_bar.dart';
import 'package:sant_app/widgets/app_button.dart';
import 'package:sant_app/widgets/app_navigator_animation.dart';
import 'package:sant_app/widgets/app_scaffold.dart';
import 'package:sant_app/widgets/app_textfield.dart';

class PhoneScreen extends StatefulWidget {
  final bool isUser;
  const PhoneScreen({super.key, required this.isUser});

  @override
  State<PhoneScreen> createState() => _PhoneScreenState();
}

class _PhoneScreenState extends State<PhoneScreen> {
  final phoneNumberController = TextEditingController();
  final FocusNode _numberFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(_numberFocusNode);
    });
  }

  @override
  void dispose() {
    phoneNumberController.dispose();
    _numberFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 50),

            // AppBar
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: Icon(
                    Icons.arrow_back_ios_new,
                    color: Colors.black87,
                    size: 20,
                  ),
                ),
                Text(
                  "OTP Verification",
                  style: AppFonts.outfitBlack.copyWith(
                    fontSize: 20,
                    color: Colors.black87,
                  ),
                ),
                IconButton(
                  onPressed: () {
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  },
                  icon: Icon(Icons.close, color: Colors.black87, size: 24),
                ),
              ],
            ),

            // Main Container
            Container(
              width: double.maxFinite,
              margin: EdgeInsets.symmetric(
                vertical: 45,
                horizontal: 35,
              ).copyWith(bottom: 15),
              padding: EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    "Enter Your Phone Number",
                    style: AppFonts.outfitBlack.copyWith(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    "Enter Your 10 Digit Phone Number\nto verify it's you.",
                    textAlign: TextAlign.center,
                    style: AppFonts.outfitBlack.copyWith(
                      fontSize: 12,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 20),
                  AppTextfield(
                    controller: phoneNumberController,
                    focusNode: _numberFocusNode,
                    label: "Phone Number",
                    hintText: "Enter your Phone Number",
                    textInputType: TextInputType.phone,
                    maxLength: 10,
                  ),
                  SizedBox(height: 50),
                ],
              ),
            ),

            // Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 35),
              child: AppButton(
                text: "Send OTP",
                onTap: () async {
                  BuildContext? loaderCtx;

                  showDialog(
                    barrierDismissible: false,
                    context: context,
                    builder: (ctx) {
                      loaderCtx = ctx;
                      return const Center(child: CircularProgressIndicator());
                    },
                  );

                  try {
                    final phoneNumber =
                        '+91${phoneNumberController.text.trim()}';

                    final verificationId = await signInWithPhoneNumber(
                      context,
                      phoneNumber,
                    );

                    if (verificationId == null) {
                      if (loaderCtx != null) Navigator.pop(loaderCtx!);
                      toastMessage("Phone Sign-In failed! Please try again.");
                      return;
                    }

                    if (loaderCtx != null) Navigator.pop(loaderCtx!);

                    navigatorPush(
                      context,
                      OtpScreen(
                        verificationId: verificationId.toString(),
                        phoneNumber: phoneNumber,
                        isUser: widget.isUser,
                      ),
                    );

                    log(verificationId.toString(), name: 'status');
                  } catch (e, s) {
                    if (loaderCtx != null) Navigator.pop(loaderCtx!);
                    log(
                      e.toString(),
                      stackTrace: s,
                      name: 'Phone Sign-In firebase error',
                    );
                    toastMessage("Phone Sign-In failed! Please try again.");
                  }
                },
              ),
            ),

            SizedBox(height: 50),
          ],
        ),
      ),
    );
  }
}
