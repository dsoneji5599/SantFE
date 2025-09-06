import 'dart:async';
import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

// Initialize Firebase
final FirebaseAuth _auth = FirebaseAuth.instance;
final GoogleSignIn googleSignIn = GoogleSignIn(
  clientId: kIsWeb
      ? null
      : '324337762463-7sl10g7ssitaib048jmlupqbhbr2ka88.apps.googleusercontent.com',
);

/// Generate a cryptographically secure random nonce for Apple Sign In
String generateNonce([int length = 32]) {
  const charset =
      '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
  final random = Random.secure();
  return List.generate(
    length,
    (_) => charset[random.nextInt(charset.length)],
  ).join();
}

/// Returns the sha256 hash of [input] in hex notation.
String sha256ofString(String input) {
  final bytes = utf8.encode(input);
  final digest = sha256.convert(bytes);
  return digest.toString();
}

// Google Authentication
Future<UserCredential?> signInWithGoogle() async {
  try {
    if (kIsWeb) {
      // For Web
      GoogleAuthProvider authProvider = GoogleAuthProvider();
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithPopup(authProvider);
      return userCredential;
    } else {
      // For Mobile
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      return await FirebaseAuth.instance.signInWithCredential(credential);
    }
    // } on FirebaseAuthException catch (e) {
    //   developer.log(
    //     'Firebase error during Google Sign-In: ${e.code} - ${e.message}',
    //     name: 'error',
    //   );
    //   rethrow;
  } catch (e, stacktrace) {
    developer.log('Error during Google Sign-In: $e', name: 'error');
    developer.log('StackTrace: $stacktrace', name: 'error');
    return null;
  }
}

// Apple Authentication
Future<UserCredential?> signInWithApple() async {
  try {
    // Generate a random nonce and its SHA256 hash
    final rawNonce = generateNonce();
    final nonce = sha256ofString(rawNonce);

    developer.log('Initiating Apple Sign In', name: 'apple');

    // Request Apple ID credentials
    final appleCredential = await SignInWithApple.getAppleIDCredential(
      scopes: [
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName,
      ],
      nonce: nonce,
    );

    // Create an OAuth credential for Firebase
    final oauthCredential = OAuthProvider("apple.com").credential(
      idToken: appleCredential.identityToken,
      accessToken: appleCredential.authorizationCode,
      rawNonce: rawNonce,
    );

    await FirebaseAuth.instance.signOut();

    developer.log('Signing in with Apple credential', name: 'apple');

    // Ensure we have an identity token
    if (appleCredential.identityToken == null) {
      throw Exception('Apple Sign In failed: No identity token returned');
    }

    // Sign in with Firebase
    final userCredential = await _auth.signInWithCredential(oauthCredential);

    // If this is a new user and we have name information, update the display name
    if (userCredential.additionalUserInfo?.isNewUser == true &&
        appleCredential.givenName != null) {
      await userCredential.user?.updateDisplayName(
        '${appleCredential.givenName} ${appleCredential.familyName ?? ""}'
            .trim(),
      );
    }

    return userCredential;
  } on SignInWithAppleException catch (e) {
    developer.log('Apple Sign In Exception: ${e.toString()}', name: 'error');
    return null;
  } on FirebaseAuthException catch (e) {
    developer.log(
      'Firebase error during Apple Sign-In: ${e.code} - ${e.message}',
      name: 'error',
    );
    rethrow;
  } catch (e, stacktrace) {
    developer.log('Error during Apple Sign-In: $e', name: 'error');
    developer.log('StackTrace: $stacktrace', name: 'error');
    return null;
  }
}

Future<String?> signInWithPhoneNumber(
  BuildContext context,
  String phoneNumber,
) async {
  try {
    final completer = Completer<String>();

    await _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: (PhoneAuthCredential credential) async {
        await _auth.signInWithCredential(credential);
      },
      verificationFailed: (FirebaseAuthException e) {
        developer.log('Phone verification failed: ${e.message}', name: 'error');
        completer.completeError(e);
      },
      codeSent: (String verificationId, int? resendToken) async {
        completer.complete(verificationId);
      },
      codeAutoRetrievalTimeout: (String verificationId) {},
      timeout: const Duration(seconds: 60),
    );

    return completer.future;
  } catch (e, stacktrace) {
    developer.log('Error during Phone Sign-In: $e', name: 'error');
    developer.log('StackTrace: $stacktrace', name: 'error');
    return null;
  }
}

Future<UserCredential?> verifyOtpCode(
  String verificationId,
  String smsCode,
) async {
  try {
    final credential = PhoneAuthProvider.credential(
      verificationId: verificationId,
      smsCode: smsCode,
    );

    final userCredential = await _auth.signInWithCredential(credential);
    return userCredential;
  } catch (e, stacktrace) {
    developer.log('OTP verification failed: $e', name: 'error');
    developer.log('StackTrace: $stacktrace', name: 'error');
    return null;
  }
}

// Decode JWT token for debugging
void decodeJwt(String token) {
  try {
    final parts = token.split('.');
    if (parts.length != 3) {
      developer.log('Invalid JWT format', name: 'error');
      return;
    }

    // Normalize and decode the payload part
    final payload = base64Url.decode(base64Url.normalize(parts[1]));
    final decoded = utf8.decode(payload);
    developer.log('JWT Payload: $decoded', name: 'jwt');
  } catch (e) {
    developer.log('Error decoding JWT: $e', name: 'error');
  }
}

// Sign Out
Future<void> signOut() async {
  try {
    // Clear preferences
    SharedPreferences preferences = await SharedPreferences.getInstance();
    await preferences.clear();

    // Sign out from Firebase
    await _auth.signOut();

    // Sign out from Google if signed in
    if (await googleSignIn.isSignedIn()) {
      await googleSignIn.signOut();
    }

    developer.log(
      "Successfully signed out and cleared preferences",
      name: "SignOut",
    );
  } catch (e) {
    developer.log("Error during sign out: $e", name: "SignOut");
    rethrow;
  }
}

// Get current user
User? getCurrentUser() {
  return _auth.currentUser;
}

// Check if user is logged in
bool isUserLoggedIn() {
  return _auth.currentUser != null;
}
