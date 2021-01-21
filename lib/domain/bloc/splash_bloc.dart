import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:ichazy/domain/repository/main_repository.dart';

class SplashBloc extends Bloc<SplashEvent, SplashState> {
  final MainRepository _mainRepository;

  SplashBloc(this._mainRepository) : super(null);

  @override
  Stream<SplashState> mapEventToState(SplashEvent event) async* {
    if (event is SplashInitEvent) {
      yield* _mapSplashInitToState();
    }
  }

  Stream<SplashState> _mapSplashInitToState() async* {
    try {
      bool success = await _mainRepository.checkSession();
      if (success) {
        yield SplashFeedState();
      } else
        yield SplashFailureState();
    } catch (e, s) {
      _mainRepository.addLogString('SplashBloc');
      _mainRepository.addLogString('$e\n$s');
      yield SplashFailureState();
    }
  }
}

abstract class SplashEvent {}

class SplashInitEvent extends SplashEvent {}

abstract class SplashState {}

class SplashFailureState extends SplashState {}

class SplashFeedState extends SplashState {}

class SplashErrorState extends SplashState {
  final error;
  SplashErrorState(this.error);
}
