import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ichazy/domain/model/challenge.dart';
import 'package:ichazy/domain/model/reply_data.dart';
import 'package:ichazy/domain/repository/main_repository.dart';

class FeedBloc extends Bloc<FeedEvent, FeedState> {
  final MainRepository _mainRepository;
  Filter _filter;
  String _uid;
  int offset = 0;
  int startPointId;

  FeedBloc(this._mainRepository) : super(null);

  FeedState get initialState => FeedHardLoadingState();

  @override
  Stream<FeedState> mapEventToState(FeedEvent event) async* {
    if (event is FeedInitEvent) {
      yield* _mapFeedInitToState();
    }
    if (event is FeedLoadingEvent) {
      yield* _mapFeedLoadingToState(event.filter, event.uid);
    }
    if (event is FeedAddPosts) {
      yield* _mapFeedAddPostsToState(state);
    }
  }

  Stream<FeedState> _mapFeedLoadingToState(Filter filter, String uid) async* {
    _filter = filter;
    _uid = uid;
    offset = 0;
    yield FeedLoadingState();
    try {
      if (_filter == Filter.ALL_ACTIVE_BY_REGIONS) {
        startPointId = 0;
      } else {
        startPointId =
            await _mainRepository.getApplicationStartPointId(_filter, _uid);
      }

      if (startPointId == null) throw Exception('startPointId == null');
      List<Challenge> challenges;
      List<Reply> replies;
      if (_filter == Filter.ALL_ACTIVE_BY_REGIONS) {
        challenges = await _mainRepository.getChallenges(
            _filter, _uid, startPointId, offset);
        yield FeedResultState(
            challenges, challenges.length == 10 ? false : true);
      } else {
        replies = await _mainRepository.getReplies(
            _filter, _uid, startPointId, offset);
        yield FeedRepliesResultState(
            replies, replies.length == 10 ? false : true);
      }
    } catch (e) {
      print('loading');
      print(e);
      yield FeedErrorState(e);
    }
  }

  Stream<FeedState> _mapFeedInitToState() async* {
    offset = 0;
    yield FeedHardLoadingState();
    try {
      if (_filter == Filter.ALL_ACTIVE_BY_REGIONS) {
        startPointId = 0;
      } else {
        startPointId =
            await _mainRepository.getApplicationStartPointId(_filter, _uid);
      }
      if (startPointId == null) throw Exception('startPointId == null');
      if (_filter == Filter.ALL_ACTIVE_BY_REGIONS) {
        List<Challenge> challenges = await _mainRepository.getChallenges(
            _filter, _uid, startPointId, offset);
        yield FeedResultState(
            challenges, challenges.length == 10 ? false : true);
      } else {
        List<Reply> replies = await _mainRepository.getReplies(
            _filter, _uid, startPointId, offset);
        yield FeedRepliesResultState(
            replies, replies.isNotEmpty ? false : true);
      }
    } catch (e) {
      print('init');
      print(e);
      yield FeedErrorState(e);
    }
  }

  Stream<FeedState> _mapFeedAddPostsToState(FeedState currentState) async* {
    if (!_hasReachedThreshold(currentState)) {
      try {
        if (currentState is FeedResultState) {
          offset = offset + 10;
          final challenges = await _mainRepository.getChallenges(
              _filter, _uid, startPointId, offset);
          print(challenges.length);
          yield challenges.isEmpty
              ? currentState.copyWith(hasReachedThreshold: true)
              : FeedResultState(currentState.challenges + challenges,
                  challenges.length == 10 ? false : true);
        }
        if (currentState is FeedRepliesResultState) {
          offset = offset + 10;
          final replies = await _mainRepository.getReplies(
              _filter, _uid, startPointId, offset);
          yield replies.isEmpty
              ? currentState.copyWith(hasReachedThreshold: true)
              : FeedRepliesResultState(currentState.replies + replies,
                  replies.length == 10 ? false : true);
        }
      } catch (e, s) {
        print('add');
        print(e);
        _mainRepository.addLogString('FeedBloc');
        _mainRepository.addLogString('$e\n$s');
        yield FeedErrorState(e);
      }
    }
  }

  bool _hasReachedThreshold(ResultState state) =>
      (state is FeedResultState || state is FeedRepliesResultState) &&
      state.hasReachedThreshold;
}

abstract class FeedEvent {}

class FeedInitEvent extends FeedEvent {}

class FeedLoadingEvent extends FeedEvent {
  final Filter filter;
  final String uid;
  FeedLoadingEvent(this.filter, this.uid);
}

class FeedAddPosts extends FeedEvent {}

abstract class FeedState {}

class FeedLoadingState extends FeedState {}

class FeedHardLoadingState extends FeedLoadingState {}

class ResultState extends FeedState {
  final bool hasReachedThreshold;
  ResultState(this.hasReachedThreshold);
}

class FeedResultState extends ResultState {
  final List<Challenge> challenges;
  final bool hasReachedThreshold;
  FeedResultState(this.challenges, this.hasReachedThreshold)
      : super(hasReachedThreshold);

  FeedResultState copyWith({
    List<Challenge> challenges,
    bool hasReachedThreshold,
  }) {
    return FeedResultState(challenges ?? this.challenges,
        hasReachedThreshold ?? this.hasReachedThreshold);
  }
}

class FeedRepliesResultState extends ResultState {
  final List<Reply> replies;
  final bool hasReachedThreshold;
  FeedRepliesResultState(this.replies, this.hasReachedThreshold)
      : super(hasReachedThreshold);

  FeedRepliesResultState copyWith({
    List<Reply> replies,
    bool hasReachedThreshold,
  }) {
    return FeedRepliesResultState(replies ?? this.replies,
        hasReachedThreshold ?? this.hasReachedThreshold);
  }
}

class FeedErrorState extends FeedState {
  final error;
  FeedErrorState(this.error);
}
