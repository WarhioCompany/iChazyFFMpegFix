class AgeCount {
  static int _minAge = 18;
  static int countAge(DateTime dateTime) {
    DateTime today = DateTime.now();
    final int age = today.year - dateTime.year;
    return age;
  }

  static DateTime lastDate() {
    DateTime today = DateTime.now();
    DateTime age = DateTime(today.year - _minAge);

    //DateTime lastDate = DateTime.fromMillisecondsSinceEpoch(today.millisecondsSinceEpoch - age.millisecondsSinceEpoch);
    return age;
  }
}
