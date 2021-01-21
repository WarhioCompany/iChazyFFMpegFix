import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ichazy/data/api/ethernet/response.dart';
import 'package:ichazy/domain/repository/main_repository.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final MainRepository _mainRepository;
  bool checkLicense;
  bool _email = false;
  bool _password = false;
  bool _license = false;
  bool _nickname = false;

  LoginBloc(this._mainRepository, {this.checkLicense = true}) : super(null);

  LoginState get initialState => LoginInitState();

  bool get validated {
    if (checkLicense) {
      return _email && _password && _license && _nickname;
    } else {
      return _email && _password;
    }
  }

  @override
  Stream<LoginState> mapEventToState(LoginEvent event) async* {
    if (event is LoginSignInEvent) {
      yield* _mapLoginSignInToState(event.email, event.password);
    }
    if (event is LoginSignUpEvent) {
      yield* _mapLoginSignUpToState(
          event.email, event.password, event.nickname, event.regionId);
    }
    if (event is ShowErrorMessageEvent) {
      yield* _mapShowErrorMessageToState(event.error);
    }
    if (event is LoginEmailSwitch) {
      yield* _mapLoginEmailToState(event.value);
    }
    if (event is LoginPasswordSwitch) {
      yield* _mapLoginPasswordToState(event.value);
    }
    if (event is LoginNicknameSwitch) {
      yield* _mapLoginNicknameToState(event.value);
    }
    if (event is LoginLicenseSwitch) {
      yield* _mapLoginLicenseToState(event.value);
    }
  }

  Stream<LoginState> _mapLoginEmailToState(bool value) async* {
    _email = value;
    if (validated)
      yield LoginEnabledState();
    else
      yield LoginDisabledState();
  }

  Stream<LoginState> _mapLoginPasswordToState(bool value) async* {
    _password = value;
    if (validated)
      yield LoginEnabledState();
    else
      yield LoginDisabledState();
  }

  Stream<LoginState> _mapLoginNicknameToState(bool value) async* {
    print('nick $value');
    _nickname = value;
    if (validated)
      yield LoginEnabledState();
    else
      yield LoginDisabledState();
  }

  Stream<LoginState> _mapLoginLicenseToState(bool value) async* {
    _license = value;
    if (validated)
      yield LoginEnabledState();
    else
      LoginDisabledState();
  }

  Stream<LoginState> _mapShowErrorMessageToState(String error) async* {
    yield LoginErrorState(error);
  }

  Stream<LoginState> _mapLoginSignInToState(
      String email, String password) async* {
    yield LoginLoadingState();
    try {
      await _mainRepository.connect(email, password);
      yield LoginResultState();
    } catch (e, s) {
      print(e);
      _mainRepository.addLogString('LoginBloc');
      _mainRepository.addLogString('$e\n$s');
      yield LoginErrorState("Что-то пошло не так");
    }
  }

  Stream<LoginState> _mapLoginSignUpToState(
      String email, String password, String nickname, regionId) async* {
    yield LoginLoadingState();
    try {
      await _mainRepository.register(email, password, nickname, regionId);
      yield LoginResultState();
    } on UserPrimaryIdNotUniqueException {
      yield LoginErrorState("Такой аккаунт уже существует");
    } catch (e) {
      print(e);
      yield LoginErrorState("Что-то пошло не так");
    }
  }
}

abstract class LoginEvent {}

class LoginSignInEvent extends LoginEvent {
  final String email;
  final String password;
  LoginSignInEvent(this.email, this.password);
}

class LoginSignUpEvent extends LoginEvent {
  final String email;
  final String password;
  final String nickname;
  final String regionId;
  LoginSignUpEvent(this.email, this.password, this.nickname, this.regionId);
}

class LoginEmailSwitch extends LoginEvent {
  final bool value;
  LoginEmailSwitch(this.value);
}

class LoginPasswordSwitch extends LoginEvent {
  final bool value;
  LoginPasswordSwitch(this.value);
}

class LoginNicknameSwitch extends LoginEvent {
  final bool value;
  LoginNicknameSwitch(this.value);
}

class LoginLicenseSwitch extends LoginEvent {
  final bool value;
  LoginLicenseSwitch(this.value);
}

class ShowErrorMessageEvent extends LoginEvent {
  final String error;
  ShowErrorMessageEvent(this.error);
}

abstract class LoginState {}

class LoginInitState extends LoginState {}

class LoginDisabledState extends LoginState {}

class LoginEnabledState extends LoginState {}

class LoginResultState extends LoginState {}

class EmptyState extends LoginState {}

class LoginLoadingState extends LoginState {}

class LoginErrorState extends LoginState {
  final error;
  LoginErrorState(this.error);
}
