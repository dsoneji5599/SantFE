import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' show FirebaseAuth;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sant_app/app.dart';
import 'package:sant_app/provider/auth_provider.dart';
import 'package:sant_app/repositories/firebase_api.dart';
import 'package:sant_app/screens/auth/phone_screen.dart';
import 'package:sant_app/screens/auth/register_user_screen.dart';
import 'package:sant_app/themes/app_colors.dart';
import 'package:sant_app/themes/app_fonts.dart';
import 'package:sant_app/themes/app_images.dart';
import 'package:sant_app/utils/my_shareprefernce.dart';
import 'package:sant_app/utils/toast_bar.dart';
import 'package:sant_app/widgets/app_button.dart';
import 'package:sant_app/widgets/app_navigator_animation.dart';
import 'package:sant_app/widgets/app_scaffold.dart';

class LoginScreen extends StatefulWidget {
  final bool isUser;
  const LoginScreen({super.key, required this.isUser});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      body: Column(
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

          // Sign In Button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 50),
            child: AppButton(
              onTap: () {
                navigatorPush(context, PhoneScreen(isUser: widget.isUser));
              },
              text: 'Sign In',
            ),
          ),

          SizedBox(height: 65),

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
                    "Or sign in with",
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

          // Signup With Google & Apple Button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 50),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Google Button
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      BuildContext? loaderCTX0;

                      showDialog(
                        barrierDismissible: false,
                        context: context,
                        builder: (ctx) {
                          loaderCTX0 = ctx;
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        },
                      );

                      try {
                        final value = await signInWithGoogle();

                        log(value.toString(), name: "Signin with Google Logs");

                        if (value == null) {
                          Navigator.pop(loaderCTX0!);
                          toastMessage(
                            "Google Sign-In failed! Please try again.",
                          );
                          return;
                        }

                        final currentUser = FirebaseAuth.instance.currentUser;
                        if (currentUser == null ||
                            currentUser.uid != value.user?.uid) {
                          Navigator.pop(loaderCTX0!);
                          toastMessage("User not authenticated properly.");
                          return;
                        }

                        await FirebaseFirestore.instance
                            .collection('users')
                            .doc(value.user?.uid)
                            .set({
                              'uid': value.user?.uid ?? '',
                              'name': value.user?.displayName ?? '',
                              'email': value.user?.email ?? '',
                              'photoUrl': value.user?.photoURL ?? '',
                              'phone': '', // no phone here for Google Sign-In
                              'createdAt': FieldValue.serverTimestamp(),
                              'isUser': widget.isUser,
                            }, SetOptions(merge: true));

                        Navigator.pop(loaderCTX0!);

                        if (widget.isUser) {
                          final isNewUser = !(await context
                              .read<AuthProvider>()
                              .checkUserExist(email: value.user?.email));

                          if (isNewUser) {
                            navigatorPush(
                              context,
                              RegisterUserScreen(
                                firebaseUid: value.user?.uid ?? '',
                                email: value.user?.email ?? '',
                                isUser: widget.isUser,
                                isFromPhone: false,
                              ),
                            );
                            return;
                          }
                        } else {
                          final isNewSant = !(await context
                              .read<AuthProvider>()
                              .checkSantExist(email: value.user?.email));

                          if (isNewSant) {
                            navigatorPush(
                              context,
                              RegisterUserScreen(
                                firebaseUid: value.user?.uid ?? '',
                                email: value.user?.email ?? '',
                                isUser: widget.isUser,
                                isFromPhone: false,
                              ),
                            );
                            return;
                          }
                        }

                        // Existing user login attempt
                        bool loginSuccess;

                        if (widget.isUser) {
                          loginSuccess = await context
                              .read<AuthProvider>()
                              .userLogin(
                                email: value.user?.email ?? '',
                                firebaseUid: value.user?.uid ?? '',
                              );
                          MySharedPreferences.instance.setBooleanValue(
                            "isUser",
                            widget.isUser,
                          );
                        } else {
                          loginSuccess = await context
                              .read<AuthProvider>()
                              .santLogin(
                                email: value.user?.email ?? '',
                                firebaseUid: value.user?.uid ?? '',
                              );
                          MySharedPreferences.instance.setBooleanValue(
                            "isUser",
                            widget.isUser,
                          );
                        }

                        // if (loaderCTX0 != null) Navigator.pop(loaderCTX0!);

                        if (loginSuccess) {
                          if (widget.isUser) {
                            navigatorPushReplacement(
                              context,
                              App(isUser: widget.isUser),
                            );
                          } else {
                            navigatorPushReplacement(
                              context,
                              App(isUser: widget.isUser),
                            );
                          }
                        } else {
                          toastMessage('Login failed. Please try again.');
                        }
                      } catch (e, s) {
                        if (loaderCTX0 != null) Navigator.pop(loaderCTX0!);
                        log(
                          e.toString(),
                          stackTrace: s,
                          name: 'firebase error',
                        );
                        toastMessage(
                          'Google Sign-In failed! Please try again.',
                        );
                      }
                    },

                    icon: Image.asset(AppIcons.googleIcon, height: 16),
                    label: const Text(
                      'Google',
                      style: TextStyle(color: Colors.black54, fontSize: 12),
                    ),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.all(10),
                      side: BorderSide(color: Colors.grey),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 10),

                // Apple Button
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      BuildContext? loaderCTX0;
                      showDialog(
                        barrierDismissible: false,
                        context: context,
                        builder: (ctx) {
                          loaderCTX0 = ctx;
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        },
                      ).then((value) => loaderCTX0 = null);

                      if (Platform.isIOS) {
                        try {
                          final value = await signInWithApple();

                          if (value == null) {
                            if (loaderCTX0 != null) Navigator.pop(loaderCTX0!);
                            toastMessage(
                              "Apple Sign-In failed! Please try again.",
                            );
                            return;
                          }

                          final isNewUser = !(await context
                              .read<AuthProvider>()
                              .checkUserExist(email: value.user?.email));

                          if (loaderCTX0 != null) Navigator.pop(loaderCTX0!);

                          if (isNewUser) {
                            navigatorPush(
                              context,
                              RegisterUserScreen(
                                firebaseUid: value.user?.uid ?? "",
                                email: value.user?.email ?? '',
                                isUser: widget.isUser,
                                isFromPhone: false,
                              ),
                            );
                            return;
                          }

                          // Existing user login attempt
                          bool loginSuccess;

                          if (widget.isUser) {
                            loginSuccess = await context
                                .read<AuthProvider>()
                                .userLogin(
                                  phoneNumber: value.user?.email ?? '',
                                  firebaseUid: value.user?.uid ?? '',
                                );
                            MySharedPreferences.instance.setBooleanValue(
                              "isUser",
                              widget.isUser,
                            );
                          } else {
                            loginSuccess = await context
                                .read<AuthProvider>()
                                .santLogin(
                                  phoneNumber: value.user?.email ?? '',
                                  firebaseUid: value.user?.uid ?? '',
                                );
                            MySharedPreferences.instance.setBooleanValue(
                              "isUser",
                              widget.isUser,
                            );
                          }

                          if (loaderCTX0 != null) Navigator.pop(loaderCTX0!);

                          if (loginSuccess) {
                            if (widget.isUser) {
                              navigatorPushReplacement(
                                context,
                                App(isUser: widget.isUser),
                              );
                            } else {
                              navigatorPushReplacement(
                                context,
                                App(isUser: widget.isUser),
                              );
                            }
                          } else {
                            toastMessage('Login failed. Please try again.');
                          }
                        } catch (e, s) {
                          if (loaderCTX0 != null) Navigator.pop(loaderCTX0!);
                          log(
                            e.toString(),
                            stackTrace: s,
                            name: 'firebase error',
                          );
                          toastMessage(
                            'Apple Sign-In failed. Please try again.',
                          );
                        }
                      } else {
                        toastMessage("Please Use iOS Device to Continue");
                        Navigator.pop(context);
                      }
                    },

                    icon: Image.asset(AppIcons.appleIcon, height: 16),
                    label: const Text(
                      'Apple',
                      style: TextStyle(color: Colors.black54, fontSize: 12),
                    ),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.all(10),
                      side: BorderSide(color: Colors.grey),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
