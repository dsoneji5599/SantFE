class SavedSantListModel {
  final String? bookmarkId;
  final String? userId;
  final String? saintId;
  final String? name;
  final dynamic profileImage;
  final String? samajName;
  final String? sampraday;
  final DateTime? createdAt;

  SavedSantListModel({
    required this.bookmarkId,
    required this.userId,
    required this.saintId,
    required this.name,
    required this.profileImage,
    required this.samajName,
    required this.sampraday,
    required this.createdAt,
  });

  factory SavedSantListModel.fromJson(Map<String, dynamic> json) =>
      SavedSantListModel(
        bookmarkId: json["bookmark_id"],
        userId: json["user_id"],
        saintId: json["saint_id"],
        name: json["name"],
        profileImage: json["profile_image"],
        samajName: json["samaj_name"],
        sampraday: json["sampraday"],
        createdAt: json["created_at"] == null
            ? null
            : DateTime.parse(json["created_at"]),
      );
}
