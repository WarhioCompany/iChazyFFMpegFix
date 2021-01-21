import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ichazy/data/api/ethernet/response.dart';
import 'package:ichazy/domain/model/brand.dart';
import 'package:ichazy/domain/model/challenge.dart';
import 'package:ichazy/domain/repository/main_repository.dart';

class ChallengeBloc extends Bloc<ChallengeEvent, ChallengeState> {
  final MainRepository _mainRepository;

  ChallengeBloc(this._mainRepository) : super(null);

  @override
  Stream<ChallengeState> mapEventToState(ChallengeEvent event) async* {
    if (event is ChallengeLoadingEvent) {
      yield* _mapChallengeLoadingToState(
          event.uuid, event.previewType, event.thumb);
    }
    if (event is ChallengeUploadDialogEvent) {
      yield* _mapToUploadDialogState(event.challengeId);
    }
    if (event is ChallengeGetPhotoEvent) {
      yield* _mapChallengeGetPhotoToState(event.challengeId);
    }
    if (event is ChallengeGetVideoEvent) {
      yield* _mapChallengeGetVideoToState(event.challengeId);
    }
    if (event is ChallengeCreatePhotoEvent) {
      yield* _mapChallengeCreatePhotoToState(event.context, event.challengeId);
    }
    if (event is ChallengeCreateVideoEvent) {
      yield* _mapChallengeCreateVideoToState(event.context, event.challengeId);
    }
    if (event is ChallengeOpenProfileEvent) {
      yield* _mapChallengeOpenProfileToState(event.brandId);
    }
    if (event is ChallengeOpenChallengeEvent) {
      yield* _mapChallengeOpenChallengeToState(event.brandId);
    }
  }

  Stream<ChallengeState> _mapToUploadDialogState(String challengeId) async* {
    try {
      await _mainRepository.checkSession();
      if (!await _mainRepository.replyIsApplied(challengeId)) {
        yield ChallengeUploadDialogState();
      }
    } on SessionIdNotFoundException {
      _mainRepository.disconnect();
      yield ChallengeLoginState();
    } on NotEnoughBalanceAmountException {
      yield ChallengeMessageState(message: 'Недостаточно монет.', pop: false);
    } on ChallengeApplicationNotUniqueException {
      yield ChallengeMessageState(
          message:
              'Этот челлендж вы уже выполняли. Пожалуйста, выберите другой челлендж.',
          pop: false);
    } catch (e, s) {
      print(e);
      _mainRepository.addLogString('ChallengeBloc');
      _mainRepository.addLogString('$e\n$s');
    }
  }

  Stream<ChallengeState> _mapChallengeGetPhotoToState(
      String challengeId) async* {
    try {
      File file = await _mainRepository.getImageFromGallery();
      await _sendPhoto(file, challengeId);
      yield ChallengeMessageState(message: 'Заявка принята');
    } on CancelException {} on ChallengeApplicationNotUniqueException {
      yield ChallengeMessageState(message: 'Вы уже выполнили этот челлендж.');
    } on SessionIdNotFoundException {
      _mainRepository.disconnect();
      yield ChallengeMessageState(message: 'id сессии не найден');
    } catch (e, s) {
      print(e);
      _mainRepository.addLogString('ChallengeBloc');
      _mainRepository.addLogString('$e\n$s');
      yield ChallengeMessageState(message: UnknownException().message);
    }
  }

  Stream<ChallengeState> _mapChallengeGetVideoToState(
      String challengeId) async* {
    try {
      File file = await _mainRepository.getVideoFromGallery();
      if (!await checkSize(file)) throw MaxSizeException();
      yield ChallengeClosePopup();
      yield ChallengeMessageState(message: 'Заявка отправлена', pop: false);
      File compessedFile = await _mainRepository.compressVideo(file);
      //yield ChallengeShowVideo(file);
      //await Future.delayed(Duration(seconds: 4));
      await _sendVideo(compessedFile, challengeId);
      yield ChallengeMessageState(message: 'Заявка принята', pop: false);
    } on CancelException {} on ChallengeApplicationNotUniqueException {
      yield ChallengeMessageState(message: 'Вы уже выполнили этот челлендж.');
    } on MaxSizeException {
      yield ChallengeMessageState(
          message: 'Превышен максимальный размер файла.');
    } on SessionIdNotFoundException {
      _mainRepository.disconnect();
      yield ChallengeMessageState(message: 'id сессии не найден');
    } catch (e, s) {
      print(e);
      _mainRepository.addLogString('ChallengeBloc');
      _mainRepository.addLogString('$e\n$s');
      yield ChallengeMessageState(message: UnknownException().message);
    }
  }

  Stream<ChallengeState> _mapChallengeCreatePhotoToState(
      BuildContext context, String challengeId) async* {
    try {
      File file = await _mainRepository.recordPhoto(context);
      await _sendPhoto(file, challengeId);
      yield ChallengeMessageState(message: 'Заявка принята');
    } on CancelException {} on ChallengeApplicationNotUniqueException {
      yield ChallengeMessageState(message: 'Вы уже выполнили этот челлендж.');
    } on SessionIdNotFoundException {
      _mainRepository.disconnect();
      yield ChallengeMessageState(message: 'id сессии не найден');
    } catch (e, s) {
      print(e);
      _mainRepository.addLogString('ChallengeBloc');
      _mainRepository.addLogString('$e\n$s');
      yield ChallengeMessageState(message: UnknownException().message);
    }
  }

  Stream<ChallengeState> _mapChallengeCreateVideoToState(
      BuildContext context, String challengeId) async* {
    try {
      File file = await _mainRepository.recordVideo(context);
      if (!await checkSize(file)) throw MaxSizeException();
      yield ChallengeClosePopup();
      yield ChallengeMessageState(message: 'Заявка отправлена', pop: false);
      File compessedFile = await _mainRepository.compressVideo(file);
      await _sendVideo(compessedFile, challengeId);
      yield ChallengeMessageState(message: 'Заявка принята', pop: false);
    } on CancelException {
      print('cancel');
    } on ChallengeApplicationNotUniqueException {
      yield ChallengeMessageState(message: 'Вы уже выполнили этот челлендж.');
    } on SessionIdNotFoundException {
      _mainRepository.disconnect();
      yield ChallengeMessageState(message: 'id сессии не найден');
    } on MaxSizeException {
      yield ChallengeMessageState(
          message: 'Превышен максимальный размер файла.');
    } catch (e, s) {
      print(e);
      _mainRepository.addLogString('ChallengeBloc');
      _mainRepository.addLogString('$e\n$s');
      yield ChallengeMessageState(message: UnknownException().message);
    }
  }

  Stream<ChallengeState> _mapChallengeLoadingToState(
      String uuid, ChallengeType previewType, bool thumb) async* {
    yield ChallengeLoadingState();
    try {
      final file = await _mainRepository.getFile(uuid, previewType, thumb);
      yield ChallengeResultState(file);
    } catch (e, s) {
      _mainRepository.addLogString('ChallengeBloc');
      _mainRepository.addLogString('$e\n$s');
      yield ChallengeErrorState(e);
    }
  }

  _sendPhoto(File file, String challengeId) async {
    var reply = await _mainRepository.createReply(challengeId);
    await _mainRepository.uploadPhoto(reply.id, file);
  }

  _sendVideo(File file, String challengeId) async {
    var reply = await _mainRepository.createReply(challengeId);
    await _mainRepository.uploadVideo(reply.id, file);
  }

  Stream<ChallengeState> _mapChallengeOpenProfileToState(
      String brandId) async* {
    try {
      //await _mainRepository.checkSession();
      print(brandId);
      var brand = await _mainRepository.getBrandProfile(brandId);
      yield ChallengeOpenProfileState(brand);
    }
    // on SessionIdNotFoundException {
    //   yield ChallengeLoginState();
    // }
    catch (e, s) {
      print(e);
      _mainRepository.addLogString('ChallengeBloc');
      _mainRepository.addLogString('$e\n$s');
    }
  }

  Stream<ChallengeState> _mapChallengeOpenChallengeToState(
      String brandId) async* {
    var brand = await _mainRepository.getBrandProfile(brandId);
    yield ChallengeOpenChallengeState(brand);
  }

  Future<bool> checkSize(File file) async {
    final size = await file.length();
    print(size);
    final bytes = convertBytes(size);
    return bytes < 104857600 ? true : false;
  }

  int convertBytes(int bytes) {
    if (bytes == 0) return 0;
    return (bytes / 1024).floor();
  }
}

abstract class ChallengeEvent {}

class ChallengeOpenProfileEvent extends ChallengeEvent {
  final String brandId;
  ChallengeOpenProfileEvent(this.brandId);
}

class ChallengeGetPhotoEvent extends ChallengeEvent {
  final String challengeId;
  ChallengeGetPhotoEvent(this.challengeId);
}

class ChallengeGetVideoEvent extends ChallengeEvent {
  final String challengeId;
  ChallengeGetVideoEvent(this.challengeId);
}

class ChallengeCreatePhotoEvent extends ChallengeEvent {
  final BuildContext context;
  final String challengeId;
  ChallengeCreatePhotoEvent(this.context, this.challengeId);
}

class ChallengeCreateVideoEvent extends ChallengeEvent {
  final BuildContext context;
  final String challengeId;
  ChallengeCreateVideoEvent(this.context, this.challengeId);
}

class ChallengeUploadDialogEvent extends ChallengeEvent {
  final String challengeId;
  ChallengeUploadDialogEvent(this.challengeId);
}

class ChallengeLoadingEvent extends ChallengeEvent {
  final String uuid;
  final ChallengeType previewType;
  final bool thumb;
  ChallengeLoadingEvent(this.uuid, this.previewType, this.thumb);
}

class ChallengeOpenChallengeEvent extends ChallengeEvent {
  final String brandId;
  ChallengeOpenChallengeEvent(this.brandId);
}

abstract class ChallengeState {}

class ChallengeLoadingState extends ChallengeState {}

class ChallengeResultState extends ChallengeState {
  final File file;
  ChallengeResultState(this.file);
}

class ChallengeOpenProfileState extends ChallengeState {
  final Brand brand;
  ChallengeOpenProfileState(this.brand);
}

class ChallengeUploadDialogState extends ChallengeState {}

class ChallengeLoginState extends ChallengeState {}

class ChallengeMessageState extends ChallengeState {
  final String message;
  final bool pop;
  ChallengeMessageState({this.message, this.pop = true});
}

class ChallengeErrorState extends ChallengeState {
  final error;
  ChallengeErrorState(this.error);
}

class ChallengeClosePopup extends ChallengeState {}

class ChallengeShowVideo extends ChallengeState {
  final File file;
  ChallengeShowVideo(this.file);
}

class ChallengeOpenChallengeState extends ChallengeState {
  final Brand brand;
  ChallengeOpenChallengeState(this.brand);
}
