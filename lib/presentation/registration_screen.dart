import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ichazy/data/const.dart';
import 'package:ichazy/domain/bloc/filled_cubit.dart';
import 'package:ichazy/domain/bloc/login_bloc.dart';
import 'package:ichazy/domain/bloc/region_cubit.dart';
import 'package:ichazy/domain/model/region.dart';
import 'package:ichazy/internal/login_module.dart';
import 'package:ichazy/presentation/feed_screen.dart';

import 'colors/colors.dart';
import 'elements/fswitch.dart';
import 'login_screen.dart';

class RegistrationScreen extends StatefulWidget {
  @override
  _RegistrationScreenState createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _filledCubit = LoginModule.filledCubit();
  final _loginBloc = LoginModule.loginBloc();
  final _regionCubit = RegionCubit(RegionSingleton().regions.values.first);
  TextEditingController _emailController;
  TextEditingController _passwordController;
  TextEditingController _nicknameController;
  Region currentRegion;
  bool isSwitched = false;
  bool obscureText = true;
  bool emailFilled = true;
  bool passwordFilled = true;
  bool nicknameFilled = true;
  FocusNode passwordFocus;
  FocusNode emailFocus;
  FocusNode nicknameFocus;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    _nicknameController = TextEditingController();
    passwordFocus = FocusNode();
    emailFocus = FocusNode();
    nicknameFocus = FocusNode();
    passwordFocus.addListener(() {
      if (passwordFocus.hasFocus) {
        _filledCubit.passwordFilled();
      }
    });
    emailFocus.addListener(() {
      if (emailFocus.hasFocus) {
        _filledCubit.emailFilled();
      }
    });
    nicknameFocus.addListener(() {
      if (nicknameFocus.hasFocus) {
        _filledCubit.nicknameFilled();
      }
    });
    _nicknameController.addListener(() {
      print(_nicknameController.text.length);
      if (_nicknameController.text != null &&
          _nicknameController.text.length > 0) {
        _loginBloc.add(LoginNicknameSwitch(true));
      } else
        _loginBloc.add(LoginNicknameSwitch(false));
    });
    _emailController.addListener(() {
      if (_emailController.text != null && _emailController.text.length > 0) {
        _loginBloc.add(LoginEmailSwitch(true));
      } else
        _loginBloc.add(LoginEmailSwitch(false));
    });
    _passwordController.addListener(() {
      if (_passwordController.text != null &&
          _passwordController.text.length > 5) {
        _loginBloc.add(LoginPasswordSwitch(true));
      } else
        _loginBloc.add(LoginPasswordSwitch(false));
    });
  }

  @override
  void dispose() {
    passwordFocus.dispose();
    emailFocus.dispose();
    nicknameFocus.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _nicknameController.dispose();
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
          actions: [_getRegionSelect()],
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
      "Регистрация",
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
        _getLoginButton(),
      ],
    );
  }

  Widget _getFields() {
    return BlocBuilder(
      cubit: _filledCubit,
      builder: (context, state) {
        return Column(
          children: [
            _getNicknameField(state == FilledState.nicknameFilled),
            SizedBox(
              height: 20,
            ),
            _getEmailField(state == FilledState.emailFilled),
            SizedBox(
              height: 20,
            ),
            _getPasswordField(state == FilledState.passwordFilled),
            SizedBox(
              height: 20,
            ),
            _getLicence(),
          ],
        );
      },
    );
  }

  Widget _getEmailField(bool emailFilled) {
    return TextField(
      keyboardType: TextInputType.emailAddress,
      focusNode: emailFocus,
      cursorColor: AppColor.ORANGE,
      controller: _emailController,
      decoration: InputDecoration(
        filled: !emailFilled,
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
        labelText: 'Email',
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
        filled: !passwordFilled,
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
        labelText: 'Пароль',
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

  Widget _getNicknameField(bool nicknameFilled) {
    return TextField(
      keyboardType: TextInputType.text,
      focusNode: nicknameFocus,
      cursorColor: AppColor.ORANGE,
      controller: _nicknameController,
      decoration: InputDecoration(
        filled: !nicknameFilled,
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
        labelText: 'Никнейм',
        //labelStyle: TextStyle(color: AppColor.ORANGE),
      ),
    );
  }

  Widget _getLicence() {
    return Row(
      children: [
        FSwitch(
          onChanged: (value) {
            _loginBloc.add(LoginLicenseSwitch(value));
            setState(() {
              isSwitched = value;
            });
          },
          width: 50,
          color: Colors.white,
          open: isSwitched,
          openColor: AppColor.ORANGE,
          borderSliderColor: Colors.grey[350],
          shadowCircleColor: Colors.black.withOpacity(0.3),
          shadowSliderOffset: Offset(0, -1),
          shadowCircleBlur: 10.0,
        ),
        SizedBox(
          width: 12,
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Я согласен с условиями',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            GestureDetector(
              onTap: () => _openLicence(),
              child: Text(
                'Пользовательского соглашения',
                style: TextStyle(
                    color: AppColor.ORANGE, fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _getRegisterButton() {
    return BlocBuilder<LoginBloc, LoginState>(
      cubit: _loginBloc,
      builder: (context, state) {
        print(_loginBloc.validated);
        if (_loginBloc.validated) {
          return InkWell(
            onTap: () async {
              _loginBloc.add(LoginSignUpEvent(
                  _emailController.text,
                  _passwordController.text,
                  _nicknameController.text,
                  _regionCubit.currentRegion.id));
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
                    'Зарегистрироваться',
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
                  'Зарегистрироваться',
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

  Widget _getRegionSelect() {
    final Map<String, Region> mapRegion = RegionSingleton().regions;
    final List<Region> temp = mapRegion.values.toList();
    final List<PopupMenuEntry<Region>> items = [];
    for (final region in temp) {
      items.add(PopupMenuItem(
        height: 45,
        value: region,
        child: region.getRegionImage(),
      ));
    }
    return Container(
      child: BlocBuilder<RegionCubit, RegionState>(
        cubit: _regionCubit,
        builder: (context, state) {
          return PopupMenuButton<Region>(
            padding: EdgeInsets.all(8),
            icon: _regionCubit.currentRegion.getRegionImage(),
            initialValue: _regionCubit.currentRegion,
            onSelected: (region) => _regionCubit.changeRegion(region.id),
            itemBuilder: (context) => items,
            // PopupMenuItem(
            //   value: 'error',
            //   child: Text('Сообщить об ошибке'),
            // ),
            // PopupMenuItem(
            //   value: 'log',
            //   child: Text('Скопировать лог'),
            // ),
            // PopupMenuItem(
            //   value: 'exit',
            //   child: Text('Выйти'),
            // ),
          );
        },
      ),
    );
  }

  Widget _getLoginButton() {
    return FlatButton(
      onPressed: () {
        print('Войти');
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => LoginScreen()),
        );
        // _loginBloc.add(
        //     LoginSignInEvent(_emailController.text, _passwordController.text));
      },
      child: Text(
        'Войти',
        style: TextStyle(fontSize: 16),
      ),
    );
  }

  _openLicence() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return SimpleDialog(
            contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            children: [
              SingleChildScrollView(
                child: Text(Strings.license),
              ),
            ],
          );
        });
  }

  _openSuccessPage() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => FeedScreen()),
    );
  }
}
