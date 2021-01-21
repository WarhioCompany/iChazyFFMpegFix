import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ichazy/domain/model/brand.dart';
import 'package:ichazy/domain/model/reply_data.dart';
import 'package:ichazy/domain/model/user.dart';
import 'package:ichazy/internal/dependencies/main_repository_module.dart';

class ReplyCardCubit extends Cubit<ReplyCardState> {
  final _mainRepository = MainRepositoryModule.mainRepository();

  ReplyCardCubit() : super(null);

  void openProfile(Reply reply) async {
    try {
      User user =
          await _mainRepository.getUserProfile(reply.createReply.userId);
      emit(OpenProfileState(user));
    } catch (e, s) {
      _mainRepository.addLogString('ReplyCardCubit');
      _mainRepository.addLogString('$e\n$s');
      emit(ErrorReplyCardState(e));
    }
  }

  void openBrand(String brandId) async {
    try {
      Brand brand = await _mainRepository.getBrandProfile(brandId);
      emit(OpenBrandState(brand));
    } catch (e, s) {
      _mainRepository.addLogString('ReplyCardCubit');
      _mainRepository.addLogString('$e\n$s');
      emit(ErrorReplyCardState(e));
    }
  }

  void replyCancel(String challengeId) async {
    try {
      await _mainRepository.replyCancel(challengeId);
      emit(ExitScreen());
    } catch (e, s) {
      _mainRepository.addLogString('ReplyCardCubit');
      _mainRepository.addLogString('$e\n$s');
      emit(ErrorReplyCardState(e));
    }
  }

  void openReply(String replyId) async {
    try {
      Reply reply = await _mainRepository.getReply(replyId);
      print('user wait');
      final User user = await _mainRepository.getLocalProfile();
      print('user = $user');
      emit(OpenReplyState(reply, user != null ? user.id : ''));
    } catch (e, s) {
      _mainRepository.addLogString('ReplyCardCubit');
      _mainRepository.addLogString('$e\n$s');
      emit(ErrorReplyCardState(e));
    }
  }
}

abstract class ReplyCardState {}

class OpenProfileState extends ReplyCardState {
  final User user;
  OpenProfileState(this.user);
}

class OpenBrandState extends ReplyCardState {
  final Brand brand;
  OpenBrandState(this.brand);
}

class OpenReplyState extends ReplyCardState {
  final Reply reply;
  final String userId;
  OpenReplyState(this.reply, this.userId);
}

class ExitScreen extends ReplyCardState {}

class ErrorReplyCardState extends ReplyCardState {
  final error;
  ErrorReplyCardState(this.error);
}
