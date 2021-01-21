import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ichazy/data/api/ethernet/response.dart';
import 'package:ichazy/domain/model/auth.dart';
import 'package:ichazy/domain/model/region.dart';
import 'package:ichazy/domain/model/user.dart';
import 'package:ichazy/domain/repository/main_repository.dart';

class AccountScreenBloc extends Bloc<AccountScreenEvent, AccountScreenState> {
  final MainRepository _mainRepository;
  User oldUser;
  bool isConfirmedEmail = true;
  String email;

  AccountScreenBloc(this._mainRepository) : super(null);

  AccountScreenState get initialState => InitScreenState();

  @override
  Stream<AccountScreenState> mapEventToState(AccountScreenEvent event) async* {
    if (event is InitEvent) {
      oldUser = event.user;
      yield* _mapInitToState();
    }
    if (event is OpenChangeScreenEvent) {
      oldUser = event.user;
      yield* _mapOpenChangeScreenToState();
    }
    if (event is AvatarChangeEvent) {
      yield* _mapAvatarChangeToState();
    }
    if (event is RefreshPageEvent) {
      yield* _mapRefreshPageToState();
    }
    if (event is SaveChangesEvent) {
      yield* _mapSaveChangesState(event.nickname, event.birthday, event.sex,
          event.regionId, event.regionMask);
    }
    if (event is ConfirmEmailEvent) {
      yield* _mapConfirmToState();
    }
    if (event is LogEvent) {
      yield* _mapLogToState();
    }
    if (event is ExitEvent) {
      yield* _mapExitToState();
    }
  }

  Stream<AccountScreenState> _mapInitToState() async* {
    List<Auth> auth = await _mainRepository.getUserAuth();
    final authCheck = auth.firstWhere(
        (element) => element.authType == AuthType.EMAIL && !element.isConfirmed,
        orElse: () => null);
    if (authCheck == null || authCheck.isConfirmed) {
      isConfirmedEmail = true;
    } else {
      email = authCheck.primaryId;
      isConfirmedEmail = false;
    }
    yield InitScreenState();
    if (RegionSingleton().regions.isEmpty) {
      await RegionSingleton().init();
    }
  }

  Stream<AccountScreenState> _mapAvatarChangeToState() async* {
    try {
      File file = await _mainRepository.getImageFromGallery();
      await _mainRepository.setAvatar(file);
      List<Auth> auth = await _mainRepository.getUserAuth();
      final authCheck = auth.firstWhere(
          (element) =>
              element.authType == AuthType.EMAIL && !element.isConfirmed,
          orElse: () => null);
      if (authCheck != null) {
        email = authCheck.primaryId;
      }
      if (authCheck == null || authCheck.isConfirmed) {
        isConfirmedEmail = true;
      } else {
        email = authCheck.primaryId;
        isConfirmedEmail = false;
      }
      yield RefreshScreenState();
      User newUser = await _mainRepository.refreshProfile();
      yield ChangeScreenState(newUser, auth);
    } on CancelException {} on SessionIdNotFoundException {
      _mainRepository.disconnect();
      yield ExitState();
    } catch (e, s) {
      print(e);
      _mainRepository.addLogString('AccountScreenBloc');
      _mainRepository.addLogString('$e\n$s');
      yield AccountScreenErrorState(UnknownException().message);
    }
  }

  Stream<AccountScreenState> _mapOpenChangeScreenToState() async* {
    try {
      User newUser = await _mainRepository.refreshProfile();
      List<Auth> auth = await _mainRepository.getUserAuth();
      final authCheck = auth.firstWhere(
          (element) =>
              element.authType == AuthType.EMAIL && !element.isConfirmed,
          orElse: () => null);
      if (authCheck == null || authCheck.isConfirmed) {
        isConfirmedEmail = true;
      } else {
        email = authCheck.primaryId;
        isConfirmedEmail = false;
      }
      yield ChangeScreenState(newUser, auth);
    } on SessionIdNotFoundException {
      await _mainRepository.disconnect();
      yield ExitState();
    } catch (e, s) {
      print(e);
      _mainRepository.addLogString('AccountScreenBloc');
      _mainRepository.addLogString('$e\n$s');
      yield AccountScreenErrorState(UnknownException().message);
    }
  }

  Stream<AccountScreenState> _mapLogToState() async* {
    yield LogState(_mainRepository.getLog());
  }

  Stream<AccountScreenState> _mapRefreshPageToState() async* {
    try {
      User newUser = await _mainRepository.refreshProfile();
      List<Auth> auth = await _mainRepository.getUserAuth();
      final authCheck = auth.firstWhere(
          (element) =>
              element.authType == AuthType.EMAIL && !element.isConfirmed,
          orElse: () => null);
      if (authCheck == null || authCheck.isConfirmed) {
        isConfirmedEmail = true;
      } else {
        email = authCheck.primaryId;
        isConfirmedEmail = false;
      }
      yield RefreshScreenState();
      yield ChangeScreenState(newUser, auth);
    } on SessionIdNotFoundException {
      await _mainRepository.disconnect();
      yield ExitState();
    } catch (e, s) {
      print(e);
      _mainRepository.addLogString('AccountScreenBloc');
      _mainRepository.addLogString('$e\n$s');
      yield AccountScreenErrorState(UnknownException().message);
    }
  }

  Stream<AccountScreenState> _mapSaveChangesState(String nickname,
      DateTime birthday, Sex sex, String regionId, int regionMask) async* {
    if (oldUser.sex == sex &&
        oldUser.nickname == nickname &&
        oldUser.birthday == (birthday.millisecondsSinceEpoch ~/ 1000)) {
      User newUser = await _mainRepository.refreshProfile();
      yield InfoScreenState(newUser);
    } else {
      try {
        User user = User('', nickname, birthday.millisecondsSinceEpoch ~/ 1000,
            '', 0, sex, regionId, regionMask);
        User newUser = await _mainRepository.editAccount(user);
        oldUser = newUser;
        yield InfoScreenState(newUser);
      } on UserBirthdayOutOfRangeException {
        _mainRepository.addLogString('AccountScreenBloc');
        _mainRepository.addLogString(UserBirthdayOutOfRangeException().message);
        yield AccountScreenErrorState(
            UserBirthdayOutOfRangeException().message);
      } on UserNicknameNotUniqueException {
        _mainRepository.addLogString('AccountScreenBloc');
        _mainRepository.addLogString(UserNicknameNotUniqueException().message);
        yield AccountScreenErrorState(UserNicknameNotUniqueException().message);
      } on FileChunkOutOfOrderException {
        _mainRepository.addLogString('AccountScreenBloc');
        _mainRepository.addLogString(FileChunkOutOfOrderException().message);
        yield AccountScreenErrorState(FileChunkOutOfOrderException().message);
      } on SessionIdNotFoundException {
        await _mainRepository.disconnect();
        yield ExitState();
      } catch (e, s) {
        print(e);
        _mainRepository.addLogString('AccountScreenBloc');
        _mainRepository.addLogString('$e\n$s');
        yield AccountScreenErrorState(UnknownException().message);
      }
    }
  }

  Stream<AccountScreenState> _mapExitToState() async* {
    try {
      await _mainRepository.disconnect();
      yield ExitState();
    } catch (e, s) {
      print(e);
      _mainRepository.addLogString('$e\n$s');
      yield AccountScreenErrorState(UnknownException().message);
    }
  }

  Stream<AccountScreenState> _mapConfirmToState() async* {
    try {
      await _mainRepository.confirmEmail(email);
      yield AccountScreenErrorState('Отправлен запрос подтверждения email.');
    } catch (e, s) {
      print(e);
      _mainRepository.addLogString('AccountScreenBloc');
      _mainRepository.addLogString('$e\n$s');
      yield AccountScreenErrorState(UnknownException().message);
    }
  }
}

abstract class AccountScreenEvent {}

class InitEvent extends AccountScreenEvent {
  final User user;
  InitEvent(this.user);
}

class AvatarChangeEvent extends AccountScreenEvent {}

class OpenChangeScreenEvent extends AccountScreenEvent {
  final User user;
  OpenChangeScreenEvent(this.user);
}

class RefreshPageEvent extends AccountScreenEvent {}

class LogEvent extends AccountScreenEvent {}

class SaveChangesEvent extends AccountScreenEvent {
  final String nickname;
  final DateTime birthday;
  final Sex sex;
  final String regionId;
  final int regionMask;
  SaveChangesEvent(
      this.nickname, this.birthday, this.sex, this.regionId, this.regionMask);
}

class ExitEvent extends AccountScreenEvent {}

class ConfirmEmailEvent extends AccountScreenEvent {}

abstract class AccountScreenState {}

class InitScreenState extends AccountScreenState {}

class InfoScreenState extends AccountScreenState {
  final User user;
  InfoScreenState(this.user);
}

class RefreshScreenState extends AccountScreenState {}

class ChangeScreenState extends AccountScreenState {
  final User user;
  final List<Auth> auth;
  ChangeScreenState(this.user, this.auth);
}

class LogState extends AccountScreenState {
  final String log;
  LogState(this.log);
}

class ExitState extends AccountScreenState {}

class AccountScreenErrorState extends AccountScreenState {
  final error;
  AccountScreenErrorState(this.error);
}
