import 'dart:io';

import 'package:flutter/material.dart';
import 'package:ichazy/domain/model/auth.dart';
import 'package:ichazy/domain/model/award.dart';
import 'package:ichazy/domain/model/balance_response.dart';
import 'package:ichazy/domain/model/brand.dart';
import 'package:ichazy/domain/model/challenge.dart';
import 'package:ichazy/domain/model/create_reply_data.dart';
import 'package:ichazy/domain/model/like_model.dart';
import 'package:ichazy/domain/model/region.dart';
import 'package:ichazy/domain/model/reply_data.dart';

import '../model/user.dart';

abstract class MainRepository {
  Future<void> register(
      String primaryId, String secret, String nickname, String regionId);
  Future<void> connect([String email, String password]);
  Future<User> getLocalProfile();
  Future<User> getUserProfile(String userId);
  Future<Brand> getBrandProfile(String brandId);
  Future<User> refreshProfile();
  Future<List<Auth>> getUserAuth();
  Future<int> getBalanceStartPointId();
  Future<void> setAvatar(File file);
  Future<List<Reply>> getUserWaitingReplies(int offset);
  Future<List<Reply>> getUserWinReplies(int offset);
  Future<List<BalanceOperation>> getBalanceHistory(
      int startPointId, int offset);
  Future<int> getBalance();
  Future<List<Award>> getUserRewards(bool isUsed, int offset);
  Future<Reply> getReply(String replyId);
  Future<File> recordPhoto(BuildContext context);
  Future<File> recordVideo(BuildContext context);
  Future<void> uploadPhoto(String challengeId, File file);
  Future<void> uploadVideo(String challengeId, File file);
  Future<void> disconnect();
  Future<void> newCode();
  Future<List<Region>> getRegions();
  Future<void> restoreAuth(String id);
  Future<void> confirmEmail(String email);
  Future<bool> replyIsApplied(String challengeId);
  Future<Award> setIsUsedPromoCode(String promoCodeId, bool isUsed);
  Future<void> replyCancel(String challengeId);
  Future<User> editAccount(User user);
  Future<bool> checkValue(User user); // изменить на проверку значения
  Future<void> deleteSession();
  void addLogString(String newLog);
  String getLog();
  Future<bool> checkSession();
  //Future<List<Challenge>> userChallenges(User user);
  Future<File> getImageFromGallery();
  Future<File> getVideoFromGallery();
  Future<File> compressVideo(File file);
  Future<CreateReply> createReply(String challengeId);
  Future<List<Challenge>> getChallenges(
      Filter filter, String uid, int startPointId, int offset); // feed?
  Future<File> getFile(String uuid, ChallengeType previewType,
      [bool thumb = false]);
  Future<int> getStartPointId(Filter filter, String uid, [DateTime dateTime]);
  Future<int> getApplicationStartPointId(Filter filter, String uid,
      [DateTime dateTime]);

  Future<List<Reply>> getReplies(
      Filter filter, String uid, int startPointId, int offset);

  Future<LikeResponse> updateLike(String applicationId, LikeStatus type);
}
