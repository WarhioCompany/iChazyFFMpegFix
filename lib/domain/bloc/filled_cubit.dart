import 'package:flutter_bloc/flutter_bloc.dart';

class FilledCubit extends Cubit<FilledState> {
  FilledCubit() : super(FilledState.none);

  void passwordFilled() => emit(FilledState.passwordFilled);
  void emailFilled() => emit(FilledState.emailFilled);
  void nicknameFilled() => emit(FilledState.nicknameFilled);
}

enum FilledState { none, passwordFilled, emailFilled, nicknameFilled }
