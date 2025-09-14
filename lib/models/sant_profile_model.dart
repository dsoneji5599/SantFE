class SantProfileModel {
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

    SantProfileModel({
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
    });

    factory SantProfileModel.fromJson(Map<String, dynamic> json) => SantProfileModel(
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
        dikshaDate: json["diksha_date"] == null ? null : DateTime.parse(json["diksha_date"]),
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
        createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
        updatedAt: json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
    );

    Map<String, dynamic> toJson() => {
        "firebase_uid": firebaseUid,
        "saint_id": saintId,
        "name": name,
        "email": email,
        "mobile": mobile,
        "profile_image": profileImage,
        "gender": gender,
        "dob": "${dob!.year.toString().padLeft(4, '0')}-${dob!.month.toString().padLeft(2, '0')}-${dob!.day.toString().padLeft(2, '0')}",
        "salutation": salutation,
        "sampraday": sampraday,
        "upadhi": upadhi,
        "sangh": sangh,
        "diksha_place": dikshaPlace,
        "diksha_date": "${dikshaDate!.year.toString().padLeft(4, '0')}-${dikshaDate!.month.toString().padLeft(2, '0')}-${dikshaDate!.day.toString().padLeft(2, '0')}",
        "tapasya_details": tapasyaDetails,
        "knowledge_details": knowledgeDetails,
        "vihar_details": viharDetails,
        "samaj": samaj,
        "samaj_name": samajName,
        "district": district,
        "district_name": districtName,
        "city": city,
        "city_name": cityName,
        "state": state,
        "state_name": stateName,
        "country": country,
        "country_name": countryName,
        "extra": extra?.toJson(),
        "is_active": isActive,
        "created_at": createdAt?.toIso8601String(),
        "updated_at": updatedAt?.toIso8601String(),
    };
}

class Extra {
    Extra();

    factory Extra.fromJson(Map<String, dynamic> json) => Extra(
    );

    Map<String, dynamic> toJson() => {
    };
}
