//Third Party Imports
import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:sant_app/utils/my_shareprefernce.dart';
import 'package:sant_app/utils/toast_bar.dart';

class BaseRepository {
  /// For POST request
  Future<http.Response> postHttp({
    required Map<String, dynamic> data,
    required String api,
    bool token = false,
  }) async {
    String? accessToken;
    final url = api;
    log(url, name: 'postHttp');
    log(data.toString(), name: '$api data');
    if (token) {
      accessToken = await MySharedPreferences.instance.getStringValue(
        "access_token",
      );
      log(accessToken.toString(), name: "access_token");
    }

    final response = await http.post(
      Uri.parse(url),
      headers: accessToken == null
          ? {'Content-Type': 'application/json'}
          : {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $accessToken',
            },
      body: json.encode(data),
    );
    log(response.statusCode.toString(), name: "Status Code");
    if (response.statusCode == 500) {
      toastMessage("Server error, Please try again Later!");
    }
    return response;
  }

  /// For GET request
  Future<http.Response> getHttp({
    required String api,
    bool token = false,
    Map<String, dynamic>? data,
  }) async {
    String? accessToken;
    final url = api;
    log(url, name: 'getHttp');
    if (token) {
      accessToken = await MySharedPreferences.instance.getStringValue(
        "access_token",
      );
      log(accessToken.toString(), name: "access_token");
    }

    final response = await http.get(
      Uri.parse(url),
      headers: accessToken == null
          ? {'Content-Type': 'application/json'}
          : {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $accessToken',
            },
    );
    log(response.statusCode.toString(), name: api);
    if (response.statusCode == 500) {
      toastMessage("Server error, Please try again Later!");
    }
    return response;
  }

  /// For PUT request
  Future<http.Response> putHttp({
    required Map<String, dynamic> data,
    required String api,
    bool token = false,
  }) async {
    String? accessToken;
    final url = api;
    log(url, name: 'putHttp');
    log(data.toString(), name: '$api data');
    if (token) {
      accessToken = await MySharedPreferences.instance.getStringValue(
        "access_token",
      );
      log(accessToken.toString(), name: "access_token");
    }
    final response = await http.put(
      Uri.parse(url),
      headers: accessToken == null
          ? {'Content-Type': 'application/json'}
          : {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $accessToken',
            },
      body: json.encode(data),
    );
    log(response.statusCode.toString());
    if (response.statusCode == 500) {
      toastMessage("Server error, Please try again Later!");
    }
    return response;
  }

  /// For DELETE request
  Future<http.Response> deleteHttp({
    required String api,
    bool token = false,
  }) async {
    String? accessToken;
    final url = api;
    log(url, name: 'deleteHttp');
    if (token) {
      accessToken = await MySharedPreferences.instance.getStringValue(
        "access_token",
      );
      log(accessToken.toString(), name: "access_token");
    }

    final response = await http.delete(
      Uri.parse(url),
      headers: accessToken == null
          ? {'Content-Type': 'application/json'}
          : {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $accessToken',
            },
    );
    log(response.toString());
    if (response.statusCode == 500) {
      toastMessage("Server error, Please try again Later!");
    }
    return response;
  }

  // Future<int> refreshToken() async {
  //   String? refreshToken = await MySharedPreferences.instance.getStringValue(
  //     "refresh_token",
  //   );
  //   final url = ApiUrls.baseUrl + UserAuthUrls.refreshToken;
  //   log(refreshToken.toString(), name: 'refreshToken');

  //   final response = await http.post(
  //     Uri.parse(url),
  //     headers: {
  //       'Content-Type': 'application/json',
  //       'Authorization': 'Bearer $refreshToken',
  //     },
  //   );
  //   log(response.body, name: 'response refreshToken');
  //   if (response.statusCode == 200) {
  //     String accessToken = json.decode(response.body)['data']["access_token"];
  //     String refreshToken = json.decode(response.body)['data']["refresh_token"];
  //     MySharedPreferences.instance.setStringValue("access_token", accessToken);
  //     MySharedPreferences.instance.setStringValue(
  //       "refresh_token",
  //       refreshToken,
  //     );
  //   }
  //   return response.statusCode;
  // }
}
