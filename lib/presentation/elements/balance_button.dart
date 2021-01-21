import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ichazy/domain/bloc/balance_cubit.dart';
import 'package:ichazy/presentation/colors/colors.dart';
import 'package:ichazy/presentation/registration_screen.dart';

import '../balance_screen.dart';

class BalanceButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider<BalanceCubit>(
      create: (context) {
        return BalanceCubit()..init();
      },
      child: BlocConsumer<BalanceCubit, BalanceState>(
        listener: (context, state) async {
          print(state);
          if (state is OpenLoginState) _openLoginScreen(context);
          if (state is OpenBalanceState)
            _openBalanceScreen(
                context, BlocProvider.of<BalanceCubit>(context).balanceValue);
        },
        builder: (context, state) {
          return Container(
            child: Ink(
              decoration: const ShapeDecoration(
                shape: RoundedRectangleBorder(),
              ),
              child: RaisedButton.icon(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
                color: AppColor.ORANGE3,
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                onPressed: () async =>
                    BlocProvider.of<BalanceCubit>(context).openBalanceScreen(),
                icon: Image.asset(
                  'assets/icons/png/coins.png',
                  color: Colors.white,
                  height: 25,
                  filterQuality: FilterQuality.medium,
                ),
                label: Text(
                  '${BlocProvider.of<BalanceCubit>(context).balanceValue}',
                  style: TextStyle(
                      fontFamily: 'SF',
                      fontSize: 20,
                      color: Colors.white,
                      fontWeight: FontWeight.w300),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _openLoginScreen(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => RegistrationScreen()),
    );
  }

  void _openBalanceScreen(BuildContext context, int balanceValue) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => BalanceScreen(balanceValue)),
    );
  }
}
