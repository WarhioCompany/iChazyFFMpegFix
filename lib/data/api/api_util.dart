import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:convert/convert.dart';
import 'package:ichazy/data/api/ethernet/ethernet.dart';
import 'package:ichazy/domain/model/auth.dart';
import 'package:ichazy/domain/model/award.dart';
import 'package:ichazy/domain/model/balance_response.dart';
import 'package:ichazy/domain/model/brand.dart';
import 'package:ichazy/domain/model/challenge.dart';
import 'package:ichazy/domain/model/create_reply_data.dart';
import 'package:ichazy/domain/model/like_model.dart';
import 'package:ichazy/domain/model/region.dart';
import 'package:ichazy/domain/model/reply_data.dart';
import 'package:ichazy/domain/model/user.dart';

import 'ethernet/response.dart';

class ApiUtil {
  //int offset = 0;
  Ethernet _ethernet = Ethernet();

  Future<Session> connect([String email, String password]) async {
    if (email != null && password != null) {
      Map map = await _ethernet.signIn(email, password);
      if (map == null) throw Exception();
      Session session = Session.fromMap(map);
      return session;
    } else {
      //
    }
  }

  Future<SignUpResponse> register(
      String primaryId, String secret, String nickname, String regionId) async {
    print('Зарегистрироваться');
    Map<String, dynamic> json =
        await _ethernet.signUp(primaryId, secret, nickname, regionId);
    SignUpResponse response = SignUpResponse.fromMap(json);
    return response;
  }

  Future<void> newCode() {
    //
  }

  Future<void> confirm() {
    //
  }

  Future<void> setAvatar(String sessionId, File file) async {
    FileStat stat = await file.stat();
    String fileId = await _ethernet.uploadAvatar(sessionId, stat.size);
    await startUpload(sessionId, fileId, file);
    await _ethernet.getUploadInfo(sessionId, fileId);
  }

  Future<void> uploadPhoto(
      String sessionId, String challengeId, File file) async {
    await uploadNewFile(sessionId, challengeId, file, 'WEBP');
  }

  Future<void> uploadVideo(
      String sessionId, String challengeId, File file) async {
    await uploadNewFile(sessionId, challengeId, file, 'MP4');
  }

  Future<List<Auth>> getUserAuth(String sessionId) async {
    List<Auth> result = [];
    var tempListMaps = await _ethernet.getUserAuth(sessionId);
    for (Map<String, dynamic> map in tempListMaps) {
      print(map);
      result.add(Auth.fromMap(map));
    }
    return result;
  }

  Future<List<Award>> getUserRewards(
      String sessionId, bool isUsed, int offset) async {
    List<Award> result = [];
    var tempListMaps =
        await _ethernet.getUserRewards(sessionId, isUsed, offset);
    for (Map<String, dynamic> map in tempListMaps) {
      print(map);
      result.add(Award.fromMap(map));
    }
    return result;
  }

  Future<void> replyCancel(String sessionId, String challengeId) async {
    await _ethernet.replyCancel(sessionId, challengeId);
  }

  Future<Award> setIsUsedPromoCode(
      String sessionId, String promoCodeId, bool isUsed) async {
    Map<String, dynamic> map =
        await _ethernet.setIsUsedPromoCode(sessionId, promoCodeId, isUsed);
    Award award = Award.fromMap(map);
    return award;
  }

  Future<Reply> getReply(String sessionId, String replyId) async {
    Map<String, dynamic> map = await _ethernet.getReply(sessionId, replyId);
    Reply reply = Reply.fromMap(map);
    print(reply.likeStatus);
    return reply;
  }

  Future<void> uploadNewFile(
      String sessionId, String challengeId, File file, String type) async {
    FileStat stat = await file.stat();
    String fileId =
        await _ethernet.uploadNewFile(sessionId, challengeId, stat.size, type);
    await startUpload(sessionId, fileId, file);
    await _ethernet.getUploadInfo(sessionId, fileId);
  }

  Future<void> startUpload(String sessionId, String fileId, File file) async {
    final int chunk = 524288;
    print('fileId = $fileId');
    FileStat stat = await file.stat();
    Uint8List bytes = await file.readAsBytes();
    HexEncoder _encoder = hex.encoder;
    if (stat.size < chunk) {
      String hexData = _encoder.convert(bytes);
      await _ethernet.uploadFileChunk(sessionId, fileId, 0, hexData);
    } else {
      final int numberOfChunks = stat.size ~/ chunk;
      for (int chunkId = 0; chunkId < numberOfChunks + 1; chunkId++) {
        Uint8List part;
        if (chunkId != numberOfChunks) {
          part = bytes.sublist(chunkId * chunk, (chunkId + 1) * chunk);
        } else {
          part = bytes.sublist(chunkId * chunk, bytes.length);
        }
        String hexData = _encoder.convert(part);
        print(hexData.length);
        await _ethernet.uploadFileChunk(sessionId, fileId, chunkId, hexData);
      }
    }
  }

  //удаление аккаунта 2 фазы
  //отмена удаления аккаунта
  Future<User> editAccount(String sessionId, User user) async {
    Map<String, dynamic> map = await _ethernet.editAccount(sessionId,
        user.nickname, user.birthday, sexToString(user.sex), user.regionId);
    print(map);
    User userResult = User.fromUserData(UserData.fromMap(map));
    return userResult;
  }

  Future<void> restoreAuth(String id) async {
    await _ethernet.restoreAuth(id);
  }

  Future<UserData> getProfile(String sessionId) async {
    Map<String, dynamic> map = await _ethernet.getProfile(sessionId);
    UserData userData = UserData.fromMap(map);
    return userData;
  }

  Future<UserData> getUserProfile(String sessionId, String userId) async {
    Map<String, dynamic> map =
        await _ethernet.getUserProfile(sessionId, userId);
    UserData userData = UserData.fromMap(map);
    return userData;
  }

  Future<BrandData> getBrandProfile(String sessionId, String uuid) async {
    Map<String, dynamic> map = await _ethernet.getBrandProfile(sessionId, uuid);
    BrandData brandData = BrandData.fromMap(map);
    return brandData;
  }

  Future<bool> replyIsApplied(String sessionId, String challengeId) async {
    final String response =
        await _ethernet.replyIsApplied(sessionId, challengeId);
    if (response == 'OK') {
      return false;
    } else if (response == 'ALREADY_APPLIED') {
      throw ChallengeApplicationNotUniqueException();
    } else if (response == 'NOT_ENOUGH_BALANCE_AMOUNT') {
      throw NotEnoughBalanceAmountException();
    } else {
      throw UnknownException();
    }
  }

  Future<CreateReply> createReply(String sessionId, String challengeId) async {
    Map<String, dynamic> map =
        await _ethernet.createReply(sessionId, challengeId);
    CreateReply createReply = CreateReply.fromMap(map);
    return createReply;
  }

  Future<List<Challenge>> getChallenges(Filter filter, String uid,
      int regionMask, int startPointId, int offset) async {
    print('regionMask = $regionMask');
    List<Challenge> result = [];
    String textFilter = filterToText(filter);
    var tempListMaps = await _ethernet.getChallenges(
        textFilter, uid, regionMask, startPointId, offset);
    List<ChallengeStatsInfo> tempStats = [];
    List<ChallengeModel> models = [];
    List<String> brandAvatarIds = [];
    for (Map<String, dynamic> map in tempListMaps) {
      models.add(ChallengeModel.fromMap(map['challenge']));
      tempStats.add(ChallengeStatsInfo.fromMap(map['stats']));
      brandAvatarIds.add(map['brand_avatar_id']);
    }
    print('brand id');
    //print(models[0].brandID);
    for (int i = 0; i < models.length; i++) {
      var value = Challenge(
        uuid: models[i].uuid,
        previewUuid: models[i].previewID,
        challengeType: models[i].challengeInfo.challengeType,
        brandId: models[i].brandID,
        challengeDifficulty: models[i].challengeInfo.challengeDifficulty,
        brandAvatarId: brandAvatarIds[i],
        awardPreviewId: models[i].awardPreviewId,
        name: models[i].challengeInfo.name,
        about: models[i].challengeInfo.about,
        publicationDate:
            DateTime.fromMillisecondsSinceEpoch(models[i].publicationTS * 1000),
        startDate: DateTime.fromMillisecondsSinceEpoch(
            models[i].challengeInfo.startTS * 1000),
        stopDate: DateTime.fromMillisecondsSinceEpoch(
            models[i].challengeInfo.stopTS * 1000),
        applicationCountLimit: models[i].challengeInfo.applicationCountLimit,
        applicationCount: tempStats[i].applicationsCountApproved,
        winnersCountLimit: models[i].challengeInfo.winnersCountLimit,
        winnersCount: tempStats[i].winnersCount,
        priority: models[i].challengeInfo.priority,
        coinsAmount: models[i].challengeInfo.userPayment,
      );
      result.add(value);
    }
    return result;
  }

  Future<List<Reply>> getReplies(String sid, Filter filter, String uid,
      int startPointId, int offset) async {
    List<Reply> result = [];
    var tempListMaps = await _ethernet.getReplies(
        sid, filterToText(filter), uid, startPointId, offset);
    for (Map<String, dynamic> map in tempListMaps) {
      result.add(Reply.fromMap(map));
    }
    return result;
  }

  Future<List<Reply>> getUserWinReplies(String sid, int offset) async {
    List<Reply> result = [];
    var tempListMaps = await _ethernet.getUserWinReplies(sid, offset);
    for (Map<String, dynamic> map in tempListMaps) {
      result.add(Reply.fromMap(map));
    }
    return result;
  }

  Future<List<Reply>> getUserWaitingReplies(String sid, int offset) async {
    List<Reply> result = [];
    var tempListMaps = await _ethernet.getUserWaitingReplies(sid, offset);
    for (Map<String, dynamic> map in tempListMaps) {
      print(tempListMaps.first);
      result.add(Reply.fromMap(map));
    }
    return result;
  }

  Future<int> getApplicationStartPointId(
      String sessionId, Filter filter, String uid,
      [DateTime dateTime]) async {
    return await _ethernet.getApplicationStartPointId(
        sessionId, filterToText(filter), uid, dateTime);
  }

  Future<int> getStartPointId(String sessionId, Filter filter, String uid,
      [DateTime dateTime]) async {
    return await _ethernet.getStartPointId(
        sessionId, filterToText(filter), uid, dateTime);
  }

  Future<int> getBalanceStartPointId(String sessionId,
      [DateTime dateTime]) async {
    return await _ethernet.getBalanceStartPointId(sessionId);
  }

  Future<BalanceResponse> getBalance(String sessionId) async {
    Map<String, dynamic> map = await _ethernet.getBalance(sessionId);
    BalanceResponse balanceResponse = BalanceResponse.fromMap(map);
    return balanceResponse;
  }

  Future<void> confirmEmail(String sessionId, String email) async {
    await _ethernet.confirmEmail(sessionId, email);
  }

  Future<List<BalanceOperation>> getBalanceHistory(
      String sessionId, int startPointId, int offset) async {
    List<BalanceOperation> result = [];
    var tempListMaps =
        await _ethernet.getBalanceHistory(sessionId, startPointId, offset);
    for (Map<String, dynamic> map in tempListMaps) {
      result.add(BalanceOperation.fromMap(map));
    }
    return result;
  }

  Future<LikeResponse> updateLike(
      String sessionId, String applicationId, LikeStatus type) async {
    String action;
    if (type == LikeStatus.LIKE) {
      action = 'LIKE';
    } else {
      action = 'NOT_SET';
    }
    Map<String, dynamic> map =
        await _ethernet.setLike(sessionId, applicationId, action);

    LikeResponse likeResponse =
        LikeResponse(LikeModel.fromMap(map['like']), map['count']);
    return likeResponse;
  }

  Future<List<Region>> getRegions() async {
    List<Region> result = [];
    var tempListMaps = await _ethernet.getRegions();
    for (Map<String, dynamic> map in tempListMaps) {
      result.add(Region.fromJson(map));
    }
    return result;
  }
}
