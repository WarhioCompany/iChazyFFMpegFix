import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ichazy/domain/model/balance_response.dart';
import 'package:ichazy/domain/model/challenge.dart';
import 'package:ichazy/domain/repository/main_repository.dart';

class BalanceBloc extends Bloc<BalanceEvent, BalanceState> {
  final MainRepository _mainRepository;
  Filter _filter;
  String _uid;
  int offset = 0;
  int startPointId;
  bool _isLoading = false;

  BalanceBloc(this._mainRepository) : super(null);

  @override
  Stream<BalanceState> mapEventToState(BalanceEvent event) async* {
    if (event is BalanceInitEvent) {
      yield* _mapFeedInitToState();
    }
    if (event is BalanceLoadingEvent) {
      yield* _mapFeedLoadingToState();
    }
    if (event is BalanceAddOperations) {
      yield* _mapFeedAddPostsToState(state);
    }
  }

  Stream<BalanceState> _mapFeedLoadingToState() async* {
    offset = 0;
    yield BalanceLoadingState();
    try {
      startPointId = await _mainRepository.getBalanceStartPointId();

      if (startPointId == null) throw Exception('startPointId == null');
      List<BalanceOperation> operations;
      operations =
          await _mainRepository.getBalanceHistory(startPointId, offset);
      yield BalanceResultState(operations, false);
    } catch (e) {
      print(e);
      yield BalanceErrorState(e);
    }
  }

  Stream<BalanceState> _mapFeedInitToState() async* {
    offset = 1;
    try {
      startPointId = await _mainRepository.getStartPointId(_filter, _uid);

      if (startPointId == null) throw Exception('startPointId == null');
      final List<BalanceOperation> operations =
          await _mainRepository.getBalanceHistory(startPointId, offset);
      yield BalanceResultState(operations, false);
    } catch (e) {
      print(e);
      yield BalanceErrorState(e);
    }
  }

  Stream<BalanceState> _mapFeedAddPostsToState(
      BalanceState currentState) async* {
    if (!_hasReachedThreshold(currentState) && !_isLoading) {
      _isLoading = true;
      try {
        if (currentState is BalanceResultState) {
          ++offset;
          final List<BalanceOperation> operations =
              await _mainRepository.getBalanceHistory(startPointId, offset);
          _isLoading = false;
          yield operations.isEmpty
              ? currentState.copyWith(hasReachedThreshold: true)
              : BalanceResultState(currentState.operations + operations, false);
        }
      } catch (e, s) {
        print(e);
        _isLoading = false;
        _mainRepository.addLogString('FeedBloc');
        _mainRepository.addLogString('$e\n$s');
        yield BalanceErrorState(e);
      }
    }
  }

  bool _hasReachedThreshold(ResultState state) =>
      (state is BalanceResultState) && state.hasReachedThreshold;
}

abstract class BalanceEvent {}

class BalanceInitEvent extends BalanceEvent {}

class BalanceLoadingEvent extends BalanceEvent {}

class BalanceAddOperations extends BalanceEvent {}

abstract class BalanceState {}

class BalanceLoadingState extends BalanceState {}

class ResultState extends BalanceState {
  final bool hasReachedThreshold;
  ResultState(this.hasReachedThreshold);
}

class BalanceResultState extends ResultState {
  final List<BalanceOperation> operations;
  final bool hasReachedThreshold;
  BalanceResultState(this.operations, this.hasReachedThreshold)
      : super(hasReachedThreshold);

  BalanceResultState copyWith({
    List<BalanceOperation> operations,
    bool hasReachedThreshold,
  }) {
    return BalanceResultState(operations ?? this.operations,
        hasReachedThreshold ?? this.hasReachedThreshold);
  }
}

class BalanceErrorState extends BalanceState {
  final error;
  BalanceErrorState(this.error);
}
