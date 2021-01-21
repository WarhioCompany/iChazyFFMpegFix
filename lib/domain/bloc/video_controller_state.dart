part of 'video_controller_cubit.dart';

@immutable
abstract class VideoControllerState {}

class VideoControllerInitial extends VideoControllerState {}

abstract class VideoVolumeState extends VideoControllerState {}

class VideoVolumeOnState extends VideoVolumeState {}

class VideoVolumeOffState extends VideoVolumeState {}
