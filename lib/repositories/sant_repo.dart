import 'dart:convert';
import 'dart:developer';

import 'package:sant_app/repositories/base_repo.dart';
import 'package:sant_app/utils/app_urls.dart';

class SantRepo extends BaseRepository {
  Future getSantAPI() async {
    final response = await getHttp(
      api: ApiUrls.baseUrl + SantUrls.getSant,
      token: true,
    );
    log(response.body, name: 'response getSantAPI');
    return json.decode(response.body);
  }
}
