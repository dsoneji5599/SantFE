class CityModel {
  final String? cityId;
  final String? city;

  CityModel({this.cityId, this.city});

  factory CityModel.fromJson(Map<String, dynamic> json) =>
      CityModel(cityId: json["city_id"], city: json["city"]);
}
