import 'dart:convert';
import 'dart:developer';

import 'package:sant_app/repositories/base_repo.dart';
import 'package:sant_app/utils/app_urls.dart';

class UtilRepo extends BaseRepository {
  Future getCountryAPI() async {
    final response = await getHttp(api: ApiUrls.baseUrl + UtilUrls.country);
    log(response.body, name: 'response getCountryAPI');
    return json.decode(response.body);
  }

  Future getStateAPI(Map<String, dynamic> body) async {
    final response = await postHttp(
      data: body,
      api: ApiUrls.baseUrl + UtilUrls.state,
    );
    log(response.body, name: 'response getStateAPI');
    return json.decode(response.body);
  }

  Future getCityAPI(Map<String, dynamic> body) async {
    final response = await postHttp(
      data: body,
      api: ApiUrls.baseUrl + UtilUrls.city,
    );
    log(response.body, name: 'response getCityAPI');
    return json.decode(response.body);
  }

  Future getDistrictAPI(Map<String, dynamic> body) async {
    final response = await postHttp(
      data: body,
      api: ApiUrls.baseUrl + UtilUrls.district,
    );
    log(response.body, name: 'response getDistrictAPI');
    return json.decode(response.body);
  }

  Future getSamajAPI() async {
    final response = await getHttp(api: ApiUrls.baseUrl + UtilUrls.samaj);
    log(response.body, name: 'response getSamajAPI');
    return json.decode(response.body);
  }
}
