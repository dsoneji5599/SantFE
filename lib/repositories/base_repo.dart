// Third Party Imports
import 'dart:convert';
import 'dart:developer' as developer;
import 'package:http/http.dart' as http;

// Project Imports
import 'package:sant_app/repositories/firebase_api.dart';
import 'package:sant_app/screens/auth/onboarding_screen.dart';
import 'package:sant_app/utils/app_urls.dart';
import 'package:sant_app/utils/my_shareprefernce.dart';
import 'package:sant_app/utils/toast_bar.dart';
import 'package:sant_app/widgets/app_navigator_animation.dart';
import 'package:sant_app/widgets/keys.dart';

class BaseRepository {
  static bool _isBlockedHandled = false;

  Future<bool> _checkUserBlocked() async {
    try {
      if (_isBlockedHandled) return true;

      final accessToken = await MySharedPreferences.instance.getStringValue(
        "access_token",
      );

      if (accessToken == null || accessToken.isEmpty) {
        return false;
      }

      final response = await http.get(
        Uri.parse(ApiUrls.baseUrl + UserAuthUrls.checkUserIsBlocked),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
      );

      developer.log(response.body, name: '_checkUserBlocked response');

      if (response.statusCode == 403 || response.body == 'User Blocked') {
        _isBlockedHandled = true;

        await signOut();

        toastMessage("Your account has been blocked.");

        final context = Keys.navigatorKey.currentContext;
        if (context != null) {
          navigatorPushReplacement(context, OnboardingScreen());
        }

        return true;
      }
    } catch (e) {
      developer.log(e.toString(), name: '_checkUserBlocked error');
      return false;
    }

    return false;
  }

  /// POST
  Future<http.Response> postHttp({
    required Map<String, dynamic> data,
    required String api,
    bool token = false,
  }) async {
    if (await _checkUserBlocked()) {
      return http.Response('User Blocked', 403);
    }

    String? accessToken;

    developer.log(api, name: 'postHttp');
    developer.log(data.toString(), name: '$api data');

    if (token) {
      accessToken = await MySharedPreferences.instance.getStringValue(
        "access_token",
      );
    }

    final response = await http.post(
      Uri.parse(api),
      headers: accessToken == null
          ? {'Content-Type': 'application/json'}
          : {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $accessToken',
            },
      body: json.encode(data),
    );

    developer.log(response.statusCode.toString(), name: "Status Code");

    if (response.statusCode == 500) {
      toastMessage("Server error, Please try again Later!");
    }

    return response;
  }

  /// GET
  Future<http.Response> getHttp({
    required String api,
    bool token = false,
    Map<String, dynamic>? data,
  }) async {
    if (await _checkUserBlocked()) {
      return http.Response('User Blocked', 403);
    }

    String? accessToken;

    developer.log(api, name: 'getHttp');

    if (token) {
      accessToken = await MySharedPreferences.instance.getStringValue(
        "access_token",
      );
    }

    final response = await http.get(
      Uri.parse(api),
      headers: accessToken == null
          ? {'Content-Type': 'application/json'}
          : {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $accessToken',
            },
    );

    developer.log(response.statusCode.toString(), name: api);

    if (response.statusCode == 500) {
      toastMessage("Server error, Please try again Later!");
    }

    return response;
  }

  /// PUT
  Future<http.Response> putHttp({
    required Map<String, dynamic> data,
    required String api,
    bool token = false,
  }) async {
    if (await _checkUserBlocked()) {
      return http.Response('User Blocked', 403);
    }

    String? accessToken;

    developer.log(api, name: 'putHttp');
    developer.log(data.toString(), name: '$api data');

    if (token) {
      accessToken = await MySharedPreferences.instance.getStringValue(
        "access_token",
      );
    }

    final response = await http.put(
      Uri.parse(api),
      headers: accessToken == null
          ? {'Content-Type': 'application/json'}
          : {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $accessToken',
            },
      body: json.encode(data),
    );

    developer.log(response.statusCode.toString());

    if (response.statusCode == 500) {
      toastMessage("Server error, Please try again Later!");
    }

    return response;
  }

  /// DELETE
  Future<http.Response> deleteHttp({
    required String api,
    bool token = false,
  }) async {
    if (await _checkUserBlocked()) {
      return http.Response('User Blocked', 403);
    }

    String? accessToken;

    developer.log(api, name: 'deleteHttp');

    if (token) {
      accessToken = await MySharedPreferences.instance.getStringValue(
        "access_token",
      );
    }

    final response = await http.delete(
      Uri.parse(api),
      headers: accessToken == null
          ? {'Content-Type': 'application/json'}
          : {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $accessToken',
            },
    );

    developer.log(response.toString());

    if (response.statusCode == 500) {
      toastMessage("Server error, Please try again Later!");
    }

    return response;
  }
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

