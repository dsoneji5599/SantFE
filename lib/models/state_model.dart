class StateModel {
  final String? stateId;
  final String? state;

  StateModel({this.stateId, this.state});

  factory StateModel.fromJson(Map<String, dynamic> json) =>
      StateModel(stateId: json["state_id"], state: json["state"]);
}
