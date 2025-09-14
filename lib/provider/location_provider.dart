import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:sant_app/models/live_sant_model.dart';
import 'package:sant_app/models/sant_journey_history.dart';
import 'package:sant_app/repositories/location_repo.dart';
import 'package:sant_app/utils/my_shareprefernce.dart';
import 'package:sant_app/utils/toast_bar.dart';

class LocationProvider extends ChangeNotifier {
  final repo = LocationRepo();
  String journeyId = '';
  LiveSantJourneyModel? liveSantJourneyModel;
  List<SantJourneyHistoryModel> historyList = [];
  List<SantJourneyHistoryModel> nearbySantList = [];

  Future<bool> startJourneyProvider({
    required Map<String, dynamic> data,
  }) async {
    try {
      Map<String, dynamic> responseData = await repo.startJourneyAPI(data);
      if (responseData['status_code'] == 201) {
        toastMessage(
          responseData['message'] != null
              ? responseData['message'].toString()
              : "Journey Started Successfully.",
        );
        return true;
      } else {
        log(responseData.toString(), name: 'error startJourneyProvider');
        toastMessage(
          responseData['message'] != null
              ? responseData['message'].toString()
              : "Failed Starting Journey",
        );
        return false;
      }
    } catch (e, s) {
      log("$e", stackTrace: s, name: "Error startJourneyProvider");
      toastMessage("Failed Starting Journey");
      return false;
    }
  }

  Future<bool> updateJourneyProvider({
    required Map<String, dynamic> data,
  }) async {
    try {
      String? journeyId = await MySharedPreferences.instance.getStringValue(
        "journey_id",
      );
      Map<String, dynamic> responseData = await repo.updateJourneyAPI(
        data,
        journeyId,
      );
      if (responseData['status_code'] == 200) {
        toastMessage(
          responseData['message'] != null
              ? responseData['message'].toString()
              : "Journey Updated Successfully.",
        );
        return true;
      } else {
        log(responseData.toString(), name: 'error updateJourneyProvider');
        toastMessage(
          responseData['message'] != null
              ? responseData['message'].toString()
              : "Failed Updating Journey",
        );
        return false;
      }
    } catch (e, s) {
      log("$e", stackTrace: s, name: "Error updateJourneyProvider");
      toastMessage("Failed Updating Journey");
      return false;
    }
  }

  Future<LiveSantJourneyModel?> getLiveSantJourneyProvider() async {
    try {
      Map<String, dynamic> responseData = await repo.liveSantAPI();
      log(responseData.toString(), name: 'response getLiveSantJourneyProvider');
      if (responseData['status_code'] == 200 && responseData['data'] != null) {
        liveSantJourneyModel = LiveSantJourneyModel.fromJson(
          responseData['data'],
        );
        if (liveSantJourneyModel?.journeyId != null) {
          MySharedPreferences.instance.setStringValue(
            "journey_id",
            liveSantJourneyModel!.journeyId!,
          );
        }
        notifyListeners();
        return liveSantJourneyModel;
      }
    } catch (e, s) {
      log("$e", stackTrace: s, name: "Error getLiveSantJourneyProvider");
    }
    return null;
  }

  Future<dynamic> getSantHistoryList() async {
    try {
      Map<String, dynamic> responseData = await repo.getSantHistoryAPI();
      if (responseData['status_code'] == 200) {
        historyList = List<SantJourneyHistoryModel>.from(
          responseData["data"].map((x) => SantJourneyHistoryModel.fromJson(x)),
        );
        notifyListeners();
        return historyList;
      } else {
        log(responseData.toString(), name: 'response getSantHistoryList');
      }
    } catch (e) {
      log("$e", name: "Error getSantHistoryList");
    }
  }

  Future<dynamic> getNearbySantList() async {
    try {
      Map<String, dynamic> responseData = await repo.getNearbySantPI();
      if (responseData['status_code'] == 200) {
        nearbySantList = List<SantJourneyHistoryModel>.from(
          responseData["data"].map((x) => SantJourneyHistoryModel.fromJson(x)),
        );
        notifyListeners();
        return nearbySantList;
      } else {
        log(responseData.toString(), name: 'response getNearbySantList');
      }
    } catch (e) {
      log("$e", name: "Error getNearbySantList");
    }
  }
}
