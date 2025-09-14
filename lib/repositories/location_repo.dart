import 'dart:convert';
import 'dart:developer';

import 'package:sant_app/repositories/base_repo.dart';
import 'package:sant_app/utils/app_urls.dart';

class LocationRepo extends BaseRepository {
  Future startJourneyAPI(Map<String, dynamic> data) async {
    final response = await postHttp(
      api: ApiUrls.baseUrl + LocationURLs.startJourney,
      data: data,
      token: true,
    );
    log(response.body, name: 'response startJourneyAPI');
    return json.decode(response.body);
  }

  Future updateJourneyAPI(Map<String, dynamic> data, String? journeyId) async {
    String params = '?journey_id=$journeyId';
    final response = await postHttp(
      api: ApiUrls.baseUrl + LocationURLs.updateJourney + params,
      data: data,
      token: true,
    );
    log(response.body, name: 'response updateJourneyAPI');
    return json.decode(response.body);
  }

  Future liveSantAPI() async {
    final response = await getHttp(
      api: ApiUrls.baseUrl + LocationURLs.getLiveSantJourney,
      token: true,
    );
    log(response.body, name: 'response liveSantAPI');
    return json.decode(response.body);
  }

  Future getSantHistoryAPI() async {
    final response = await getHttp(
      api: ApiUrls.baseUrl + LocationURLs.journeyHistory,
      token: true,
    );
    log(response.body, name: 'response getSantHistoryAPI');
    return json.decode(response.body);
  }

  Future getNearbySantPI() async {
    final response = await getHttp(
      api: ApiUrls.baseUrl + LocationURLs.searchSantList,
      token: true,
    );
    log(response.body, name: 'response getNearbySantPI');
    return json.decode(response.body);
  }
}
