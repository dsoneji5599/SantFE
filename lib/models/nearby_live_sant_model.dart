class NearbyLiveSantModel {
  final SaintDetail saintDetail;
  final JourneyDetail journeyDetail;

  NearbyLiveSantModel({required this.saintDetail, required this.journeyDetail});

  factory NearbyLiveSantModel.fromJson(Map<String, dynamic> json) {
    return NearbyLiveSantModel(
      saintDetail: SaintDetail.fromJson(json['saint_detail']),
      journeyDetail: JourneyDetail.fromJson(json['journey_detail']),
    );
  }
}

class SaintDetail {
  final String firebaseUid;
  final String saintId;
  final String name;
  final String email;
  final String mobile;
  final String? profileImage;
  final String gender;
  final String dob;
  final String salutation;
  final String sampraday;
  final String upadhi;
  final String sangh;
  final String dikshaPlace;
  final String dikshaDate;
  final String tapasyaDetails;
  final String knowledgeDetails;
  final String viharDetails;
  final String samaj;
  final String samajName;
  final String district;
  final String districtName;
  final String city;
  final String cityName;
  final String state;
  final String stateName;
  final String country;
  final String countryName;
  final Map<String, dynamic> extra;
  final bool isActive;
  final String createdAt;
  final String updatedAt;
  final bool? isBookmarked;

  SaintDetail({
    required this.firebaseUid,
    required this.saintId,
    required this.name,
    required this.email,
    required this.mobile,
    this.profileImage,
    required this.gender,
    required this.dob,
    required this.salutation,
    required this.sampraday,
    required this.upadhi,
    required this.sangh,
    required this.dikshaPlace,
    required this.dikshaDate,
    required this.tapasyaDetails,
    required this.knowledgeDetails,
    required this.viharDetails,
    required this.samaj,
    required this.samajName,
    required this.district,
    required this.districtName,
    required this.city,
    required this.cityName,
    required this.state,
    required this.stateName,
    required this.country,
    required this.countryName,
    required this.extra,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
    this.isBookmarked,
  });

  factory SaintDetail.fromJson(Map<String, dynamic> json) {
    return SaintDetail(
      firebaseUid: json['firebase_uid'],
      saintId: json['saint_id'],
      name: json['name'],
      email: json['email'],
      mobile: json['mobile'],
      profileImage: json['profile_image'],
      gender: json['gender'],
      dob: json['dob'],
      salutation: json['salutation'],
      sampraday: json['sampraday'],
      upadhi: json['upadhi'],
      sangh: json['sangh'],
      dikshaPlace: json['diksha_place'],
      dikshaDate: json['diksha_date'],
      tapasyaDetails: json['tapasya_details'],
      knowledgeDetails: json['knowledge_details'],
      viharDetails: json['vihar_details'],
      samaj: json['samaj'],
      samajName: json['samaj_name'],
      district: json['district'],
      districtName: json['district_name'],
      city: json['city'],
      cityName: json['city_name'],
      state: json['state'],
      stateName: json['state_name'],
      country: json['country'],
      countryName: json['country_name'],
      extra: Map<String, dynamic>.from(json['extra']),
      isActive: json['is_active'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      isBookmarked: json['is_bookmarked'],
    );
  }
}

class JourneyDetail {
  final String journeyId;
  final String saintId;
  final double startLatitude;
  final double startLongitude;
  final double endLatitude;
  final double endLongitude;
  final String startDate;
  final String? endDate;
  final double currentLatitude;
  final double currentLongitude;
  final String currentCity;
  final String currentState;
  final String currentCountry;
  final String journeyStatus;
  final String createdAt;
  final String updatedAt;

  JourneyDetail({
    required this.journeyId,
    required this.saintId,
    required this.startLatitude,
    required this.startLongitude,
    required this.endLatitude,
    required this.endLongitude,
    required this.startDate,
    this.endDate,
    required this.currentLatitude,
    required this.currentLongitude,
    required this.currentCity,
    required this.currentState,
    required this.currentCountry,
    required this.journeyStatus,
    required this.createdAt,
    required this.updatedAt,
  });

  factory JourneyDetail.fromJson(Map<String, dynamic> json) {
    return JourneyDetail(
      journeyId: json['journey_id'],
      saintId: json['saint_id'],
      startLatitude: json['start_latitude'].toDouble(),
      startLongitude: json['start_longitude'].toDouble(),
      endLatitude: json['end_latitude'].toDouble(),
      endLongitude: json['end_longitude'].toDouble(),
      startDate: json['start_date'],
      endDate: json['end_date'],
      currentLatitude: json['current_latitude'].toDouble(),
      currentLongitude: json['current_longitude'].toDouble(),
      currentCity: json['current_city'],
      currentState: json['current_state'],
      currentCountry: json['current_country'],
      journeyStatus: json['journey_status'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }
}
