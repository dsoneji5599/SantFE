class DistrictModel {
  final String? districtId;
  final String? district;

  DistrictModel({this.districtId, this.district});

  factory DistrictModel.fromJson(Map<String, dynamic> json) => DistrictModel(
    districtId: json["district_id"],
    district: json["district"],
  );
}
