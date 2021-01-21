import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ichazy/data/api/ethernet/response.dart';
import 'package:ichazy/domain/model/user.dart';
import 'package:ichazy/domain/repository/main_repository.dart';

class AvatarChangeBloc extends Bloc<AvatarChangeEvent, AvatarChangeState> {
  final MainRepository _mainRepository;

  AvatarChangeBloc(this._mainRepository) : super(null);

  @override
  Stream<AvatarChangeState> mapEventToState(AvatarChangeEvent event) async* {
    if (event is AvatarChangeCallEvent) {
      yield* _mapInitToState();
    }
  }

  Stream<AvatarChangeState> _mapInitToState() async* {
    yield AvatarChangeStartState();
    try {
      File file = await _mainRepository.getImageFromGallery();
      await _mainRepository.setAvatar(file);
      User user = await _mainRepository.refreshProfile();
      yield AvatarChangeRefreshState(user);
    } on SessionIdNotFoundException {
      _mainRepository.disconnect();
      yield AvatarLoginScreenState();
    } catch (e, s) {
      print(e);
      _mainRepository.addLogString('AvatarChangeState');
      _mainRepository.addLogString('$e\n$s');
      yield AvatarChangeErrorState(UnknownException().message);
    }
  }
}

abstract class AvatarChangeEvent {}

class AvatarChangeCallEvent extends AvatarChangeEvent {}

abstract class AvatarChangeState {}

class AvatarChangeStartState extends AvatarChangeState {}

class AvatarChangeRefreshState extends AvatarChangeState {
  User user;
  AvatarChangeRefreshState(this.user);
}

class AvatarChangeErrorState extends AvatarChangeState {
  final error;
  AvatarChangeErrorState(this.error);
}

class AvatarLoginScreenState extends AvatarChangeState {}
