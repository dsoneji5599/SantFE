class UserProfileModel {
  final String? firebaseUid;
  final String? userId;
  final String? name;
  final DateTime? dob;
  final dynamic profileImage;
  final String? email;
  final String? mobile;
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
  final bool? isActive;
  final bool? isAdmin;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  UserProfileModel({
    this.firebaseUid,
    this.userId,
    this.name,
    this.dob,
    this.profileImage,
    this.email,
    this.mobile,
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
    this.isActive,
    this.isAdmin,
    this.createdAt,
    this.updatedAt,
  });

  factory UserProfileModel.fromJson(Map<String, dynamic> json) =>
      UserProfileModel(
        firebaseUid: json["firebase_uid"],
        userId: json["user_id"],
        name: json["name"],
        dob: json["dob"] == null ? null : DateTime.parse(json["dob"]),
        profileImage: json["profile_image"],
        email: json["email"],
        mobile: json["mobile"],
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
        isActive: json["is_active"],
        isAdmin: json["is_admin"],
        createdAt: json["created_at"] == null
            ? null
            : DateTime.parse(json["created_at"]),
        updatedAt: json["updated_at"] == null
            ? null
            : DateTime.parse(json["updated_at"]),
      );
}
