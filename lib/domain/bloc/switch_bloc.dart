import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:ichazy/data/api/ethernet/response.dart';
import 'package:ichazy/domain/model/like_model.dart';
import 'package:ichazy/domain/model/reply_data.dart';
import 'package:ichazy/internal/dependencies/main_repository_module.dart';
import 'package:meta/meta.dart';

///Класс Bloc регулирующий состояние переключателя.
class SwitchBloc extends Bloc<SwitchEvent, SwitchState> {
  bool _value;
  int _likes;
  final _mainRepository = MainRepositoryModule.mainRepository();

  SwitchBloc(bool value, int likes) : super(SwitchInitial(value, likes)) {
    _value = value;
    _likes = likes;
  }

  ///Возвращает значение.
  bool get value => _value;

  int get likes => _likes;

  @override
  Stream<SwitchState> mapEventToState(
    SwitchEvent event,
  ) async* {
    if (event is SwitchInitial) {
      _value = !_value;
    }
    if (event is ChangeSwitchEvent) {
      bool oldValue = _value;
      int oldLikes = _likes;
      _value = event.value;
      _likes = event.likes;
      yield ChangeSwitchState(_value, _likes);
      try {
        LikeStatus type;
        if (value) {
          type = LikeStatus.LIKE;
        } else {
          type = LikeStatus.NOT_SET;
        }
        LikeResponse response =
            await _mainRepository.updateLike(event.applicationId, type);
        bool newBool;
        if (response.likeModel.likeStatus == LikeStatus.LIKE) {
          newBool = true;
        } else {
          newBool = false;
        }
        print(response.value);
        _likes = response.value;
        _value = newBool;
        yield ChangeSwitchState(_value, _likes);
      } on SessionIdNotFoundException {
        _mainRepository.disconnect();
        _value = oldValue;
        _likes = oldLikes;
        yield ChangeSwitchState(_value, _likes);
        yield LoginSwitchState(_value, _likes);
      } catch (e, s) {
        print('[ ChangeSwitchEvent ] $e \n$s');
        _value = oldValue;
        _likes = oldLikes;
        yield ChangeSwitchState(_value, _likes);
        //TODO обработать ошибку
      }
      return;
    }
  }
}

///Класс событий переключателя в стоп-листе
abstract class SwitchEvent {}

///Событие обновления переключателя.
///Запрос на изменение соответствующего поля находится в [callback].
class ChangeSwitchEvent extends SwitchEvent {
  final bool value;
  final int likes;
  final String applicationId;

  ChangeSwitchEvent(
      {@required this.value, this.likes, @required this.applicationId});
}

///Состояние переключателя.
abstract class SwitchState {
  ///Текущее значение переключателя.
  final bool value;
  final int likes;

  const SwitchState(this.value, this.likes);
}

///Начальное состояние.
class SwitchInitial extends SwitchState {
  SwitchInitial(bool value, int likes) : super(value, likes);
}

///Изменение состояния.
class ChangeSwitchState extends SwitchState {
  ChangeSwitchState(bool value, int likes) : super(value, likes);
}

class LoginSwitchState extends SwitchState {
  LoginSwitchState(bool value, int likes) : super(value, likes);
}
