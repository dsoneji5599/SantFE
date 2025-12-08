import 'dart:async';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:provider/provider.dart';
import 'package:sant_app/app.dart';
import 'package:sant_app/provider/auth_provider.dart';

import 'package:sant_app/repositories/firebase_api.dart';
import 'package:sant_app/screens/auth/register_user_screen.dart';
import 'package:sant_app/themes/app_fonts.dart';
import 'package:sant_app/utils/my_shareprefernce.dart';
import 'package:sant_app/utils/toast_bar.dart';
import 'package:sant_app/widgets/app_button.dart';
import 'package:sant_app/widgets/app_navigator_animation.dart';
import 'package:sant_app/widgets/app_scaffold.dart';

class OtpScreen extends StatefulWidget {
  final String verificationId;
  final String phoneNumber;
  final bool isUser;
  final bool? isBhai;
  const OtpScreen({
    super.key,
    required this.verificationId,
    required this.phoneNumber,
    required this.isUser,
    this.isBhai,
  });

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final otpController = TextEditingController();
  final FocusNode _otpFocusNode = FocusNode();

  late String verificationId;

  Timer? _timer;
  int _start = 30;
  bool _isResendEnabled = false;

  void startTimer() {
    setState(() {
      _start = 30;
      _isResendEnabled = false;
    });

    _timer?.cancel();
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_start == 0) {
        setState(() {
          _isResendEnabled = true;
        });
        timer.cancel();
      } else {
        setState(() {
          _start--;
        });
      }
    });
  }

  @override
  void initState() {
    super.initState();
    startTimer();
    verificationId = widget.verificationId;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(_otpFocusNode);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    otpController.dispose();
    _otpFocusNode.dispose();
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
                    "Enter Your Pin",
                    style: AppFonts.outfitBlack.copyWith(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    "You get a six digit verification code\nto verify it's you.",
                    textAlign: TextAlign.center,
                    style: AppFonts.outfitBlack.copyWith(
                      fontSize: 14,
                      color: Colors.black,
                    ),
                  ),

                  SizedBox(height: 20),

                  PinCodeTextField(
                    appContext: context,
                    keyboardType: TextInputType.number,
                    length: 6,
                    controller: otpController,
                    focusNode: _otpFocusNode,
                    onChanged: (_) {},
                    pinTheme: PinTheme(
                      shape: PinCodeFieldShape.box,
                      borderRadius: BorderRadius.circular(8),
                      fieldHeight: 45,
                      fieldWidth: 40,
                      borderWidth: 1,
                      activeBorderWidth: 1,
                      inactiveBorderWidth: 1,
                      selectedBorderWidth: 1,
                      activeColor: Colors.orange,
                      selectedColor: Colors.orange,
                      inactiveColor: Colors.grey,
                    ),
                  ),

                  SizedBox(height: 10),

                  Text(
                    "Did not get any code?",
                    textAlign: TextAlign.center,
                    style: AppFonts.outfitBlack,
                  ),

                  // Re-Send Button
                  TextButton(
                    onPressed: _isResendEnabled
                        ? () async {
                            BuildContext? loaderCtx;

                            showDialog(
                              barrierDismissible: false,
                              context: context,
                              builder: (ctx) {
                                loaderCtx = ctx;
                                return const Center(
                                  child: CircularProgressIndicator(),
                                );
                              },
                            );

                            try {
                              final newVerificationId =
                                  await signInWithPhoneNumber(
                                    context,
                                    widget.phoneNumber,
                                  );

                              if (newVerificationId != null) {
                                if (loaderCtx != null) {
                                  Navigator.pop(loaderCtx!);
                                }

                                setState(() {
                                  verificationId = newVerificationId;
                                });

                                toastMessage("OTP resent successfully");
                                startTimer();
                              } else {
                                if (loaderCtx != null) {
                                  Navigator.pop(loaderCtx!);
                                }
                                toastMessage(
                                  "Failed to resend OTP. Try again.",
                                );
                              }
                            } catch (e) {
                              if (loaderCtx != null) Navigator.pop(loaderCtx!);
                              toastMessage("An error occurred. Try again.");
                            }
                          }
                        : null,
                    child: Text(
                      "Re-send",
                      style: AppFonts.outfitBlack.copyWith(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: _isResendEnabled ? Colors.black : Colors.grey,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),

                  Text(
                    "00:${_start.toString().padLeft(2, '0')}s",
                    textAlign: TextAlign.center,
                    style: AppFonts.outfitBlack,
                  ),
                ],
              ),
            ),

            // Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 35),
              child: AppButton(
                text: "Verify OTP",
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
                    final smsCode = otpController.text.trim();

                    if (smsCode.length != 6) {
                      if (loaderCtx != null) Navigator.pop(loaderCtx!);
                      toastMessage("Please enter a 6-digit OTP");
                      return;
                    }

                    final user = await verifyOtpCode(
                      widget.verificationId,
                      smsCode,
                    );

                    if (user != null) {
                      await FirebaseFirestore.instance
                          .collection('users')
                          .doc(user.user?.uid)
                          .set({
                            'uid': user.user?.uid ?? '',
                            'name': user.user?.displayName ?? '',
                            'email': '',
                            'photoUrl': user.user?.photoURL ?? '',
                            'phone': user.user?.phoneNumber ?? '',
                            'createdAt': FieldValue.serverTimestamp(),
                            'isUser': widget.isUser,
                          }, SetOptions(merge: true));
                    }

                    if (widget.isBhai == true) {
                      bool loginSuccess = await context
                          .read<AuthProvider>()
                          .bhaiLogin(
                            phoneNumber: user?.user?.phoneNumber ?? '',
                            firebaseUid: user?.user?.uid ?? '',
                          );
                      MySharedPreferences.instance.setBooleanValue(
                        "isUser",
                        widget.isUser,
                      );

                      if (loginSuccess) {
                        if (loaderCtx != null) Navigator.pop(loaderCtx!);
                        navigatorPushReplacement(context, App(isUser: false));
                        return;
                      }
                      if (loaderCtx != null) Navigator.pop(loaderCtx!);
                      return;
                    }

                    if (user != null) {
                      if (widget.isUser) {
                        bool loginSuccess = await context
                            .read<AuthProvider>()
                            .userLogin(
                              phoneNumber: user.user?.phoneNumber ?? '',
                              firebaseUid: user.user?.uid ?? '',
                            );
                        MySharedPreferences.instance.setBooleanValue(
                          "isUser",
                          widget.isUser,
                        );
                        if (loginSuccess) {
                          if (loaderCtx != null) Navigator.pop(loaderCtx!);

                          navigatorPushReplacement(
                            context,
                            App(isUser: widget.isUser),
                          );
                        } else {
                          if (loaderCtx != null) Navigator.pop(loaderCtx!);

                          navigatorPush(
                            context,
                            RegisterUserScreen(
                              firebaseUid: user.user?.uid ?? "",
                              phoneNumber: widget.phoneNumber,
                              isUser: widget.isUser,
                              isFromPhone: true,
                            ),
                          );
                        }
                      } else {
                        String santResult = await context
                            .read<AuthProvider>()
                            .santLogin(
                              phoneNumber: user.user?.phoneNumber ?? '',
                              firebaseUid: user.user?.uid ?? '',
                            );
                        MySharedPreferences.instance.setBooleanValue(
                          "isUser",
                          widget.isUser,
                        );

                        if (santResult == "success") {
                          if (loaderCtx != null) Navigator.pop(loaderCtx!);

                          navigatorPushReplacement(
                            context,
                            App(isUser: widget.isUser),
                          );
                        } else if (santResult == "new") {
                          if (loaderCtx != null) Navigator.pop(loaderCtx!);

                          navigatorPush(
                            context,
                            RegisterUserScreen(
                              firebaseUid: user.user?.uid ?? "",
                              phoneNumber: widget.phoneNumber,
                              isUser: widget.isUser,
                              isFromPhone: true,
                            ),
                          );
                        } else if (santResult == "pending") {
                          if (loaderCtx != null) Navigator.pop(loaderCtx!);

                          Navigator.of(
                            context,
                          ).popUntil((route) => route.isFirst);
                        }
                      }

                      // Save phone in shared preferences
                      MySharedPreferences.instance.setStringValue(
                        "phone",
                        widget.phoneNumber,
                      );

                      if (loaderCtx != null) Navigator.pop(loaderCtx!);
                    } else {
                      if (loaderCtx != null) Navigator.pop(loaderCtx!);
                      toastMessage('Invalid OTP. Please try again');
                    }
                  } catch (e, s) {
                    if (loaderCtx != null) Navigator.pop(loaderCtx!);
                    log(
                      e.toString(),
                      stackTrace: s,
                      name: 'OTP Verification Error',
                    );
                    toastMessage('Verification failed. Please try again.');
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
