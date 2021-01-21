
import 'package:ichazy/data/util.dart';

class UtilModule {
  static Util _util;
  static Util util() {
    if (_util == null) {
      _util = Util();
    }
    return _util;
  }
}