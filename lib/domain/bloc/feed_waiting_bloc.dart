import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ichazy/domain/model/reply_data.dart';
import 'package:ichazy/domain/repository/main_repository.dart';

class FeedWaitingBloc extends Bloc<FeedWaitingEvent, FeedWaitingState> {
  final MainRepository _mainRepository;
  int offset = 0;
  bool _isLoading = false;

  FeedWaitingBloc(this._mainRepository) : super(null);

  FeedWaitingState get initialState => FeedWaitingHardLoadingState();

  @override
  Stream<FeedWaitingState> mapEventToState(FeedWaitingEvent event) async* {
    if (event is FeedWaitingInitEvent) {
      yield* _mapFeedInitToState();
    }
    if (event is FeedWaitingLoadingEvent) {
      yield* _mapFeedLoadingToState();
    }
    if (event is FeedWaitingAddPosts) {
      yield* _mapFeedAddPostsToState(state);
    }
  }

  Stream<FeedWaitingState> _mapFeedLoadingToState() async* {
    offset = 0;
    yield FeedWaitingLoadingState();
    try {
      List<Reply> replies;
      replies = await _mainRepository.getUserWaitingReplies(offset);
      yield FeedWaitingRepliesResultState(replies, false);
    } catch (e) {
      print(e);
      yield FeedWaitingErrorState(e);
    }
  }

  Stream<FeedWaitingState> _mapFeedInitToState() async* {
    offset = 0;
    yield FeedWaitingHardLoadingState();
    try {
      List<Reply> replies = await _mainRepository.getUserWaitingReplies(offset);
      yield FeedWaitingRepliesResultState(replies, false);
    } catch (e) {
      print(e);
      yield FeedWaitingErrorState(e);
    }
  }

  Stream<FeedWaitingState> _mapFeedAddPostsToState(
      FeedWaitingState currentState) async* {
    if (!_hasReachedThreshold(currentState) && !_isLoading) {
      _isLoading = true;
      try {
        if (currentState is FeedWaitingRepliesResultState) {
          offset = offset + 10;
          final replies = await _mainRepository.getUserWaitingReplies(offset);
          _isLoading = false;
          yield replies.isEmpty
              ? currentState.copyWith(hasReachedThreshold: true)
              : FeedWaitingRepliesResultState(currentState.replies + replies,
                  replies.length == 10 ? false : true);
        }
      } catch (e, s) {
        print(e);
        _isLoading = false;
        _mainRepository.addLogString('FeedBloc');
        _mainRepository.addLogString('$e\n$s');
        yield FeedWaitingErrorState(e);
      }
    }
  }

  bool _hasReachedThreshold(ResultWaitingState state) =>
      state is FeedWaitingRepliesResultState && state.hasReachedThreshold;
}

abstract class FeedWaitingEvent {}

class FeedWaitingInitEvent extends FeedWaitingEvent {}

class FeedWaitingLoadingEvent extends FeedWaitingEvent {}

class FeedWaitingAddPosts extends FeedWaitingEvent {}

abstract class FeedWaitingState {}

class FeedWaitingLoadingState extends FeedWaitingState {}

class FeedWaitingHardLoadingState extends FeedWaitingLoadingState {}

class ResultWaitingState extends FeedWaitingState {
  final bool hasReachedThreshold;
  ResultWaitingState(this.hasReachedThreshold);
}

class FeedWaitingRepliesResultState extends ResultWaitingState {
  final List<Reply> replies;
  final bool hasReachedThreshold;
  FeedWaitingRepliesResultState(this.replies, this.hasReachedThreshold)
      : super(hasReachedThreshold);

  FeedWaitingRepliesResultState copyWith({
    List<Reply> replies,
    bool hasReachedThreshold,
  }) {
    return FeedWaitingRepliesResultState(replies ?? this.replies,
        hasReachedThreshold ?? this.hasReachedThreshold);
  }
}

class FeedWaitingErrorState extends FeedWaitingState {
  final error;
  FeedWaitingErrorState(this.error);
}
