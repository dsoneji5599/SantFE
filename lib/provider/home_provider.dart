import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:sant_app/models/event_model.dart';
import 'package:sant_app/models/family_model.dart';
import 'package:sant_app/models/temple_model.dart';
import 'package:sant_app/repositories/home_repo.dart';
import 'package:sant_app/utils/toast_bar.dart';

class HomeProvider extends ChangeNotifier {
  final repo = HomeRepo();

  List<EventModel> eventList = [];
  List<TempleModel> templeListAll = [];
  List<TempleModel> templeListMy = [];
  List<FamilyModel> familyList = [];

  Future<dynamic> getEventList() async {
    try {
      Map<String, dynamic> responseData = await repo.getEventAPI();
      if (responseData['status_code'] == 200) {
        eventList = List<EventModel>.from(
          responseData["data"].map((x) => EventModel.fromJson(x)),
        );
        notifyListeners();
        return eventList;
      } else {
        log(responseData.toString(), name: 'response getEventList');
      }
    } catch (e) {
      log("$e", name: "Error getEventList");
    }
  }

  Future<dynamic> getTempleList({required String filterType}) async {
    try {
      Map<String, dynamic> responseData = await repo.getTemplesAPI(
        filterType: filterType,
      );
      if (responseData['status_code'] == 200) {
        if (filterType == 'all') {
          templeListAll = List<TempleModel>.from(
            responseData["data"].map((x) => TempleModel.fromJson(x)),
          );
        } else {
          templeListMy = List<TempleModel>.from(
            responseData["data"].map((x) => TempleModel.fromJson(x)),
          );
        }
        notifyListeners();
      } else {
        log(responseData.toString(), name: 'response getTempleList');
      }
    } catch (e) {
      log("$e", name: "Error getTempleList");
    }
  }

  Future<dynamic> getFamilyList() async {
    try {
      Map<String, dynamic> responseData = await repo.getFamilyAPI();
      if (responseData['status_code'] == 200) {
        familyList = List<FamilyModel>.from(
          responseData["data"].map((x) => FamilyModel.fromJson(x)),
        );
        notifyListeners();
        return familyList;
      } else {
        log(responseData.toString(), name: 'response getFamilyList');
      }
    } catch (e) {
      log("$e", name: "Error getFamilyList");
    }
  }

  Future<bool> addTemple({required Map<String, dynamic> data}) async {
    try {
      Map<String, dynamic> responseData = await repo.addTempleAPI(data);
      if (responseData['status_code'] == 201) {
        toastMessage("Temple Added Successfully.");
        await getTempleList(filterType: 'all');
        await getTempleList(filterType: 'my');
        notifyListeners();
        return true;
      } else {
        log(responseData.toString(), name: 'addTemple');
        toastMessage("Failed Adding Temple!");
        return false;
      }
    } catch (e, s) {
      log("$e", stackTrace: s, name: "addTemple");
      toastMessage("Failed Adding Temple!");
      return false;
    }
  }

  Future<bool> editTemple({
    required Map<String, dynamic> data,
    required String templeId,
  }) async {
    try {
      Map<String, dynamic> responseData = await repo.editTempleAPI(
        data,
        templeId,
      );
      if (responseData['status_code'] == 200) {
        toastMessage("Temple Updated Successfully.");
        await getTempleList(filterType: 'all');
        await getTempleList(filterType: 'my');
        return true;
      } else {
        log(responseData.toString(), name: 'editTemple');
        toastMessage("Failed Updating Temple!");
        return false;
      }
    } catch (e, s) {
      log("$e", stackTrace: s, name: "editTemple");
      toastMessage("Failed Updating Temple!");
      return false;
    }
  }

  Future<bool> addEvent({required Map<String, dynamic> data}) async {
    try {
      Map<String, dynamic> responseData = await repo.addEventAPI(data);
      if (responseData['status_code'] == 201) {
        toastMessage("Event Added Successfully.");
        await getEventList();
        notifyListeners();
        return true;
      } else {
        log(responseData.toString(), name: 'addEvent');
        toastMessage("Failed Adding Event!");
        await getEventList();
        notifyListeners();
        return false;
      }
    } catch (e, s) {
      log("$e", stackTrace: s, name: "addEvent");
      toastMessage("Failed Adding Event!");
      return false;
    }
  }

  Future<bool> editEvent({
    required Map<String, dynamic> data,
    required String eventId,
  }) async {
    try {
      Map<String, dynamic> responseData = await repo.editEventAPI(
        data,
        eventId,
      );
      if (responseData['status_code'] == 200) {
        toastMessage("Event Updated Successfully.");
        await getEventList();
        notifyListeners();
        return true;
      } else {
        log(responseData.toString(), name: 'editEvent');
        toastMessage("Failed Updating Event!");
        return false;
      }
    } catch (e, s) {
      log("$e", stackTrace: s, name: "editEvent");
      toastMessage("Failed Updating Event!");
      return false;
    }
  }
}
