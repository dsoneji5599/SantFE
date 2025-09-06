class CountryModel {
  final String? countryId;
  final String? country;

  CountryModel({this.countryId, this.country});

  factory CountryModel.fromJson(Map<String, dynamic> json) =>
      CountryModel(countryId: json["country_id"], country: json["country"]);
}
