import 'package:ichazy/domain/bloc/account_screen_bloc.dart';
import 'dependencies/main_repository_module.dart';

class AccountModule {
  static AccountScreenBloc accountBloc() {
    return AccountScreenBloc(MainRepositoryModule.mainRepository());
  }
}