import 'package:ichazy/domain/bloc/challenge_bloc.dart';

import './dependencies/main_repository_module.dart';

class ChallengeModule {
  static ChallengeBloc challengeBloc() {
    return ChallengeBloc(MainRepositoryModule.mainRepository());
  }
}