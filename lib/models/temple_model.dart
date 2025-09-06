class TempleModel {
  final String? templeId;
  final String? name;
  final String? type;
  final String? description;
  final dynamic imagePath;

  TempleModel({
    this.templeId,
    this.name,
    this.type,
    this.description,
    this.imagePath,
  });

  factory TempleModel.fromJson(Map<String, dynamic> json) => TempleModel(
    templeId: json["temple_id"],
    name: json["name"],
    type: json["type"],
    description: json["description"],
    imagePath: json["image_path"],
  );
}
