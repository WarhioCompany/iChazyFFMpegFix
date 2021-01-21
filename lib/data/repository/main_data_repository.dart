import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:ichazy/data/api/api_util.dart';
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
import 'package:ichazy/domain/repository/main_repository.dart';

import '../util.dart';

class MainDataRepository extends MainRepository {
  final ApiUtil _apiUtil;
  final Util _util;

  MainDataRepository(this._util, this._apiUtil);

  @override
  Future<void> connect([String email, String password]) async {
    await _util.connect(email, password);
  }

  @override
  void addLogString(String newLog) {
    _util.addLogString(newLog);
  }

  @override
  String getLog() {
    return _util.getLog();
  }

  @override
  Future<void> disconnect() async {
    await _util.disconnect();
    return;
  }

  @override
  Future<List<Auth>> getUserAuth() async {
    return await _util.getUserAuth();
  }

  @override
  Future<List<Award>> getUserRewards(bool isUsed, int offset) async {
    return await _util.getUserRewards(isUsed, offset);
  }

  @override
  Future<void> restoreAuth(String id) async {
    await _apiUtil.restoreAuth(id);
  }

  @override
  Future<bool> checkSession() async {
    Session session = await _util.getSession();
    await _util.getProfile();
    if (session.id == null || session.id == '') {
      return false;
    }
    print(session.sid);
    return true;
  }

  @override
  Future<List<Region>> getRegions() async {
    return await _apiUtil.getRegions();
  }

  @override
  Future<File> compressVideo(File file) async {
    return await _util.compressVideo(file);
  }

  @override
  Future<Award> setIsUsedPromoCode(String promoCodeId, bool isUsed) async {
    return await _util.setIsUsedPromoCode(promoCodeId, isUsed);
  }

  @override
  Future<Reply> getReply(String replyId) async {
    return await _util.getReply(replyId);
  }

  @override
  Future<void> register(
      String primaryId, String secret, String nickname, String regionId) async {
    await _util.register(primaryId, secret, nickname, regionId);
  }

  @override
  Future<List<BalanceOperation>> getBalanceHistory(
      int startPointId, int offset) async {
    return await _util.getBalanceHistory(startPointId, offset);
  }

  @override
  Future<int> getBalance() async {
    return await _util.getBalance();
  }

  @override
  Future<LikeResponse> updateLike(String applicationId, LikeStatus type) async {
    return await _util.updateLike(applicationId, type);
  }

  @override
  Future<User> getLocalProfile() async {
    return await _util.getLocalProfile();
  }

  @override
  Future<User> getUserProfile(String userId) async {
    return await _util.getUserProfile(userId);
  }

  @override
  Future<Brand> getBrandProfile(String brandId) async {
    return await _util.getBrandProfile(brandId);
  }

  @override
  Future<User> refreshProfile() async {
    return await _util.refreshProfile();
  }

  @override
  Future<void> setAvatar(File file) async {
    await _util.setAvatar(file);
  }

  @override
  Future<void> uploadPhoto(String challengeId, File file) async {
    await _util.uploadPhoto(challengeId, file);
  }

  @override
  Future<void> uploadVideo(String challengeId, File file) async {
    await _util.uploadVideo(challengeId, file);
  }

  @override
  Future<File> getImageFromGallery() async {
    File file = await _util.getImageFromGallery();
    file = await _util.cropImage(file);
    file = await _util.compressImage(file);
    return file;
  }

  @override
  Future<File> getVideoFromGallery() async {
    File file = await _util.getVideoFromGallery();
    return file;
  }

  @override
  Future<List<Reply>> getUserWinReplies(int offset) async {
    return await _util.getUserWinReplies(offset);
  }

  @override
  Future<List<Reply>> getUserWaitingReplies(int offset) async {
    return await _util.getUserWaitingReplies(offset);
  }

  @override
  Future<bool> replyIsApplied(String challengeId) async {
    return await _util.replyIsApplied(challengeId);
  }

  @override
  Future<File> recordPhoto(BuildContext context) async {
    File file = await _util.recordPhoto(context);
    file = await _util.cropImage(file);
    file = await _util.compressImage(file);
    return file;
  }

  @override
  Future<File> recordVideo(BuildContext context) async {
    File file = await _util.recordVideo(context);
    return file;
  }

  @override
  Future<CreateReply> createReply(String challengeId) async {
    return await _util.createReply(challengeId);
  }

  @override
  Future<void> newCode() {
    return _util.newCode();
  }

  @override
  Future<void> confirm() {
    return _apiUtil.confirm();
  }

  //удаление аккаунта 2 фазы
  //отмена удаления аккаунта
  @override
  Future<User> editAccount(User user) async {
    return await _util.editAccount(user);
  }

  @override
  Future<bool> checkValue(User user) {
    return _util.checkValue(user);
  } // изменить на проверку значения

  @override
  Future<void> deleteSession() {
    return _util.deleteSession();
  }

  @override
  Future<void> confirmEmail(String email) async {
    await _util.confirmEmail(email);
  }

  @override
  Future<List<Challenge>> getChallenges(
      Filter filter, String uid, int startPointId, int offset) async {
    final user = await _util.getLocalProfile();
    return _util.getChallenges(
        filter, uid, user?.regionMask ?? 255, startPointId, offset);
  }

  @override
  Future<List<Reply>> getReplies(
      Filter filter, String uid, int startPointId, int offset) {
    return _util.getReplies(filter, uid, startPointId, offset);
  }

  @override
  Future<int> getApplicationStartPointId(Filter filter, String uid,
      [DateTime dateTime]) {
    return _util.getApplicationStartPointId(filter, uid, dateTime);
  }

  @override
  Future<int> getStartPointId(Filter filter, String uid, [DateTime dateTime]) {
    return _util.getStartPointId(filter, uid, dateTime);
  }

  @override
  Future<void> replyCancel(String challengeId) async {
    await _util.replyCancel(challengeId);
  }

  @override
  Future<int> getBalanceStartPointId() {
    return _util.getBalanceStartPointId();
  }

  @override
  Future<File> getFile(String uuid, ChallengeType previewType,
      [bool thumb = false]) {
    //TODO реализовать прогрессбар
    return _util.getFile(uuid, previewType, thumb);
  }
}
