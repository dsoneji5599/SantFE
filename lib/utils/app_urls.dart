class ApiUrls {
  // Local
  // static String baseUrl = "http://192.168.29.238:8000/v1/";

  // STAGING
  static String baseUrl = "http://13.203.160.236:9001/";
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
}

class HomeUrls {
  static String getEvents = 'event/get_events';
  static String getTemples = 'temple/get_temples';
  static String addTemples = 'temple/create_temple';
  static String getFamily = 'temple/get_family_member';
}

class UtilUrls {
  static String country = 'user/country';
  static String state = 'user/state';
  static String city = 'user/city';
  static String district = 'user/district';
  static String samaj = 'user/samaj';
}
