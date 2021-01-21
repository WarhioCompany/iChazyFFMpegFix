import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ichazy/domain/bloc/filled_cubit.dart';
import 'package:ichazy/domain/bloc/login_bloc.dart';
import 'package:ichazy/internal/login_module.dart';
import 'package:ichazy/presentation/feed_screen.dart';
import 'package:ichazy/presentation/restore_password_screen.dart';

import 'colors/colors.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _filledCubit = LoginModule.filledCubit();
  final _loginBloc = LoginModule.loginBloc(checkLicense: false);
  TextEditingController _emailController;
  TextEditingController _passwordController;
  //bool isSwitched = false;
  bool obscureText = true;
  bool emailFilled = true;
  bool passwordFilled = true;
  FocusNode passwordFocus;
  FocusNode emailFocus;

  _LoginScreenState();

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    passwordFocus = FocusNode();
    emailFocus = FocusNode();
    passwordFocus.addListener(() {
      if (passwordFocus.hasFocus) {
        _filledCubit.emailFilled();
      }
    });
    emailFocus.addListener(() {
      if (emailFocus.hasFocus) {
        _filledCubit.passwordFilled();
      }
    });
    _emailController.addListener(() {
      if (_emailController.text != null && _emailController.text.length > 0) {
        _loginBloc.add(LoginEmailSwitch(true));
      } else
        _loginBloc.add(LoginEmailSwitch(false));
    });
    _passwordController.addListener(() {
      if (_passwordController.text != null &&
          _passwordController.text.length > 0) {
        _loginBloc.add(LoginPasswordSwitch(true));
      } else
        _loginBloc.add(LoginPasswordSwitch(false));
    });
  }

  @override
  void dispose() {
    passwordFocus.dispose();
    emailFocus.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _loginBloc.close();
    _filledCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener(
      listener: (context, state) {
        if (state is LoginResultState) _openSuccessPage();
        if (state is LoginErrorState)
          Flushbar(
            backgroundColor: AppColor.DARK_BLUE2,
            message: state.error,
            isDismissible: true,
            duration: Duration(seconds: 3),
            dismissDirection: FlushbarDismissDirection.HORIZONTAL,
          )..show(context);
      },
      cubit: _loginBloc,
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
            // SizedBox(
            //   height: 20,
            // ),
            // _getTitle(),
            // AppDivider(),
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
      'Вход',
      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
    );
  }

  Widget _getRegisterForm() {
    return Column(
      children: [
        SizedBox(
          height: 20,
        ),
        _getFields(),
        SizedBox(
          height: 20,
        ),
        _getRegisterButton(),
        SizedBox(
          height: 30,
        ),
        //_getLoginButton(),
        // SizedBox(
        //   height: 30,
        // ),
        _getRegistrationButton(),
        SizedBox(
          height: 30,
        ),
        _getForgotPasswordButton(),
      ],
    );
  }

  Widget _getFields() {
    return Column(
      children: [
        BlocBuilder(
          cubit: _filledCubit,
          builder: (context, state) {
            if (state == FilledState.passwordFilled)
              return _getEmailField(false);
            return _getEmailField(true);
          },
        ),
        SizedBox(
          height: 20,
        ),
        BlocBuilder(
          cubit: _filledCubit,
          builder: (context, state) {
            if (state == FilledState.emailFilled)
              return _getPasswordField(false);
            return _getPasswordField(true);
          },
        ),
        SizedBox(
          height: 20,
        ),
        //_getLicence(),
      ],
    );
  }

  Widget _getEmailField(bool emailFilled) {
    return TextField(
      keyboardType: TextInputType.emailAddress,
      focusNode: emailFocus,
      cursorColor: AppColor.ORANGE,
      controller: _emailController,
      decoration: InputDecoration(
        filled: emailFilled,
        fillColor: Colors.grey[200],
        contentPadding: EdgeInsets.symmetric(vertical: 5.0, horizontal: 22.0),
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
    );
  }

  Widget _getPasswordField(bool passwordFilled) {
    return TextField(
      keyboardType: TextInputType.visiblePassword,
      focusNode: passwordFocus,
      autocorrect: false,
      cursorColor: AppColor.ORANGE,
      obscureText: obscureText,
      controller: _passwordController,
      decoration: InputDecoration(
        filled: passwordFilled,
        fillColor: Colors.grey[200],
        contentPadding: EdgeInsets.symmetric(vertical: 5.0, horizontal: 22.0),
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
        labelText: 'Пароль *',
        suffixIcon: IconButton(
          icon: Icon(
            Icons.remove_red_eye,
            color: Colors.black,
          ),
          onPressed: () {
            setState(() {
              obscureText = !obscureText;
            });
          },
        ),
      ),
    );
  }

  // Widget _getLicence() {
  //   return Row(
  //     children: [
  //       FSwitch(
  //         onChanged: (value) {
  //           _loginBloc.add(LoginLicenseSwitch(value));
  //           setState(() {
  //             isSwitched = value;
  //           });
  //         },
  //         width: 50,
  //         color: Colors.white,
  //         open: isSwitched,
  //         openColor: AppColor.ORANGE,
  //         borderSliderColor: Colors.grey[350],
  //         shadowCircleColor: Colors.black.withOpacity(0.3),
  //         shadowSliderOffset: Offset(0, -1),
  //         shadowCircleBlur: 10.0,
  //       ),
  //       SizedBox(
  //         width: 12,
  //       ),
  //       Column(
  //         crossAxisAlignment: CrossAxisAlignment.start,
  //         children: [
  //           Text(
  //             'Я согласен с условиями',
  //             style: TextStyle(fontWeight: FontWeight.w500),
  //           ),
  //           GestureDetector(
  //             onTap: () => _openLicence(),
  //             child: Text(
  //               'Пользовательского соглашения',
  //               style: TextStyle(
  //                   color: AppColor.ORANGE, fontWeight: FontWeight.w500),
  //             ),
  //           ),
  //         ],
  //       ),
  //     ],
  //   );
  // }

  Widget _getRegisterButton() {
    return BlocBuilder<LoginBloc, LoginState>(
      cubit: _loginBloc,
      builder: (context, state) {
        if (_loginBloc.validated) {
          return InkWell(
            onTap: () async {
              _loginBloc.add(LoginSignInEvent(
                  _emailController.text, _passwordController.text));
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
                    'Войти',
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
                  'Войти',
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

  // Widget _getLoginButton() {
  //   return FlatButton(
  //     onPressed: () {
  //       print('Войти');
  //       _loginBloc.add(
  //           LoginSignInEvent(_emailController.text, _passwordController.text));
  //     },
  //     // onLongPress: () {
  //     //   _openSuccessPage();
  //     // },
  //     child: Text(
  //       'Войти',
  //       style: TextStyle(fontSize: 16),
  //     ),
  //   );
  // }

  Widget _getRegistrationButton() {
    return FlatButton(
      onPressed: () {
        print('Регистрация');
        Navigator.pop(
          context,
        );
        //_loginBloc.add(LoginSignInEvent(_emailController.text, _passwordController.text));
      },
      // onLongPress: () {
      //   _openSuccessPage();
      // },
      child: Text(
        'Регистрация',
        style: TextStyle(fontSize: 16),
      ),
    );
  }

  Widget _getForgotPasswordButton() {
    return FlatButton(
      onPressed: () {
        print('Забыли пароль?');
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => RestorePasswordScreen()),
        );
      },
      // onLongPress: () {
      //   _openSuccessPage();
      // },
      child: Text(
        'Забыли пароль?',
        style: TextStyle(fontSize: 16),
      ),
    );
  }

  _openSuccessPage() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => FeedScreen()),
    );
  }
}
