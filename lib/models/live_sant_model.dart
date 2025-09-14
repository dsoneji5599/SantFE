class LiveSantJourneyModel {
  final String? journeyId;
  final String? saintId;
  final double? startLatitude;
  final double? startLongitude;
  final double? endLatitude;
  final double? endLongitude;
  final DateTime? startDate;
  final DateTime? endDate;
  final double? currentLatitude;
  final double? currentLongitude;
  final String? currentCity;
  final String? currentState;
  final String? currentCountry;
  final String? journeyStatus;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  LiveSantJourneyModel({
    this.journeyId,
    this.saintId,
    this.startLatitude,
    this.startLongitude,
    this.endLatitude,
    this.endLongitude,
    this.startDate,
    this.endDate,
    this.currentLatitude,
    this.currentLongitude,
    this.currentCity,
    this.currentState,
    this.currentCountry,
    this.journeyStatus,
    this.createdAt,
    this.updatedAt,
  });

  factory LiveSantJourneyModel.fromJson(Map<String, dynamic> json) =>
      LiveSantJourneyModel(
        journeyId: json["journey_id"],
        saintId: json["saint_id"],
        startLatitude: json["start_latitude"]?.toDouble(),
        startLongitude: json["start_longitude"]?.toDouble(),
        endLatitude: json["end_latitude"]?.toDouble(),
        endLongitude: json["end_longitude"]?.toDouble(),
        startDate: json["start_date"] == null
            ? null
            : DateTime.parse(json["start_date"]),
        endDate: json["end_date"] == null
            ? null
            : DateTime.parse(json["end_date"]),
        currentLatitude: json["current_latitude"]?.toDouble(),
        currentLongitude: json["current_longitude"]?.toDouble(),
        currentCity: json["current_city"],
        currentState: json["current_state"],
        currentCountry: json["current_country"],
        journeyStatus: json["journey_status"],
        createdAt: json["created_at"] == null
            ? null
            : DateTime.parse(json["created_at"]),
        updatedAt: json["updated_at"] == null
            ? null
            : DateTime.parse(json["updated_at"]),
      );

  Map<String, dynamic> toJson() => {
    "journey_id": journeyId,
    "saint_id": saintId,
    "start_latitude": startLatitude,
    "start_longitude": startLongitude,
    "end_latitude": endLatitude,
    "end_longitude": endLongitude,
    "start_date": startDate?.toIso8601String(),
    "end_date": endDate?.toIso8601String(),
    "current_latitude": currentLatitude,
    "current_longitude": currentLongitude,
    "current_city": currentCity,
    "current_state": currentState,
    "current_country": currentCountry,
    "journey_status": journeyStatus,
    "created_at": createdAt?.toIso8601String(),
    "updated_at": updatedAt?.toIso8601String(),
  };
}
