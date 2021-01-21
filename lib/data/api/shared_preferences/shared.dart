import 'package:shared_preferences/shared_preferences.dart';

class Preferences {
  static final Preferences _singleton = new Preferences._internal();

  SharedPreferences _sharedPreferences;

  factory Preferences() {
    return _singleton;
  }

  Preferences._internal();


  Future<void> init() async {
    this._sharedPreferences = await SharedPreferences.getInstance();
  }

  SharedPreferences get getInstance => _sharedPreferences;
}