class SamajModel {
  final String? samajId;
  final String? samajName;

  SamajModel({this.samajId, this.samajName});

  factory SamajModel.fromJson(Map<String, dynamic> json) =>
      SamajModel(samajId: json["samaj_id"], samajName: json["samaj_name"]);
}
