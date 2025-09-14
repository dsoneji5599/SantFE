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

var a = {
  "status_code": 200,
  "message": "Saint Journey Fetched Successfully",
  "data": [
    {
      "journey_id": "c19f77c4-2181-4a1c-9afa-44783b510dce",
      "saint_id": "36baa4d8-b5ee-4ec5-b613-2a7038b9740e",
      "start_latitude": 37.4219983,
      "start_longitude": -122.084,
      "end_latitude": 37.4248437631571,
      "end_longitude": -122.10129339247942,
      "start_date": "2025-09-15T01:41:55.460569",
      "end_date": "2025-09-15T01:41:55.462108",
      "current_latitude": 37.4219983,
      "current_longitude": -122.084,
      "current_city": "Mountain View",
      "current_state": "California",
      "current_country": "United States",
      "journey_status": "completed",
      "created_at": "2025-09-14T20:10:36.916586",
      "updated_at": "2025-09-14T20:10:36.916586",
    },
    {
      "journey_id": "c9935d7d-b612-487c-8ae9-04bdc146f2f8",
      "saint_id": "36baa4d8-b5ee-4ec5-b613-2a7038b9740e",
      "start_latitude": 23.053196211464403,
      "start_longitude": 72.66285226862482,
      "end_latitude": 20.905701491639032,
      "end_longitude": 70.38454378493041,
      "start_date": "2025-09-07T01:00:00",
      "end_date": "2025-09-21T12:30:00",
      "current_latitude": 23.053196211464403,
      "current_longitude": 72.66285226862482,
      "current_city": "ahmedabad",
      "current_state": "gujarat",
      "current_country": "india",
      "journey_status": "completed",
      "created_at": "2025-09-14T19:54:36.473827",
      "updated_at": "2025-09-14T19:54:36.473827",
    },
    {
      "journey_id": "64d32bf1-1c13-4211-82f0-c9290eba6dda",
      "saint_id": "36baa4d8-b5ee-4ec5-b613-2a7038b9740e",
      "start_latitude": 23.053196211464403,
      "start_longitude": 72.66285226862482,
      "end_latitude": 20.905701491639032,
      "end_longitude": 70.38454378493041,
      "start_date": "2025-09-07T01:00:00",
      "end_date": "2025-09-21T12:30:00",
      "current_latitude": 23.053196211464403,
      "current_longitude": 72.66285226862482,
      "current_city": "ahmedabad",
      "current_state": "gujarat",
      "current_country": "india",
      "journey_status": "completed",
      "created_at": "2025-09-14T19:53:07.339862",
      "updated_at": "2025-09-14T19:53:07.339862",
    },
    {
      "journey_id": "11d945ba-877d-451d-9d42-1ef02fd192e8",
      "saint_id": "36baa4d8-b5ee-4ec5-b613-2a7038b9740e",
      "start_latitude": 37.4219983,
      "start_longitude": -122.084,
      "end_latitude": 37.40290552445945,
      "end_longitude": -122.09693010896444,
      "start_date": "2025-09-15T01:24:14.033547",
      "end_date": "2025-09-15T01:24:14.033897",
      "current_latitude": 37.4219983,
      "current_longitude": -122.084,
      "current_city": "Mountain View",
      "current_state": "California",
      "current_country": "United States",
      "journey_status": "completed",
      "created_at": "2025-09-14T19:49:42.865362",
      "updated_at": "2025-09-14T19:49:42.865362",
    },
    {
      "journey_id": "e3022780-a5a2-43e0-ba68-319a2a13ca27",
      "saint_id": "36baa4d8-b5ee-4ec5-b613-2a7038b9740e",
      "start_latitude": 23.053196211464403,
      "start_longitude": 72.66285226862482,
      "end_latitude": 20.905701491639032,
      "end_longitude": 70.38454378493041,
      "start_date": "2025-09-07T01:00:00",
      "end_date": "2025-09-21T12:30:00",
      "current_latitude": 23.053196211464403,
      "current_longitude": 72.66285226862482,
      "current_city": "ahmedabad",
      "current_state": "gujarat",
      "current_country": "india",
      "journey_status": "completed",
      "created_at": "2025-09-14T19:41:51.313011",
      "updated_at": "2025-09-14T19:41:51.313011",
    },
    {
      "journey_id": "7c050ba0-b764-42c8-9762-ef2f2292aef5",
      "saint_id": "36baa4d8-b5ee-4ec5-b613-2a7038b9740e",
      "start_latitude": 23.053196211464403,
      "start_longitude": 72.66285226862482,
      "end_latitude": 20.905701491639032,
      "end_longitude": 70.38454378493041,
      "start_date": "2025-09-07T01:00:00",
      "end_date": "2025-09-21T12:30:00",
      "current_latitude": 23.053196211464403,
      "current_longitude": 72.66285226862482,
      "current_city": "ahmedabad",
      "current_state": "gujarat",
      "current_country": "india",
      "journey_status": "completed",
      "created_at": "2025-09-14T19:40:04.320034",
      "updated_at": "2025-09-14T19:40:04.320034",
    },
    {
      "journey_id": "5f79c282-4198-4c68-ae98-74c0a59e690f",
      "saint_id": "36baa4d8-b5ee-4ec5-b613-2a7038b9740e",
      "start_latitude": 23.053196211464403,
      "start_longitude": 72.66285226862482,
      "end_latitude": 20.905701491639032,
      "end_longitude": 70.38454378493041,
      "start_date": "2025-09-07T01:00:00",
      "end_date": "2025-09-21T12:30:00",
      "current_latitude": 23.053196211464403,
      "current_longitude": 72.66285226862482,
      "current_city": "ahmedabad",
      "current_state": "gujarat",
      "current_country": "india",
      "journey_status": "completed",
      "created_at": "2025-09-14T19:19:58.015763",
      "updated_at": "2025-09-14T19:19:58.015763",
    },
    {
      "journey_id": "6c0338df-df22-4e9f-8b51-f638aa8c60ff",
      "saint_id": "36baa4d8-b5ee-4ec5-b613-2a7038b9740e",
      "start_latitude": 37.4219983,
      "start_longitude": -122.084,
      "end_latitude": 37.450327422880804,
      "end_longitude": -122.13966708630322,
      "start_date": "2025-09-12T17:59:29.912311",
      "end_date": null,
      "current_latitude": 37.4219983,
      "current_longitude": -122.084,
      "current_city": "Mountain View",
      "current_state": "California",
      "current_country": "United States",
      "journey_status": "completed",
      "created_at": "2025-09-12T12:29:30.281119",
      "updated_at": "2025-09-12T12:29:30.281119",
    },
    {
      "journey_id": "8ab1fa2f-489b-4204-b098-acd9530c818c",
      "saint_id": "36baa4d8-b5ee-4ec5-b613-2a7038b9740e",
      "start_latitude": 23.053196211464403,
      "start_longitude": 72.66285226862482,
      "end_latitude": 20.905701491639032,
      "end_longitude": 70.38454378493041,
      "start_date": "2025-09-07T01:00:00",
      "end_date": "2025-09-21T12:30:00",
      "current_latitude": 23.053196211464403,
      "current_longitude": 72.66285226862482,
      "current_city": "ahmedabad",
      "current_state": "gujarat",
      "current_country": "india",
      "journey_status": "completed",
      "created_at": "2025-09-12T12:06:53.338392",
      "updated_at": "2025-09-12T12:06:53.338392",
    },
  ],
};
