import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ichazy/domain/model/challenge.dart';
import 'package:ichazy/domain/model/reply_data.dart';
import 'package:ichazy/domain/repository/main_repository.dart';

class ReplyFeedBloc extends Bloc<ReplyFeedEvent, ReplyFeedState> {
  final MainRepository _mainRepository;
  Filter _filter;
  String _uid;
  int offset = 0;
  int startPointId;
  String localChallengeId;
  ReplyFeedBloc(this._mainRepository) : super(null);

  ReplyFeedState get initialState => ReplyFeedHardLoadingState();

  @override
  Stream<ReplyFeedState> mapEventToState(ReplyFeedEvent event) async* {
    if (event is ReplyFeedLoadingEvent) {
      yield* _mapFeedLoadingToState(event.filter, event.uid);
    }
    if (event is ReplyFeedAddPosts) {
      yield* _mapFeedAddPostsToState(state);
    }
  }

  Stream<ReplyFeedState> _mapFeedLoadingToState(
      Filter filter, String uid) async* {
    offset = 0;

    localChallengeId = uid;
    _filter = filter;
    _uid = uid;
    yield ReplyFeedLoadingState();
    try {
      startPointId =
          await _mainRepository.getApplicationStartPointId(_filter, _uid);
      if (startPointId == null) throw Exception('startPointId == null');
      List<Reply> replies =
          await _mainRepository.getReplies(_filter, _uid, startPointId, offset);
      print(replies);
      yield ReplyFeedResultState(replies, false);
    } catch (e) {
      print(e);
      yield ReplyFeedErrorState(e);
    }
  }

  Stream<ReplyFeedState> _mapFeedAddPostsToState(
      ReplyFeedState currentState) async* {
    if (!_hasReachedThreshold(currentState)) {
      try {
        if (currentState is ReplyFeedResultState) {
          offset = offset + 10;
          final replies = await _mainRepository.getReplies(
              _filter, _uid, startPointId, offset);
          yield replies.isEmpty || replies.length < 10
              ? currentState.copyWith(hasReachedThreshold: true)
              : ReplyFeedResultState(currentState.replies + replies, false);
        }
      } catch (e, s) {
        print(e);
        _mainRepository.addLogString('ReplyFeedBloc');
        _mainRepository.addLogString('$e\n$s');
        yield ReplyFeedErrorState(e);
      }
    }
  }

  bool _hasReachedThreshold(ReplyFeedState state) =>
      state is ReplyFeedResultState && state.hasReachedThreshold;
}

abstract class ReplyFeedEvent {}

class ReplyFeedInitEvent extends ReplyFeedEvent {}

class ReplyFeedLoadingEvent extends ReplyFeedEvent {
  final Filter filter;
  final String uid;
  ReplyFeedLoadingEvent(this.filter, this.uid);
}

class ReplyFeedAddPosts extends ReplyFeedEvent {}

class ReplyGetBrandEvent extends ReplyFeedEvent {}

abstract class ReplyFeedState {}

class ReplyFeedLoadingState extends ReplyFeedState {}

class ReplyFeedHardLoadingState extends ReplyFeedLoadingState {}

class ReplyFeedResultState extends ReplyFeedState {
  final List<Reply> replies;
  final bool hasReachedThreshold;
  ReplyFeedResultState(this.replies, this.hasReachedThreshold);

  ReplyFeedResultState copyWith({
    List<Reply> replies,
    bool hasReachedThreshold,
  }) {
    return ReplyFeedResultState(replies ?? this.replies,
        hasReachedThreshold ?? this.hasReachedThreshold);
  }
}

class ReplyFeedErrorState extends ReplyFeedState {
  final error;
  ReplyFeedErrorState(this.error);
}
