class SantListModel {
  final String? firebaseUid;
  final String? saintId;
  final String? name;
  final String? email;
  final String? mobile;
  final dynamic profileImage;
  final String? gender;
  final DateTime? dob;
  final String? salutation;
  final String? sampraday;
  final String? upadhi;
  final String? sangh;
  final String? dikshaPlace;
  final DateTime? dikshaDate;
  final String? tapasyaDetails;
  final String? knowledgeDetails;
  final String? viharDetails;
  final String? samaj;
  final String? samajName;
  final String? district;
  final String? districtName;
  final String? city;
  final String? cityName;
  final String? state;
  final String? stateName;
  final String? country;
  final String? countryName;
  final Extra? extra;
  final bool? isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final bool? isBookmarked;
  final String? bookmarkId;

  final String? approvalStatus;
  final CurrentLocation? currentLocation;

  SantListModel({
    this.firebaseUid,
    this.saintId,
    this.name,
    this.email,
    this.mobile,
    this.profileImage,
    this.gender,
    this.dob,
    this.salutation,
    this.sampraday,
    this.upadhi,
    this.sangh,
    this.dikshaPlace,
    this.dikshaDate,
    this.tapasyaDetails,
    this.knowledgeDetails,
    this.viharDetails,
    this.samaj,
    this.samajName,
    this.district,
    this.districtName,
    this.city,
    this.cityName,
    this.state,
    this.stateName,
    this.country,
    this.countryName,
    this.extra,
    this.isActive,
    this.createdAt,
    this.updatedAt,
    this.isBookmarked,
    this.bookmarkId,
    this.approvalStatus,
    this.currentLocation,
  });

  factory SantListModel.fromJson(Map<String, dynamic> json) => SantListModel(
    firebaseUid: json["firebase_uid"],
    saintId: json["saint_id"],
    name: json["name"],
    email: json["email"],
    mobile: json["mobile"],
    profileImage: json["profile_image"],
    gender: json["gender"],
    dob: json["dob"] == null ? null : DateTime.parse(json["dob"]),
    salutation: json["salutation"],
    sampraday: json["sampraday"],
    upadhi: json["upadhi"],
    sangh: json["sangh"],
    dikshaPlace: json["diksha_place"],
    dikshaDate: json["diksha_date"] == null
        ? null
        : DateTime.parse(json["diksha_date"]),
    tapasyaDetails: json["tapasya_details"],
    knowledgeDetails: json["knowledge_details"],
    viharDetails: json["vihar_details"],
    samaj: json["samaj"],
    samajName: json["samaj_name"],
    district: json["district"],
    districtName: json["district_name"],
    city: json["city"],
    cityName: json["city_name"],
    state: json["state"],
    stateName: json["state_name"],
    country: json["country"],
    countryName: json["country_name"],
    extra: json["extra"] == null ? null : Extra.fromJson(json["extra"]),
    isActive: json["is_active"],
    createdAt: json["created_at"] == null
        ? null
        : DateTime.parse(json["created_at"]),
    updatedAt: json["updated_at"] == null
        ? null
        : DateTime.parse(json["updated_at"]),
    isBookmarked: json["is_bookmarked"],
    bookmarkId: json["bookmark_id"],
    approvalStatus: json["approval_status"],
    currentLocation: json["current_location"] == null
        ? null
        : CurrentLocation.fromJson(json["current_location"]),
  );
}

class CurrentLocation {
  final double? latitude;
  final double? longitude;

  CurrentLocation({this.latitude, this.longitude});

  factory CurrentLocation.fromJson(Map<String, dynamic> json) {
    return CurrentLocation(
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
    'latitude': latitude,
    'longitude': longitude,
  };
}

class Extra {
  Extra();

  factory Extra.fromJson(Map<String, dynamic> json) => Extra();

  Map<String, dynamic> toJson() => {};
}
