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
}
