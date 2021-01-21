import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ichazy/domain/bloc/restore_password_cubit.dart';

import 'colors/colors.dart';

class RestorePasswordScreen extends StatefulWidget {
  @override
  _RestorePasswordScreenState createState() => _RestorePasswordScreenState();
}

class _RestorePasswordScreenState extends State<RestorePasswordScreen> {
  TextEditingController _emailController;
  RestorePasswordCubit _restoreCubit;

  @override
  void initState() {
    super.initState();
    _restoreCubit = RestorePasswordCubit();
    _emailController = TextEditingController();
    _emailController.addListener(() {
      if (_emailController.text != null && _emailController.text.length > 0) {
        _restoreCubit.switchState(true);
      } else
        _restoreCubit.switchState(false);
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<RestorePasswordCubit, RestorePasswordState>(
      listener: (context, state) {
        if (state is ShowRestoreMessageState)
          Flushbar(
            backgroundColor: AppColor.DARK_BLUE2,
            message: state.message,
            isDismissible: true,
            duration: Duration(seconds: 3),
            dismissDirection: FlushbarDismissDirection.HORIZONTAL,
          )..show(context);
      },
      cubit: _restoreCubit,
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          elevation: 0,
          title: _getTitle(),
        ),
        body: SafeArea(
          child: _getBody(),
        ),
      ),
    );
  }

  Widget _getBody() {
    return SingleChildScrollView(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 25),
        child: Column(
          children: [
            SizedBox(
              height: 25,
            ),
            _getRegisterForm(),
          ],
        ),
      ),
    );
  }

  Widget _getTitle() {
    return Text(
      'Восстановление пароля',
      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
    );
  }

  Widget _getRegisterForm() {
    return Column(
      children: [
        SizedBox(
          height: 20,
        ),
        TextField(
          autofocus: true,
          keyboardType: TextInputType.emailAddress,
          cursorColor: AppColor.ORANGE,
          controller: _emailController,
          decoration: InputDecoration(
            filled: false,
            fillColor: Colors.grey[200],
            contentPadding:
                EdgeInsets.symmetric(vertical: 5.0, horizontal: 22.0),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide: BorderSide(
                color: Colors.grey[200],
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide: BorderSide(
                color: AppColor.ORANGE,
              ),
            ),
            labelText: 'Email *',
            //labelStyle: TextStyle(color: AppColor.ORANGE),
          ),
        ),
        SizedBox(
          height: 20,
        ),
        _getRegisterButton(),
        SizedBox(
          height: 30,
        ),
        _getLoginButton(),
      ],
    );
  }

  Widget _getRegisterButton() {
    return BlocBuilder<RestorePasswordCubit, RestorePasswordState>(
      cubit: _restoreCubit,
      builder: (context, state) {
        if (_restoreCubit.filled) {
          return InkWell(
            onTap: () async {
              _restoreCubit.send(_emailController.text);
            },
            child: Row(
              children: [
                Spacer(),
                Container(
                  alignment: Alignment.center,
                  height: 50,
                  padding: EdgeInsets.symmetric(horizontal: 26),
                  decoration: BoxDecoration(
                    shape: BoxShape.rectangle,
                    color: AppColor.ORANGE3,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Text(
                    'Отправить',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.white),
                  ),
                ),
                Spacer(),
              ],
            ),
          );
        }
        return InkWell(
          onTap: () {
            return null;
            //_loginBloc.add(ShowErrorMessageEvent(''));
          },
          child: Row(
            children: [
              Spacer(),
              Container(
                alignment: Alignment.center,
                height: 50,
                padding: EdgeInsets.symmetric(horizontal: 26),
                decoration: BoxDecoration(
                  shape: BoxShape.rectangle,
                  color: AppColor.GRAY,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Text(
                  'Отправить',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
              ),
              Spacer(),
            ],
          ),
        );
      },
    );
  }

  Widget _getLoginButton() {
    return FlatButton(
      onPressed: () {
        print('Войти');
        Navigator.pop(context);
      },
      child: Text(
        'Войти',
        style: TextStyle(fontSize: 16),
      ),
    );
  }

// Widget _getRegistrationButton() {
//   return FlatButton(
//     onPressed: () {
//       print('Регистрация');
//       Navigator.pop(
//         context,
//       );
//       //_loginBloc.add(LoginSignInEvent(_emailController.text, _passwordController.text));
//     },
//     // onLongPress: () {
//     //   _openSuccessPage();
//     // },
//     child: Text(
//       'Регистрация',
//       style: TextStyle(fontSize: 16),
//     ),
//   );
// }

// _openSuccessPage() {
//   Navigator.pushReplacement(
//     context,
//     MaterialPageRoute(builder: (context) => FeedScreen()),
//   );
// }
}
