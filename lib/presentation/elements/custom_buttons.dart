import 'package:flutter/material.dart';

class AppButtons {
  static Widget circleButton(String text, VoidCallback voidCallback, Color color, double width) {
    return Ink(
      height: 50,
      width: width,
      decoration: const ShapeDecoration(
        //color: AppColor.LIGHT_BLUE2,
        shape: RoundedRectangleBorder(),
      ),
      child: RaisedButton(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(40),
        ),
        color: color,
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        onPressed: voidCallback,
        child: Text(
          text,
          style: TextStyle(
              fontFamily: 'Montserrat',
              fontSize: 16,
              color: Colors.white,
              fontWeight: FontWeight.w300
          ),
        ),
      ),
    );
  }
}