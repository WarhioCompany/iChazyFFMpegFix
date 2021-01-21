import 'package:ichazy/domain/bloc/splash_bloc.dart';

import './dependencies/main_repository_module.dart';

class SplashModule {
  static SplashBloc splashBloc() {
    return SplashBloc(MainRepositoryModule.mainRepository());
  }
}