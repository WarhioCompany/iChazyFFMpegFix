part of 'timer_cubit.dart';

@immutable
abstract class TimerState {
  final int duration;
  TimerState(this.duration);
}

class TimerInitial extends TimerState {
  TimerInitial(int duration) : super(duration);
}

class Empty extends TimerState {
  Empty(int duration) : super(duration);
}

class Running extends TimerState {
  Running(int duration) : super(duration);
}

class Finished extends TimerState {
  Finished() : super(0);
}
