import 'package:flutter/material.dart';
import 'package:ichazy/presentation/colors/colors.dart';

class AppDivider extends Divider {
  @override
  Color get color => AppColor.LIGHT_BLUE2;
  @override
  double get thickness => 1;
  @override
  double get height => 1;
}

class AppDividerPreferred extends AppDivider implements PreferredSizeWidget {
  @override
  Size get preferredSize => Size.fromHeight(height);
}