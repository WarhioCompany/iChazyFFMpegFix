part of 'restore_password_cubit.dart';

@immutable
abstract class RestorePasswordState {}

class RestorePasswordInitial extends RestorePasswordState {}

class RefreshRestoreState extends RestorePasswordState {}

class ShowRestoreMessageState extends RestorePasswordState {
  final String message;
  ShowRestoreMessageState(this.message);
}
