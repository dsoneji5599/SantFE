class FamilyModel {
  final String? userFamilyId;
  final String? userId;
  final String? name;
  final DateTime? dob;
  final dynamic profileImage;
  final String? qualification;
  final String? occupation;
  final String? natureOfBusiness;
  final String? gachh;
  final String? fatherName;
  final String? motherName;
  final String? spouseName;
  final dynamic dom;
  final String? gender;
  final dynamic children;
  final List<Map<String, dynamic>>? childrenDetails;
  final String? mobile;
  final String? district;
  final String? city;
  final String? state;
  final String? country;

  FamilyModel({
    this.userFamilyId,
    this.userId,
    this.name,
    this.dob,
    this.profileImage,
    this.qualification,
    this.occupation,
    this.natureOfBusiness,
    this.gachh,
    this.fatherName,
    this.motherName,
    this.spouseName,
    this.dom,
    this.gender,
    this.children,
    this.childrenDetails,
    this.mobile,
    this.district,
    this.city,
    this.state,
    this.country,
  });

  factory FamilyModel.fromJson(Map<String, dynamic> json) => FamilyModel(
    userFamilyId: json["user_family_id"],
    userId: json["user_id"],
    name: json["name"],
    dob: json["dob"] == null ? null : DateTime.parse(json["dob"]),
    profileImage: json["profile_image"],
    qualification: json["qualification"],
    occupation: json["occupation"],
    natureOfBusiness: json["nature_of_business"],
    gachh: json["gachh"],
    fatherName: json["father_name"],
    motherName: json["mother_name"],
    spouseName: json["spouse_name"],
    dom: json["dom"] == null ? null : DateTime.parse(json["dom"]),
    gender: json["gender"],
    children: json["children"],
    childrenDetails: json["children_details"] == null
        ? null
        : List<Map<String, dynamic>>.from(
            json["children_details"].map(
              (x) => {
                "child_dob": x["child_dob"],
                "child_name": x["child_name"],
                "child_gender": x["child_gender"],
              },
            ),
          ),
    mobile: json["mobile"],
    district: json["district"],
    city: json["city"],
    state: json["state"],
    country: json["country"],
  );
}
