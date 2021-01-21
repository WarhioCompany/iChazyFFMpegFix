import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:ichazy/domain/model/award.dart';
import 'package:ichazy/domain/repository/main_repository.dart';
import 'package:meta/meta.dart';

part 'rewards_event.dart';
part 'rewards_state.dart';

class RewardsBloc extends Bloc<RewardsEvent, RewardsState> {
  final MainRepository _mainRepository;
  final bool isUsed;
  int offset = 0;
  RewardsBloc(this._mainRepository, this.isUsed) : super(RewardsInitial());

  @override
  Stream<RewardsState> mapEventToState(
    RewardsEvent event,
  ) async* {
    if (event is RewardsLoadingEvent) {
      yield* _mapFeedLoadingToState();
    }
    if (event is RewardsAddPostsEvent) {
      yield* _mapFeedAddPostsToState(state);
    }
  }

  Stream<RewardsState> _mapFeedLoadingToState() async* {
    offset = 0;

    yield RewardsLoadingState();
    try {
      List<Award> rewards =
          await _mainRepository.getUserRewards(isUsed, offset);
      print(rewards);
      yield RewardsResultState(rewards, false);
    } catch (e) {
      print(e);
      yield RewardsErrorState(e);
    }
  }

  Stream<RewardsState> _mapFeedAddPostsToState(
      RewardsState currentState) async* {
    if (!_hasReachedThreshold(currentState)) {
      try {
        if (currentState is RewardsResultState) {
          ++offset;
          List<Award> rewards =
              await _mainRepository.getUserRewards(isUsed, offset);
          yield rewards.isEmpty || rewards.length < 10
              ? currentState.copyWith(hasReachedThreshold: true)
              : RewardsResultState(currentState.rewards + rewards, false);
        }
      } catch (e, s) {
        print(e);
        _mainRepository.addLogString('ReplyFeedBloc');
        _mainRepository.addLogString('$e\n$s');
        yield RewardsErrorState(e);
      }
    }
  }

  bool _hasReachedThreshold(RewardsState state) =>
      state is RewardsResultState && state.hasReachedThreshold;
}
