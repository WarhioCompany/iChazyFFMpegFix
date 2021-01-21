import 'package:flutter/material.dart';
import 'package:ichazy/presentation/colors/colors.dart';

class AppTheme {
  static ThemeData appTheme = ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: Colors.white,
    primaryColor: AppColor.DARK_BLUE,
    accentColor: AppColor.ORANGE,
    fontFamily: 'Montserrat',
    appBarTheme: AppBarTheme(
      color: Colors.white,
      textTheme: TextTheme(headline6: TextStyle(color: Colors.black)),
      iconTheme: IconThemeData(
        color: AppColor.LIGHT_BLUE2,
      )
    ),
    //visualDensity: VisualDensity.adaptivePlatformDensity,
    // textTheme: TextTheme(
    //
    // ),
  );
}