import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:fijkplayer/fijkplayer.dart';
import 'package:meta/meta.dart';

part 'video_controller_state.dart';

class VideoControllerCubit extends Cubit<VideoControllerState> {
  VideoControllerCubit() : super(VideoControllerInitial());
  bool _volume = false;
  FijkPlayer _player = FijkPlayer();
  //FijkLog _log = FijkLog.setLevel(FijkLogLevel.Error);

  FijkPlayer get player => _player;
  bool get volume => _volume;

  void init(File file) async {
    //await _player.
    await _player.setDataSource(file.path, autoPlay: true);
    await _player.setLoop(50);
    await _player.setVolume(0);
  }

  void onVolume() async {
    await _player.setVolume(100);
    _volume = true;
    emit(VideoVolumeOnState());
  }

  void offVolume() async {
    await _player.setVolume(0);
    _volume = false;
    emit(VideoVolumeOffState());
  }

  void pause() async {
    if (_player.isPlayable()) {
      await _player.pause();
    }
  }

  void play() async {
    if (_player.isPlayable()) {
      await _player.start();
    }
  }
}
