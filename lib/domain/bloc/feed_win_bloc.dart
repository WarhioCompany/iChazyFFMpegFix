import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ichazy/domain/model/reply_data.dart';
import 'package:ichazy/domain/repository/main_repository.dart';

class FeedWinBloc extends Bloc<FeedWinEvent, FeedWinState> {
  final MainRepository _mainRepository;
  int offset = 0;
  bool _isLoading = false;

  FeedWinBloc(this._mainRepository) : super(null);

  FeedWinState get initialState => FeedWinHardLoadingState();

  @override
  Stream<FeedWinState> mapEventToState(FeedWinEvent event) async* {
    if (event is FeedWinInitEvent) {
      yield* _mapFeedInitToState();
    }
    if (event is FeedWinLoadingEvent) {
      yield* _mapFeedLoadingToState();
    }
    if (event is FeedWinAddPosts) {
      yield* _mapFeedAddPostsToState(state);
    }
  }

  Stream<FeedWinState> _mapFeedLoadingToState() async* {
    offset = 0;
    yield FeedWinLoadingState();
    try {
      List<Reply> replies;
      replies = await _mainRepository.getUserWinReplies(offset);
      yield FeedWinRepliesResultState(replies, false);
    } catch (e) {
      print(e);
      yield FeedWinErrorState(e);
    }
  }

  Stream<FeedWinState> _mapFeedInitToState() async* {
    offset = 1;
    yield FeedWinHardLoadingState();
    try {
      List<Reply> replies = await _mainRepository.getUserWinReplies(offset);
      yield FeedWinRepliesResultState(replies, false);
    } catch (e) {
      print(e);
      yield FeedWinErrorState(e);
    }
  }

  Stream<FeedWinState> _mapFeedAddPostsToState(
      FeedWinState currentState) async* {
    if (!_hasReachedThreshold(currentState) && !_isLoading) {
      _isLoading = true;
      try {
        if (currentState is FeedWinRepliesResultState) {
          offset = offset + 10;
          final replies = await _mainRepository.getUserWinReplies(offset);
          _isLoading = false;
          yield replies.isEmpty
              ? currentState.copyWith(hasReachedThreshold: true)
              : FeedWinRepliesResultState(currentState.replies + replies,
                  replies.length == 10 ? false : true);
        }
      } catch (e, s) {
        print(e);
        _isLoading = false;
        _mainRepository.addLogString('FeedBloc');
        _mainRepository.addLogString('$e\n$s');
        yield FeedWinErrorState(e);
      }
    }
  }

  bool _hasReachedThreshold(ResultWinState state) =>
      state is FeedWinRepliesResultState && state.hasReachedThreshold;
}

abstract class FeedWinEvent {}

class FeedWinInitEvent extends FeedWinEvent {}

class FeedWinLoadingEvent extends FeedWinEvent {}

class FeedWinAddPosts extends FeedWinEvent {}

abstract class FeedWinState {}

class FeedWinLoadingState extends FeedWinState {}

class FeedWinHardLoadingState extends FeedWinLoadingState {}

class ResultWinState extends FeedWinState {
  final bool hasReachedThreshold;
  ResultWinState(this.hasReachedThreshold);
}

class FeedWinRepliesResultState extends ResultWinState {
  final List<Reply> replies;
  final bool hasReachedThreshold;
  FeedWinRepliesResultState(this.replies, this.hasReachedThreshold)
      : super(hasReachedThreshold);

  FeedWinRepliesResultState copyWith({
    List<Reply> replies,
    bool hasReachedThreshold,
  }) {
    return FeedWinRepliesResultState(replies ?? this.replies,
        hasReachedThreshold ?? this.hasReachedThreshold);
  }
}

class FeedWinErrorState extends FeedWinState {
  final error;
  FeedWinErrorState(this.error);
}
