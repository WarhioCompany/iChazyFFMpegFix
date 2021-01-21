import 'package:bloc/bloc.dart';
import 'package:ichazy/data/api/ethernet/response.dart';
import 'package:ichazy/internal/dependencies/main_repository_module.dart';
import 'package:meta/meta.dart';

part 'restore_password_state.dart';

class RestorePasswordCubit extends Cubit<RestorePasswordState> {
  final _mainRepository = MainRepositoryModule.mainRepository();
  bool _emailFilled = false;
  RestorePasswordCubit() : super(RestorePasswordInitial());

  bool get filled => _emailFilled;

  void switchState(bool value) {
    _emailFilled = value;
    emit(RefreshRestoreState());
  }

  void send(String email) async {
    try {
      await _mainRepository.restoreAuth(email);
      emit(ShowRestoreMessageState(
          'Инструкции по восстановлению пароля отправлены на ваш email.'));
    } on AuthCodeTemporaryBlocked {
      emit(ShowRestoreMessageState(
          'Слишком много попыток восстановления пароля, повторите позже.'));
    } on EntityNotFoundException {
      emit(ShowRestoreMessageState('Пользователь с таким email не найден.'));
    } catch (e, s) {
      emit(ShowRestoreMessageState('Ой, что-то пошло не так.'));
      print(e);
      print(s);
    }
  }
}
