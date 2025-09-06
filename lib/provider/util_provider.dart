import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:sant_app/models/city_model.dart';
import 'package:sant_app/models/country_model.dart';
import 'package:sant_app/models/district_model.dart';
import 'package:sant_app/models/samaj_model.dart';
import 'package:sant_app/models/state_model.dart';
import 'package:sant_app/repositories/util_repo.dart';

class UtilProvider extends ChangeNotifier {
  final repo = UtilRepo();

  List<CountryModel> countryList = [];
  List<StateModel> stateList = [];
  List<CityModel> cityList = [];
  List<DistrictModel> districtList = [];
  List<SamajModel> samajList = [];

  Future<dynamic> getCountry() async {
    try {
      Map<String, dynamic> responseData = await repo.getCountryAPI();
      if (responseData['status_code'] == 200) {
        countryList = List<CountryModel>.from(
          responseData["data"].map((x) => CountryModel.fromJson(x)),
        );
        notifyListeners();
        return countryList;
      } else {
        log(responseData.toString(), name: 'response getCountry');
      }
    } catch (e) {
      log("$e", name: "Error getCountry");
    }
  }

  Future<dynamic> getState({required String countryId}) async {
    try {
      Map<String, dynamic> requestBody = {
        "country": [countryId],
      };

      Map<String, dynamic> responseData = await repo.getStateAPI(requestBody);
      if (responseData['status_code'] == 200) {
        stateList = List<StateModel>.from(
          responseData["data"].map((x) => StateModel.fromJson(x)),
        );
        notifyListeners();
        return stateList;
      } else {
        log(responseData.toString(), name: 'response getState');
      }
    } catch (e) {
      log("$e", name: "Error getState");
    }
  }

  Future<dynamic> getCity({required String stateId}) async {
    try {
      Map<String, dynamic> requestBody = {
        "state": [stateId],
      };

      Map<String, dynamic> responseData = await repo.getCityAPI(requestBody);
      if (responseData['status_code'] == 200) {
        cityList = List<CityModel>.from(
          responseData["data"].map((x) => CityModel.fromJson(x)),
        );
        notifyListeners();
        return cityList;
      } else {
        log(responseData.toString(), name: 'response getCity');
      }
    } catch (e) {
      log("$e", name: "Error getCity");
    }
  }

  Future<dynamic> getDistrict({required String cityId}) async {
    try {
      Map<String, dynamic> requestBody = {
        "city": [cityId],
      };

      Map<String, dynamic> responseData = await repo.getDistrictAPI(
        requestBody,
      );
      if (responseData['status_code'] == 200) {
        districtList = List<DistrictModel>.from(
          responseData["data"].map((x) => DistrictModel.fromJson(x)),
        );
        notifyListeners();
        return districtList;
      } else {
        log(responseData.toString(), name: 'response getDistrict');
      }
    } catch (e) {
      log("$e", name: "Error getDistrict");
    }
  }

  Future<dynamic> getSamaj() async {
    try {
      Map<String, dynamic> responseData = await repo.getSamajAPI();
      if (responseData['status_code'] == 200) {
        samajList = List<SamajModel>.from(
          responseData["data"].map((x) => SamajModel.fromJson(x)),
        );
        notifyListeners();
        return samajList;
      } else {
        log(responseData.toString(), name: 'response getSamaj');
      }
    } catch (e) {
      log("$e", name: "Error getSamaj");
    }
  }
}
