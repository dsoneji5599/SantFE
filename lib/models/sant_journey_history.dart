class SantJourneyHistoryModel {
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

  SantJourneyHistoryModel({
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

  factory SantJourneyHistoryModel.fromJson(Map<String, dynamic> json) =>
      SantJourneyHistoryModel(
        journeyId: json["journey_id"] as String?,
        saintId: json["saint_id"] as String?,
        startLatitude: (json["start_latitude"] as num?)?.toDouble(),
        startLongitude: (json["start_longitude"] as num?)?.toDouble(),
        endLatitude: (json["end_latitude"] as num?)?.toDouble(),
        endLongitude: (json["end_longitude"] as num?)?.toDouble(),
        startDate: json["start_date"] != null
            ? DateTime.tryParse(json["start_date"])
            : null,
        endDate: json["end_date"] != null
            ? DateTime.tryParse(json["end_date"])
            : null,
        currentLatitude: (json["current_latitude"] as num?)?.toDouble(),
        currentLongitude: (json["current_longitude"] as num?)?.toDouble(),
        currentCity: json["current_city"] as String?,
        currentState: json["current_state"] as String?,
        currentCountry: json["current_country"] as String?,
        journeyStatus: json["journey_status"] as String?,
        createdAt: json["created_at"] != null
            ? DateTime.tryParse(json["created_at"])
            : null,
        updatedAt: json["updated_at"] != null
            ? DateTime.tryParse(json["updated_at"])
            : null,
      );
}
