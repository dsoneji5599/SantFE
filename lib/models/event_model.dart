class EventModel {
  final String? eventId;
  final String? name;
  final DateTime? eventDate;
  final String? description;
  final dynamic imagePath;
  final bool? isActive;

  EventModel({
    this.eventId,
    this.name,
    this.eventDate,
    this.description,
    this.imagePath,
    this.isActive,
  });

  factory EventModel.fromJson(Map<String, dynamic> json) => EventModel(
    eventId: json["event_id"],
    name: json["name"],
    eventDate: json["event_date"] == null
        ? null
        : DateTime.parse(json["event_date"]),
    description: json["description"],
    imagePath: json["image_path"],
    isActive: json["is_active"],
  );
}
