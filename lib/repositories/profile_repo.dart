import 'dart:convert';
import 'dart:developer';

import 'package:sant_app/repositories/base_repo.dart';
import 'package:sant_app/utils/app_urls.dart';

class UserProfileRepo extends BaseRepository {
  Future userProfileApi() async {
    final response = await getHttp(
      api: ApiUrls.baseUrl + UserProfileUrls.get,
      token: true,
    );
    log(response.body, name: 'response userProfileApi');
    return json.decode(response.body);
  }

  Future updateUpdateProfileApi(Map<String, dynamic> data) async {
    final response = await postHttp(
      api: ApiUrls.baseUrl + UserProfileUrls.update,
      data: data,
      token: true,
    );
    log(response.body, name: 'response updateUserProfileApi');
    return json.decode(response.body);
  }

  Future santProfileApi() async {
    final response = await getHttp(
      api: ApiUrls.baseUrl + SantUrls.getSantProfile,
      token: true,
    );
    log(response.body, name: 'response santProfileApi');
    return json.decode(response.body);
  }

  Future santUpdateProfileApi(Map<String, dynamic> data) async {
    final response = await postHttp(
      api: ApiUrls.baseUrl + SantUrls.update,
      data: data,
      token: true,
    );
    log(response.body, name: 'response santUpdateProfileApi');
    return json.decode(response.body);
  }
}
