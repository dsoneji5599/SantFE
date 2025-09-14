extension DateTimeHelper on DateTime {
  String toMonthDDTime() {
    return '${month.intToMonth()} $day, ${toTime()}';
  }

  String toDDMMYYYY() {
    return '$day/${month < 10 ? '0$month' : month}/$year';
  }

  String toDDMMYYYYDash() {
    return '$day-${month < 10 ? '0$month' : month}-$year';
  }

  String toStandard() {
    return '${day.th()} ${month.intToMonth()}, $year';
  }

  String toYYYYMMDD() {
    return '$year-${month < 10 ? '0$month' : month}-${day < 10 ? '0$day' : day}';
  }

  String toTime() {
    int hour0 = hour > 12 ? hour - 12 : hour;
    return '${hour0 < 10 ? '0$hour0' : hour0}:${minute < 10 ? '0$minute' : minute} ${hour < 12 ? 'AM' : 'PM'}';
  }

  String to24() {
    return '$hour:${minute < 10 ? '0$minute' : minute}';
  }

  String toDate() {
    return '$day ${month.intToMonth()}';
  }

  String getCode() {
    return '$day$month$hour$minute';
  }

  String timeLimit() {
    final remaining = DateTime.now().difference(this);
    int days = remaining.inDays;
    int hours = remaining.inHours % 24;
    int minutes = remaining.inMinutes % 60;
    return (days > 0)
        ? 'in $days days'
        : (hours > 0)
        ? 'in $hours hours'
        : (minutes > 0)
        ? 'in $minutes minutes'
        : 'soon';
  }
}

extension IntHelper on int {
  String intToMonth() {
    List<String> months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return months[this - 1];
  }

  String th() {
    final number = toString();
    Map values = {"1": "st", "2": "nd", "3": "rd"};
    final rear =
        (number.length == 1
            ? values[number]
            : ["11", "12", "13"].contains(number)
            ? "th"
            : values[number[1]]) ??
        'th';
    return number + rear;
  }
}

extension StringHelper on String {
  String abbriviate([int limit = 10]) {
    if (length <= limit) return this;
    final list = split(
      ' ',
    ).map((e) => e.substring(0, 1).toUpperCase()).toList();
    return list.join();
  }

  int getExtendedVersionNumber() {
    List versionCells = split('.');
    versionCells = versionCells.map((i) => int.parse(i)).toList();
    return versionCells[0] * 100000 + versionCells[1] * 1000 + versionCells[2];
  }

  bool isValidAadharNumber() {
    return RegExp(r'^[2-9]{1}[0-9]{3}\\s[0-9]{4}\\s[0-9]{4}$').hasMatch(this);
  }
}
