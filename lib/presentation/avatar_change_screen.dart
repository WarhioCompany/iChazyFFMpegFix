import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ichazy/domain/bloc/avatar_change_bloc.dart';
import 'package:ichazy/domain/model/user.dart';
import 'package:ichazy/internal/avatar_change_module.dart';
import 'package:ichazy/presentation/registration_screen.dart';

import 'colors/colors.dart';
import 'elements/custom_divider.dart';

class AvatarChangeScreen extends StatelessWidget {
  final User user;

  AvatarChangeScreen(this.user);

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
        'Фото профиля',
        style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: AppColor.MAIN,
            fontFamily: 'SF'),
      ),
      shadowColor: Colors.white.withOpacity(0),
      bottom: AppDividerPreferred(),
    );
  }

  Widget _getBody() {
    var bloc = AvatarChangeModule.avatarChangeBloc();
    return BlocProvider<AvatarChangeBloc>(
      create: (context) {
        return bloc;
      },
      child: BlocConsumer(
        listener: (context, state) {
          if (state is AvatarLoginScreenState) _openLoginScreen(context);
        },
        builder: (context, state) {
          if (state is AvatarChangeRefreshState) {
            return _getAvatar(state.user, () {
              bloc.add(AvatarChangeCallEvent());
            });
          }
          return _getAvatar(user, () {
            bloc.add(AvatarChangeCallEvent());
          });
        },
      ),
    );
  }

  Widget _getAvatar(User user, VoidCallback voidCallback) {
    if (user.avatarId != null || user.avatarId == '') {
      return Ink(
        child: GestureDetector(
          onTap: voidCallback,
          child: FutureBuilder<Image>(
              future: user.getProfileImage(),
              builder: (context, AsyncSnapshot<Image> snapshot) {
                if (snapshot.connectionState == ConnectionState.done ||
                    snapshot.hasData) {
                  return CircleAvatar(
                    backgroundColor: Colors.white,
                    radius: 100,
                    child: ClipOval(
                      child: snapshot.data,
                    ),
                  );
                } else {
                  return CircularProgressIndicator();
                }
              }),
        ),
      );
    } else {
      return Ink(
        child: GestureDetector(
          onTap: voidCallback,
          child: Container(
            margin: EdgeInsets.symmetric(vertical: 15),
            height: 110,
            child: GestureDetector(
              onTap: () {},
              child: Image.asset('assets/icons/png/tab-profile-off.png'),
            ),
          ),
        ),
      );
    }
  }

  void _openLoginScreen(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => RegistrationScreen()),
    );
  }
}
