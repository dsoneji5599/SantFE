import 'dart:convert';
import 'dart:developer';

import 'package:sant_app/repositories/base_repo.dart';
import 'package:sant_app/utils/app_urls.dart';

class SantRepo extends BaseRepository {
  Future getSantApi(Map<String, dynamic> data, int offset) async {
    String params = '?limit=10&offset=$offset';

    final response = await postHttp(
      data: data,
      api: ApiUrls.baseUrl + SantUrls.getSant + params,
      token: true,
    );
    log(response.body, name: 'response getSantApi');
    return json.decode(response.body);
  }

  Future getSavedSantApi() async {
    final response = await getHttp(
      api: ApiUrls.baseUrl + Bookmark.getSavedSant,
      token: true,
    );
    log(response.body, name: 'response getSavedSantApi');
    return json.decode(response.body);
  }

  Future addBookmarkApi(String santId) async {
    String params = '?saint_id=$santId';
    final response = await postHttp(
      api: ApiUrls.baseUrl + Bookmark.addBookmark + params,
      data: {},
      token: true,
    );
    log(response.body, name: 'response addBookmarkApi');
    return json.decode(response.body);
  }

  Future removeBookmarkApi(String bookmarkId) async {
    String params = '?bookmark_id=$bookmarkId';
    final response = await postHttp(
      api: ApiUrls.baseUrl + Bookmark.removeBookmark + params,
      data: {},
      token: true,
    );
    log(response.body, name: 'response removeBookmarkApi');
    return json.decode(response.body);
  }
}
