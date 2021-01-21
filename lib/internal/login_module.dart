import 'package:ichazy/domain/bloc/filled_cubit.dart';
import 'package:ichazy/domain/bloc/login_bloc.dart';

import './dependencies/main_repository_module.dart';

class LoginModule {
  static FilledCubit filledCubit() {
    return FilledCubit();
  }

  static LoginBloc loginBloc({bool checkLicense = true}) {
    return LoginBloc(MainRepositoryModule.mainRepository(),
        checkLicense: checkLicense);
  }
}
