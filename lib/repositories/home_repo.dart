import 'dart:convert';
import 'dart:developer';

import 'package:sant_app/repositories/base_repo.dart';
import 'package:sant_app/utils/app_urls.dart';

class HomeRepo extends BaseRepository {
  Future getEventAPI() async {
    final response = await getHttp(
      api: ApiUrls.baseUrl + HomeUrls.getEvents,
      token: true,
    );
    log(response.body, name: 'response getEventAPI');
    return json.decode(response.body);
  }

  Future getTemplesAPI({required String filterType}) async {
    final response = await getHttp(
      api: "${ApiUrls.baseUrl}${HomeUrls.getTemples}?filter_type=$filterType",
      token: true,
    );
    log(response.body, name: 'response getTemplesAPI');
    return json.decode(response.body);
  }

  Future getFamilyAPI() async {
    final response = await getHttp(
      api: ApiUrls.baseUrl + HomeUrls.getFamily,
      token: true,
    );
    log(response.body, name: 'response getFamilyAPI');
    return json.decode(response.body);
  }

  Future addFamilyMemberAPI(Map<String, dynamic> data) async {
    final response = await postHttp(
      api: ApiUrls.baseUrl + HomeUrls.addFamily,
      data: data,
      token: true,
    );
    log(response.body, name: 'response addFamilyMemberAPI');
    return json.decode(response.body);
  }

  Future addTempleAPI(Map<String, dynamic> data) async {
    final response = await postHttp(
      api: ApiUrls.baseUrl + HomeUrls.addTemples,
      data: data,
      token: true,
    );
    log(response.body, name: 'response addTempleAPI');
    return json.decode(response.body);
  }

  Future editTempleAPI(Map<String, dynamic> data, String templeId) async {
    String params = '?temple_id=$templeId';
    final response = await postHttp(
      api: ApiUrls.baseUrl + HomeUrls.editTemples + params,
      data: data,
      token: true,
    );
    log(response.body, name: 'response editTempleAPI');
    return json.decode(response.body);
  }

  Future addEventAPI(Map<String, dynamic> data) async {
    final response = await postHttp(
      api: ApiUrls.baseUrl + HomeUrls.addEvent,
      data: data,
      token: true,
    );
    log(response.body, name: 'response addEventAPI');
    return json.decode(response.body);
  }

  Future editEventAPI(Map<String, dynamic> data, String eventId) async {
    String params = '?event_id=$eventId';
    final response = await postHttp(
      api: ApiUrls.baseUrl + HomeUrls.editEvent + params,
      data: data,
      token: true,
    );
    log(response.body, name: 'response editEventAPI');
    return json.decode(response.body);
  }
}
