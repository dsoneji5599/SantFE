class ApiUrls {
  // Local
  // static String baseUrl = "http://192.168.29.238:8000/v1/";

  // STAGING
  static String baseUrl = "http://3.109.209.179:9001/";
}

class UserAuthUrls {
  static String login = 'user/login';
  static String register = 'user/register';
  static String checkUserExist = 'user/is_user_exist';
  static String refreshToken = 'user/refresh_token';
}

class SantAuthUrls {
  static String login = 'saint/saint_login';
  static String register = 'saint/saint_register';
  static String checkSantExist = 'saint/is_saint_exist';
}

class UserProfileUrls {
  static String get = 'user/profile';
  static String update = 'user/update_profile';
}

class SantUrls {
  static String getSant = 'saint/get_saint_list';
  static String getSantProfile = 'saint/saint_profile';
  static String update = 'saint/update_saint_profile';
}

class Bookmark {
  static String getSavedSant = 'bookmark/get_bookmarks';
  static String addBookmark = 'bookmark/add_bookmark';
  static String removeBookmark = 'bookmark/remove_bookmark';
}

class HomeUrls {
  static String getEvents = 'event/get_events';
  static String addEvent = 'event/create_event';
  static String editEvent = 'event/edit_event';
  static String getTemples = 'temple/get_temples';
  static String addTemples = 'temple/create_temple';
  static String editTemples = 'temple/edit_temple';
  static String getFamily = 'user_family/get_family_member';
  static String addFamily = 'user_family/add_user_family_member';
}

class LocationURLs {
  static String startJourney = 'saint/start_saint_journey';
  static String updateJourney = 'saint/update_saint_journey';
  static String getLiveSantJourney = 'saint/get_live_saint_journey';
  static String journeyHistory = 'saint/get_saint_journey_history';
  static String searchSantList = 'saint/get_nearby_saint';
}

class UtilUrls {
  static String country = 'user/country';
  static String state = 'user/state';
  static String city = 'user/city';
  static String district = 'user/district';
  static String samaj = 'user/samaj';
}
