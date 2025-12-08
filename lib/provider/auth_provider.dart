import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:sant_app/repositories/auth_repo.dart';
import 'package:sant_app/utils/my_shareprefernce.dart';
import 'package:sant_app/utils/toast_bar.dart';

class AuthProvider extends ChangeNotifier {
  UserAuthRepository userAuthRepo = UserAuthRepository();
  SantAuthRepository santAuthRepo = SantAuthRepository();
  bool loggedIn = false;
  String userId = '';
  String accessToken = '';
  String refreshToken = '';
  bool? isNewUser;

  Future<void> getToken() async {
    String? token = await MySharedPreferences.instance.getStringValue(
      "access_token",
    );
    String? uId = await MySharedPreferences.instance.getStringValue("user_id");
    userId = uId ?? '';
    loggedIn = token != null;
    log(userId.toString(), name: "User Id");
    notifyListeners();
  }

  Future<bool> userLogin({
    String? firebaseUid,
    String? phoneNumber,
    String? email,
  }) async {
    try {
      Map<String, dynamic> data = {
        'firebase_uid': firebaseUid,
        if (phoneNumber?.isNotEmpty == true)
          'mobile': phoneNumber
        else if (email?.isNotEmpty == true)
          'email': email,
      };

      final response = await userAuthRepo.userLoginApi(data);
      final statusCode = int.tryParse(response['status_code'].toString());

      if (statusCode == 200) {
        userId = response["data"]["user_id"];
        accessToken = response["data"]["access_token"];
        refreshToken = response["data"]["refresh_token"];

        MySharedPreferences.instance.setStringValue("user_id", userId);
        MySharedPreferences.instance.setStringValue(
          "access_token",
          accessToken,
        );
        MySharedPreferences.instance.setStringValue(
          "refresh_token",
          refreshToken,
        );

        await getToken();
        return true;
      } else if (statusCode == 403) {
        toastMessage(
          response['message'] ?? 'User is blocked',
          isSuccess: false,
        );
        return false;
      } else {
        log(response['message'] ?? 'Failed login User');
        // toastMessage(
        //   response['message'] ?? 'Failed login User',
        //   isSuccess: false,
        // );
        return false;
      }
    } catch (e, s) {
      log(e.toString(), stackTrace: s, name: "response userLogin");
      toastMessage('Something went wrong!', isSuccess: false);
      return false;
    }
  }

  Future<bool> userRegister({required Map<String, dynamic> data}) async {
    try {
      final response = await userAuthRepo.userRegisteregisterApi(data);
      final statusCode = int.tryParse(response['status_code'].toString());

      if (statusCode == 201) {
        userId = response["data"]["user_id"];
        accessToken = response["data"]["access_token"];
        refreshToken = response["data"]["refresh_token"];

        MySharedPreferences.instance.setStringValue("user_id", userId);
        MySharedPreferences.instance.setStringValue(
          "access_token",
          accessToken,
        );
        MySharedPreferences.instance.setStringValue(
          "refresh_token",
          refreshToken,
        );

        await getToken();
        return true;
      } else {
        log(response['message'] ?? 'Failed Registering User');
        toastMessage(
          response['message'] ?? 'Failed Registering User',
          isSuccess: false,
        );
        return false;
      }
    } catch (e, s) {
      log(e.toString(), stackTrace: s, name: "response userRegister");
      toastMessage('Something went wrong!', isSuccess: false);
      return false;
    }
  }

  Future<bool> checkUserExist({String? phone, String? email}) async {
    try {
      final response = await userAuthRepo.checkUserExistApi(
        phone: phone,
        email: email,
      );
      final statusCode = int.tryParse(response['status_code'].toString());

      if (statusCode == 200) {
        return true;
      } else {
        return false;
      }
    } catch (e, s) {
      log(e.toString(), stackTrace: s, name: "response checkUserExist");
      return false;
    }
  }

  // Sant Functions
  Future<String> santLogin({
    String? firebaseUid,
    String? phoneNumber,
    String? email,
  }) async {
    try {
      Map<String, dynamic> data = {
        'firebase_uid': firebaseUid,
        if (phoneNumber?.isNotEmpty == true)
          'mobile': phoneNumber
        else if (email?.isNotEmpty == true)
          'email': email,
      };

      final response = await santAuthRepo.santLoginApi(data);
      final statusCode = int.tryParse(response['status_code'].toString());

      if (statusCode == 200) {
        final loginData = response["data"];
        if (loginData == null || (loginData is Map && loginData.isEmpty)) {
          toastMessage(
            response['message'] ?? 'Saint approval is still pending.',
            isSuccess: false,
          );
          return "pending";
        }

        accessToken = response["data"]["access_token"];
        refreshToken = response["data"]["refresh_token"];

        MySharedPreferences.instance.setStringValue("user_id", userId);
        MySharedPreferences.instance.setStringValue(
          "access_token",
          accessToken,
        );
        MySharedPreferences.instance.setStringValue(
          "refresh_token",
          refreshToken,
        );

        await getToken();
        return "success";
      } else {
        log(response['message'] ?? 'Failed login Sant');
        return "new";
      }
    } catch (e, s) {
      log(e.toString(), stackTrace: s, name: "response santLogin");
      toastMessage('Something went wrong!', isSuccess: false);
      return "new";
    }
  }

  Future<String> santRegister({required Map<String, dynamic> data}) async {
    try {
      final response = await santAuthRepo.santRegisteregisterApi(data);
      final statusCode = int.tryParse(response['status_code'].toString());

      if (statusCode == 201) {
        final loginData = response["data"];
        if (loginData == null || (loginData is Map && loginData.isEmpty)) {
          toastMessage(
            response['message'] ??
                'Saint registered successfully. Awaiting approval.',
            isSuccess: false,
          );
          return "pending";
        }

        accessToken = response["data"]["access_token"];
        refreshToken = response["data"]["refresh_token"];

        MySharedPreferences.instance.setStringValue("user_id", userId);
        MySharedPreferences.instance.setStringValue(
          "access_token",
          accessToken,
        );
        MySharedPreferences.instance.setStringValue(
          "refresh_token",
          refreshToken,
        );

        await getToken();
        return "success";
      } else {
        toastMessage(
          response['message'] ?? 'Failed Registering Sant',
          isSuccess: false,
        );
        return "new";
      }
    } catch (e, s) {
      log(e.toString(), stackTrace: s, name: "response santRegister");
      toastMessage('Something went wrong!', isSuccess: false);
      return "new";
    }
  }

  Future<bool> checkSantExist({String? phone, String? email}) async {
    try {
      final response = await santAuthRepo.checkSantExistApi(
        phone: phone,
        email: email,
      );
      final statusCode = int.tryParse(response['status_code'].toString());

      if (statusCode == 200) {
        return true;
      } else {
        return false;
      }
    } catch (e, s) {
      log(e.toString(), stackTrace: s, name: "response checkSantExist");
      return false;
    }
  }

  // Bhai Login
  Future<bool> bhaiLogin({
    String? firebaseUid,
    String? phoneNumber,
    String? email,
  }) async {
    try {
      Map<String, dynamic> data = {
        'firebase_uid': firebaseUid,
        if (phoneNumber?.isNotEmpty == true)
          'mobile': phoneNumber
        else if (email?.isNotEmpty == true)
          'email': email,
      };

      final response = await santAuthRepo.bhaiLoginApi(data);
      final statusCode = int.tryParse(response['status_code'].toString());

      if (statusCode == 200) {
        accessToken = response["data"]["access_token"];
        refreshToken = response["data"]["refresh_token"];

        MySharedPreferences.instance.setStringValue("user_id", userId);
        MySharedPreferences.instance.setStringValue(
          "access_token",
          accessToken,
        );
        MySharedPreferences.instance.setStringValue(
          "refresh_token",
          refreshToken,
        );

        toastMessage('Successfully Login as Bhai');

        await getToken();
        return true;
      } else {
        log(response['message'] ?? 'Failed login Sant');
        toastMessage(response['message'] ?? 'Failed login Sant');

        return false;
      }
    } catch (e, s) {
      log(e.toString(), stackTrace: s, name: "response bhaiLogin");
      toastMessage('Something went wrong!', isSuccess: false);
      return false;
    }
  }
}
