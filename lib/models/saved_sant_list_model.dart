class SavedSantListModel {
  final String? bookmarkId;
  final String? userId;
  final String? saintId;
  final String? firebaseUid;
  final String? name;
  final dynamic profileImage;
  final String? email;
  final String? mobile;
  final String? gender;
  final String? salutation;
  final String? samajName;
  final String? sampraday;
  final String? upadhi;
  final String? sangh;
  final String? dikshaPlace;
  final String? dikshaDate;
  final DateTime? dob;
  final String? tapasyaDetails;
  final String? knowledgeDetails;
  final String? viharDetails;
  final DateTime? createdAt;

  SavedSantListModel({
    required this.bookmarkId,
    required this.userId,
    required this.saintId,
    this.firebaseUid,
    required this.name,
    required this.profileImage,
    this.email,
    this.mobile,
    this.gender,
    this.salutation,
    required this.samajName,
    required this.sampraday,
    this.upadhi,
    this.sangh,
    this.dikshaPlace,
    this.dikshaDate,
    this.dob,
    this.tapasyaDetails,
    this.knowledgeDetails,
    this.viharDetails,
    required this.createdAt,
  });

  factory SavedSantListModel.fromJson(Map<String, dynamic> json) =>
      SavedSantListModel(
        bookmarkId: json["bookmark_id"],
        userId: json["user_id"],
        saintId: json["saint_id"],
        firebaseUid: json["firebase_uid"],
        name: json["name"],
        profileImage: json["profile_image"],
        email: json["email"],
        mobile: json["mobile"],
        gender: json["gender"],
        salutation: json["salutation"],
        samajName: json["samaj_name"],
        sampraday: json["sampraday"],
        upadhi: json["upadhi"],
        sangh: json["sangh"],
        dikshaPlace: json["diksha_place"],
        dikshaDate: json["diksha_date"],
        dob: json["dob"] == null ? null : DateTime.parse(json["dob"]),
        tapasyaDetails: json["tapasya_details"],
        knowledgeDetails: json["knowledge_details"],
        viharDetails: json["vihar_details"],
        createdAt: json["created_at"] == null
            ? null
            : DateTime.parse(json["created_at"]),
      );
}
