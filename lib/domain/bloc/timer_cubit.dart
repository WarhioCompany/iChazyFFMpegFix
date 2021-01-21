import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:ichazy/domain/model/ticker_timer.dart';
import 'package:meta/meta.dart';

part 'timer_state.dart';

class TimerCubit extends Cubit<TimerState> {
  final TickerTimer _ticker;
  final int _duration;
  StreamSubscription<int> _tickerSubscription;

  TimerCubit(this._ticker, this._duration) : super(TimerInitial(_duration));
  @override
  Future<void> close() {
    _tickerSubscription?.cancel();
    return super.close();
  }

  void start() async {
    _tickerSubscription?.cancel();
    _tickerSubscription = _ticker.tick(ticks: _duration).listen((duration) {
      if (duration > 0) {
        emit(Running(duration));
      } else
        emit(Finished());
    });
  }

  void reset() {
    _tickerSubscription?.cancel();
    emit(TimerInitial(_duration));
  }

  void tick(int duration) {}
}
