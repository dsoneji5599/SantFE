class EnumValues<E, T> {
  Map<E?, T> map;

  EnumValues(this.map);
}

enum STATUS {
  completed("COMPLETED"),
  pending("PENDING");

  final String val;

  const STATUS(this.val);
}

final getSTATUSEnum = EnumValues({
  "COMPLETED": STATUS.completed,
  "PENDING": STATUS.pending,
  null: STATUS.pending,
});
