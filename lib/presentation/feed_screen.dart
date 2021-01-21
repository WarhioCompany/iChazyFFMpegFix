import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ichazy/domain/bloc/feed_main_bloc.dart';
import 'package:ichazy/domain/model/challenge.dart';
import 'package:ichazy/domain/model/user.dart';
import 'package:ichazy/internal/feed_module.dart';
import 'package:ichazy/presentation/account_screen.dart';
import 'package:ichazy/presentation/elements/integrated_feed.dart';
import 'package:ichazy/presentation/registration_screen.dart';
import 'package:ichazy/presentation/rewards_screen.dart';

import 'balance_screen.dart';
import 'elements/balance_button.dart';
import 'elements/custom_divider.dart';

class FeedScreen extends StatefulWidget {
  @override
  _FeedScreenState createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  final _feedMainBloc = FeedModule.feedMainBloc();
  int _balance = 0;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _feedMainBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener(
      cubit: _feedMainBloc,
      listener: (context, state) {
        if (state is FeedMainProfileState) _openProfilePage(state.user);
        if (state is FeedMainRewardsState) _openRewardsPage();
        if (state is FeedMainBalanceState) _openBalancePage();
        if (state is FeedMainLoginState) _openLoginScreen();
      },
      child: Scaffold(
        appBar: _getAppBar(),
        body: _getBody(),
      ),
    );
  }

  Widget _getAppBar() {
    return AppBar(
      brightness: Brightness.light,
      centerTitle: true,
      leading: _getProfile(),
      title: BalanceButton(),
      actions: [_getRewards()],
      shadowColor: Colors.white.withOpacity(0),
      bottom: AppDividerPreferred(),
    );
  }

  Widget _getBody() {
    return IntegratedFeed(Filter.ALL_ACTIVE_BY_REGIONS, User.userDefaultName());
  }

  Widget _getProfile() {
    return Container(
      height: 10,
      padding: EdgeInsets.only(right: 15),
      child: IconButton(
        onPressed: () => _feedMainBloc.add(FeedMainProfileEvent()),
        icon: Image.asset('assets/icons/png/tab-profile-off.png'),
      ),
    );
  }

  Widget _getRewards() {
    return Container(
      margin: EdgeInsets.only(right: 10),
      child: GestureDetector(
        onTap: () => _feedMainBloc.add(FeedMainRewardsEvent()),
        child: Container(
          margin: EdgeInsets.symmetric(vertical: 15),
          height: 32,
          child: Image.asset('assets/icons/png/cup.png'),
        ),
      ),
    );
  }

  _openLoginScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => RegistrationScreen()),
    );
  }

  _openProfilePage(User user) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AccountScreen(user)),
    );
  }

  _openRewardsPage() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => RewardsScreen()),
    );
  }

  _openBalancePage() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => BalanceScreen(_balance)),
    );
  }
}
