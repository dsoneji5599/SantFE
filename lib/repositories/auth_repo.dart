import 'dart:convert';
import 'dart:developer';

import 'package:sant_app/repositories/base_repo.dart';
import 'package:sant_app/utils/app_urls.dart';

// User Repo
class UserAuthRepository extends BaseRepository {
  Future userLoginApi(Map<String, dynamic> data) async {
    final response = await postHttp(
      api: ApiUrls.baseUrl + UserAuthUrls.login,
      data: data,
    );
    log(response.body, name: 'response userLoginApi');
    return json.decode(response.body);
  }

  Future userRegisteregisterApi(Map<String, dynamic> data) async {
    final response = await postHttp(
      api: ApiUrls.baseUrl + UserAuthUrls.register,
      data: data,
    );
    log(response.body, name: 'response userRegisteregisterApi');
    return json.decode(response.body);
  }

  Future checkUserExistApi({String? phone, String? email}) async {
    String params = '';
    if (phone != null) params += '?mobile=$phone';
    if (email != null) {
      params += params.isEmpty ? '?email=$email' : '&email=$email';
    }

    final response = await getHttp(
      api: ApiUrls.baseUrl + UserAuthUrls.checkUserExist + params,
    );
    log(response.body, name: 'response checkUserExistApi');
    return json.decode(response.body);
  }
}

// Sant Repo
class SantAuthRepository extends BaseRepository {
  Future santLoginApi(Map<String, dynamic> data) async {
    final response = await postHttp(
      api: ApiUrls.baseUrl + SantAuthUrls.login,
      data: data,
    );
    log(response.body, name: 'response santLoginApi');
    return json.decode(response.body);
  }

  Future santRegisteregisterApi(Map<String, dynamic> data) async {
    final response = await postHttp(
      api: ApiUrls.baseUrl + SantAuthUrls.register,
      data: data,
    );
    log(response.body, name: 'response santRegisteregisterApi');
    return json.decode(response.body);
  }

  Future checkSantExistApi({String? phone, String? email}) async {
    String params = '';
    if (phone != null) params += '?mobile=$phone';
    if (email != null) {
      params += params.isEmpty ? '?email=$email' : '&email=$email';
    }

    final response = await getHttp(
      api: ApiUrls.baseUrl + SantAuthUrls.checkSantExist + params,
    );
    log(response.body, name: 'response checkSantExistApi');
    return json.decode(response.body);
  }

  Future bhaiLoginApi(Map<String, dynamic> data) async {
    final response = await postHttp(
      api: ApiUrls.baseUrl + SantAuthUrls.bhaiLogin,
      data: data,
    );
    log(response.body, name: 'response bhaiLoginApi');
    return json.decode(response.body);
  }
}
