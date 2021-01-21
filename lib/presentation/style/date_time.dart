import 'package:intl/intl.dart';

class Date {
  static DateFormat _startFormat = DateFormat('dd.MM.yy');
  static DateFormat _stopFormat = DateFormat('dd.MM.yy HH:mm');

  static String startDate(DateTime date) {
    return _startFormat.format(date);
  }

  static String stopDate(DateTime date) {
    return _stopFormat.format(date);
  }

  static String dateFromInt(int date) {
    final temp = DateTime.fromMillisecondsSinceEpoch(date * 1000);
    return _stopFormat.format(temp);
  }
}
