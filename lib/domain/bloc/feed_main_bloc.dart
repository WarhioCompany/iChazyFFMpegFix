import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ichazy/data/api/ethernet/response.dart';
import 'package:ichazy/domain/model/region.dart';
import 'package:ichazy/domain/model/user.dart';
import 'package:ichazy/domain/repository/main_repository.dart';

class FeedMainBloc extends Bloc<FeedMainEvent, FeedMainState> {
  final MainRepository _mainRepository;

  FeedMainBloc(this._mainRepository) : super(null);

  @override
  Stream<FeedMainState> mapEventToState(FeedMainEvent event) async* {
    if (event is FeedMainProfileEvent) {
      try {
        if (await _checkLogin()) {
          yield* _mapProfileToState();
        } else {
          yield* _mapToLoginState();
        }
      } on SessionIdNotFoundException {
        _mainRepository.disconnect();
        yield FeedMainLoginState();
      } catch (e) {
        yield FeedMainErrorState(e);
      }
    }
    if (event is FeedMainRewardsEvent) {
      try {
        if (await _checkLogin()) {
          yield* _mapRewardsToState();
        } else {
          yield FeedMainLoginState();
        }
      } on SessionIdNotFoundException {
        _mainRepository.disconnect();
        yield FeedMainLoginState();
      } catch (e) {
        yield FeedMainErrorState(e);
      }
    }
    if (event is FeedMainBalanceEvent) {
      try {
        if (await _checkLogin()) {
          yield* _mapBalanceToState();
        } else {
          yield* _mapToLoginState();
        }
      } on SessionIdNotFoundException {
        _mainRepository.disconnect();
        yield FeedMainLoginState();
      } catch (e) {
        yield FeedMainErrorState(e);
      }
    }
  }

  Future<bool> _checkLogin() async {
    return await _mainRepository.checkSession();
  }

  Stream<FeedMainState> _mapProfileToState() async* {
    try {
      if (RegionSingleton().regions.isEmpty) {
        await RegionSingleton().init();
      }
      User user = await _mainRepository.getLocalProfile();
      yield FeedMainProfileState(user);
    } on SessionIdNotFoundException {
      _mainRepository.disconnect();
      yield FeedMainLoginState();
    } catch (e, s) {
      print(e);
      _mainRepository.addLogString('FeedMainBloc');
      _mainRepository.addLogString('$e\n$s');
      yield FeedMainErrorState(e);
    }
  }

  Stream<FeedMainState> _mapRewardsToState() async* {
    yield FeedMainRewardsState();
  }

  Stream<FeedMainState> _mapBalanceToState() async* {
    yield FeedMainBalanceState();
  }

  Stream<FeedMainState> _mapToLoginState() async* {
    _mainRepository.disconnect();
    yield FeedMainLoginState();
  }
}

abstract class FeedMainEvent {}

class FeedMainProfileEvent extends FeedMainEvent {}

class FeedMainRewardsEvent extends FeedMainEvent {}

class FeedMainBalanceEvent extends FeedMainEvent {}

abstract class FeedMainState {}

class FeedMainProfileState extends FeedMainState {
  final User user;
  FeedMainProfileState(this.user);
}

class FeedMainRewardsState extends FeedMainState {}

class FeedMainBalanceState extends FeedMainState {}

class FeedMainLoginState extends FeedMainState {}

class FeedMainErrorState extends FeedMainState {
  final error;
  FeedMainErrorState(this.error);
}
