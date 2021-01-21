import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ichazy/domain/bloc/switch_bloc.dart';
import 'package:ichazy/domain/model/reply_data.dart';
//import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ichazy/domain/model/stats.dart';
import 'package:ichazy/presentation/colors/colors.dart';
import 'package:ichazy/presentation/registration_screen.dart';

class Like extends StatelessWidget {
  final String applicationId;
  final Stats stats;
  final LikeStatus initValue;

  Like({this.applicationId, this.stats, this.initValue});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        bool value;
        int likes = stats.likes;
        if (initValue == LikeStatus.NOT_SET ||
            initValue == LikeStatus.DISLIKE) {
          value = false;
        } else if (initValue == LikeStatus.LIKE) {
          value = true;
        }
        return SwitchBloc(value, likes);
      },
      child: BlocConsumer<SwitchBloc, SwitchState>(
        listener: (context, state) {
          if (state is LoginSwitchState) _openLoginScreen(context);
        },
        builder: (context, state) {
          return GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: () {
              BlocProvider.of<SwitchBloc>(context).add(ChangeSwitchEvent(
                  value: !BlocProvider.of<SwitchBloc>(context).value,
                  applicationId: applicationId,
                  likes: stats.likes));
            },
            child: Container(
              alignment: Alignment.center,
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                shape: BoxShape.rectangle,
                color: AppColor.MAIN.withOpacity(0.8),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Container(
                color: Colors.transparent,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    BlocProvider.of<SwitchBloc>(context).value
                        ? Image.asset(
                            'assets/icons/png/icon-like-on.png',
                            height: 18,
                          )
                        : Image.asset(
                            'assets/icons/png/icon-like-off.png',
                            height: 18,
                          ),
                    SizedBox(width: 10),
                    Text('${BlocProvider.of<SwitchBloc>(context).likes}',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w300)),
                  ],
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
}
