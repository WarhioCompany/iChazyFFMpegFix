import 'dart:math';

import 'package:flutter/material.dart';

class AppColor {
  static Color generate() {
    Random random = Random();
    return Color.fromARGB(255, random.nextInt(256), random.nextInt(256), random.nextInt(256));
  }

  static const Color BLUE = Color.fromRGBO(153, 204, 235, 1); // rgb(153, 204, 235);
  static const Color DARK_BLUE = Color.fromRGBO(18, 50, 76, 1); // rgb(18, 50, 76);
  static const Color CYAN = Color.fromRGBO(161, 255, 222, 1); // rgb(161, 255, 222);
  static const Color ORANGE2 = Color.fromRGBO(255, 150, 46, 1); // rgb(255, 150, 46);
  static const Color MAIN = Color.fromRGBO(28, 63, 78, 1); // rgb(255, 150, 46);
  static const Color DARK_BLUE2 = Color.fromRGBO(0, 64, 97, 1); // rgb(255, 150, 46);
  static const Color DARK_BLUE2_OPACITY = Color.fromRGBO(0, 64, 97, 0.8);
  static const Color BLUE2 = Color.fromRGBO(93, 132, 195, 1); // rgb(255, 150, 46);
  static const Color BLUE2_OPACITY = Color.fromRGBO(93, 132, 195, 0.8);
  static const Color LIGHT_BLUE = Color.fromRGBO(181, 242, 237, 1); // rgb(181, 242, 237);
  static const Color LIGHT_BLUE2 = Color.fromRGBO(171, 217, 233, 1); // rgb(255, 150, 46);
  static const Color LIGHT_BLUE3 = Color.fromRGBO(179, 216, 231, 1); // rgb(255, 150, 46);
  static const Color LIGHT_BLUE4 = Color.fromRGBO(154, 213, 221, 1); // rgb(157,216,223);
  static const Color ORANGE = Color.fromRGBO(249, 157, 46, 1); // rgb(255, 150, 46);
  static const Color ORANGE3 = Color.fromRGBO(238, 158, 76, 1); // rgb(255, 150, 46);
  static const Color GRAY = Color.fromRGBO(226, 226, 226, 1); // rgb(255, 150, 46);
  static const Color TEXT_GRAY = Color.fromRGBO(176, 177, 177, 1); // rgb(255, 150, 46);
  static const Color TITLE_TEXT_GRAY = Color.fromRGBO(121, 121, 121, 1); //rgb(121, 121, 121);
  static const Color BACKGROUND_GRAY = Color.fromRGBO(248, 249, 251, 1); // rgb(255, 150, 46);
  static const Color GREEN = Color.fromRGBO(33, 190, 136, 1); // rgb(255, 150, 46);

}

// red: '#e00000',
// green: '#33, 190, 136',