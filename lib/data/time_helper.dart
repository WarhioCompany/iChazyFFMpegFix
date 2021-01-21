class TimeHelper {
  static DateTime intToDateTime(int dateNumber) {
    return DateTime.fromMillisecondsSinceEpoch(dateNumber * 1000);
  }

  static int dateTimeToInt(DateTime date) {
    return date.millisecondsSinceEpoch ~/ 1000;
  }
}
