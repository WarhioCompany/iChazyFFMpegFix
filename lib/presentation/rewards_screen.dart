import 'package:flutter/material.dart';

import 'colors/colors.dart';
import 'elements/custom_divider.dart';
import 'elements/integrated_rewards_feed_.dart';

class RewardsScreen extends StatefulWidget {
  @override
  _RewardsScreenState createState() => _RewardsScreenState();
}

class _RewardsScreenState extends State<RewardsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _getAppBar(),
      body: SafeArea(
        child: _getBody(),
      ),
    );
  }

  Widget _getAppBar() {
    return AppBar(
      brightness: Brightness.light,
      centerTitle: true,
      title: Text(
        'Награды',
        style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: AppColor.MAIN,
            fontFamily: 'SF'),
      ),
      actions: [
        Container(
          padding: EdgeInsets.all(10),
          margin: EdgeInsets.only(right: 10),
          child: Image.asset(
            'assets/icons/png/logo 1.png',
            filterQuality: FilterQuality.medium,
          ),
        ),
      ],
      shadowColor: Colors.white.withOpacity(0),
      bottom: AppDividerPreferred(),
    );
  }

  Widget _getBody() {
    return IntegratedRewardsFeed(false);
  }
}
