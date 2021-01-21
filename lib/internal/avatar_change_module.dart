import 'package:ichazy/domain/bloc/avatar_change_bloc.dart';
import 'dependencies/main_repository_module.dart';

class AvatarChangeModule {
  static AvatarChangeBloc avatarChangeBloc() {
    return AvatarChangeBloc(MainRepositoryModule.mainRepository());
  }
}