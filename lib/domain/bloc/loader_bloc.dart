import 'package:flutter_bloc/flutter_bloc.dart';

class LoaderBloc extends Bloc<LoaderEvent, LoaderState> {

  LoaderBloc() : super(null);

  LoaderState get initialState => LoaderInactiveState();

  @override
  Stream<LoaderState> mapEventToState(LoaderEvent event) async* {
    if (event is LoaderStartEvent) {
      yield* _mapLoaderStartToState();
    }
    if (event is LoaderStopEvent) {
      yield* _mapLoaderStopToState();
    }
  }

  Stream<LoaderState> _mapLoaderStartToState() async* {
    yield LoaderActiveState();
  }

  Stream<LoaderState> _mapLoaderStopToState() async* {
    yield LoaderInactiveState();
  }
}

abstract class LoaderEvent {}

class LoaderStartEvent extends LoaderEvent {}
class LoaderStopEvent extends LoaderEvent {}

abstract class LoaderState {}

class LoaderActiveState extends LoaderState {}
class LoaderInactiveState extends LoaderState {}