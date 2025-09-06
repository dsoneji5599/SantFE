import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:sant_app/models/sant_list_model.dart';
import 'package:sant_app/repositories/sant_repo.dart';

class SantProvider extends ChangeNotifier {
  final repo = SantRepo();

  List<SantListModel> santList = [];

  Future<dynamic> getSantList() async {
    try {
      Map<String, dynamic> responseData = await repo.getSantAPI();
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
}
