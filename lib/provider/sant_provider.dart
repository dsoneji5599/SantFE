import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:sant_app/models/sant_list_model.dart';
import 'package:sant_app/models/saved_sant_list_model.dart';
import 'package:sant_app/repositories/sant_repo.dart';
import 'package:sant_app/utils/toast_bar.dart';

class SantProvider extends ChangeNotifier {
  final repo = SantRepo();

  List<SantListModel> santList = [];
  List<SavedSantListModel> savedSantList = [];

  Future<dynamic> getSantList() async {
    try {
      Map<String, dynamic> responseData = await repo.getSantApi();
      if (responseData['status_code'] == 200) {
        santList = List<SantListModel>.from(
          responseData["data"].map((x) => SantListModel.fromJson(x)),
        );
        notifyListeners();
        return santList;
      } else {
        log(responseData.toString(), name: 'response getSantList');
      }
    } catch (e) {
      log("$e", name: "Error getSantList");
    }
  }

  Future<dynamic> getSavedSantList() async {
    try {
      Map<String, dynamic> responseData = await repo.getSavedSantApi();
      if (responseData['status_code'] == 200) {
        savedSantList = List<SavedSantListModel>.from(
          responseData["data"].map((x) => SavedSantListModel.fromJson(x)),
        );
        notifyListeners();
        return savedSantList;
      } else {
        log(responseData.toString(), name: 'response getSavedSantList');
      }
    } catch (e) {
      log("$e", name: "Error getSavedSantList");
    }
  }

  Future<bool> addBookmark({required String santId}) async {
    try {
      Map<String, dynamic> responseData = await repo.addBookmarkApi(santId);
      if (responseData['status_code'] == 201) {
        toastMessage("Bookmarked Sant");
        return true;
      } else {
        log(responseData.toString(), name: 'Add Sant Bookmarked Logs');
        toastMessage("Failed Bookmarking Sant");
        return false;
      }
    } catch (e, s) {
      log("$e", stackTrace: s, name: "Error addBookmark");
      toastMessage("Failed Bookmarking Sant");
      return false;
    }
  }

  Future<bool> removeBookmark({required String bookmarkId}) async {
    try {
      Map<String, dynamic> responseData = await repo.removeBookmarkApi(
        bookmarkId,
      );
      if (responseData['status_code'] == 200) {
        toastMessage("Removed Bookmark");
        return true;
      } else {
        log(responseData.toString(), name: 'Add Sant Bookmarked Logs');
        toastMessage("Failed Removing Bookmark");
        return false;
      }
    } catch (e, s) {
      log("$e", stackTrace: s, name: "Error removeBookmark");
      toastMessage("Failed Removing Bookmark");
      return false;
    }
  }
}
