import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:sant_app/models/sant_profile_model.dart';
import 'package:sant_app/models/user_profile_model.dart';
import 'package:sant_app/repositories/profile_repo.dart';
import 'package:sant_app/utils/toast_bar.dart';

class UserProfileProvider extends ChangeNotifier {
  final repo = UserProfileRepo();
  UserProfileModel? userProfileModel;
  SantProfileModel? santProfileModel;

  Future<UserProfileModel?> getProfile() async {
    try {
      Map<String, dynamic> responseData = await repo.userProfileApi();
      log(responseData.toString(), name: 'response getProfileInfoProvider');
      if (responseData['status_code'] == 200) {
        userProfileModel = UserProfileModel.fromJson(responseData['data']);
        notifyListeners();
        return userProfileModel;
      }
    } catch (e, s) {
      log("$e", stackTrace: s, name: "Error getProfileInfoProvider");
    }
    return null;
  }

  Future<bool> updateProfileProvider({
    required Map<String, dynamic> data,
  }) async {
    try {
      Map<String, dynamic> responseData = await repo.updateUpdateProfileApi(
        data,
      );
      if (responseData['status_code'] == 200) {
        toastMessage("Profile Updated Successfully.");
        return true;
      } else {
        log(responseData.toString(), name: 'User Profile Logs');
        toastMessage("Profile Didn't Update");
        return false;
      }
    } catch (e, s) {
      log("$e", stackTrace: s, name: "Error in User Profile Get");
      toastMessage("Profile Didn't Update");
      return false;
    }
  }

  Future<SantProfileModel?> getSantProfile() async {
    try {
      Map<String, dynamic> responseData = await repo.santProfileApi();
      log(responseData.toString(), name: 'response getSantProfile');
      if (responseData['status_code'] == 200) {
        santProfileModel = SantProfileModel.fromJson(responseData['data']);
        notifyListeners();
        return santProfileModel;
      }
    } catch (e, s) {
      log("$e", stackTrace: s, name: "Error getSantProfile");
    }
    return null;
  }

  Future<bool> updateSantProfileProvider({
    required Map<String, dynamic> data,
  }) async {
    try {
      Map<String, dynamic> responseData = await repo.santUpdateProfileApi(data);
      if (responseData['status_code'] == 200) {
        toastMessage("Sant Profile Updated Successfully.");
        return true;
      } else {
        log(responseData.toString(), name: 'User Profile Logs');
        toastMessage("Sant Profile Didn't Update");
        return false;
      }
    } catch (e, s) {
      log("$e", stackTrace: s, name: "Error updateSantProfileProvider");
      toastMessage("Sant Profile Didn't Update");
      return false;
    }
  }
}
