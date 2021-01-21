import 'dart:convert';

import 'package:ichazy/data/time_helper.dart';

import 'challenge.dart';

class Award {
  Award({
    this.id,
    this.userId,
    this.listId,
    this.applicationId,
    this.challengeId,
    this.createDate,
    this.type,
    this.mode,
    this.isUsed,
    this.useDate,
    this.value,
    this.validTillDate,
    this.brandId,
    this.challengePreviewId,
    this.avatarBrandId,
    this.tag,
    this.challengeType,
  });

  final String id;
  final String userId;
  final String listId;
  final String applicationId;
  final String challengeId;
  final DateTime createDate;
  final AwardShowType type;
  final AwardPromoCodeMode mode;
  final bool isUsed;
  final DateTime useDate;
  final String value;
  final DateTime validTillDate;
  final String brandId;
  final String challengePreviewId;
  final String avatarBrandId;
  final String tag;
  final ChallengeType challengeType;

  Award copyWith({
    String id,
    String userId,
    String listId,
    String applicationId,
    String challengeId,
    DateTime createDate,
    String type,
    String mode,
    bool isUsed,
    DateTime useDate,
    String value,
    DateTime validTillDate,
    String brandId,
    String challengePreviewId,
    String avatarBrandId,
    String tag,
    ChallengeType challengeType,
  }) =>
      Award(
          id: id ?? this.id,
          userId: userId ?? this.userId,
          listId: listId ?? this.listId,
          applicationId: applicationId ?? this.applicationId,
          challengeId: challengeId ?? this.challengeId,
          createDate: createDate ?? this.createDate,
          type: type ?? this.type,
          mode: mode ?? this.mode,
          isUsed: isUsed ?? this.isUsed,
          useDate: useDate ?? this.useDate,
          value: value ?? this.value,
          validTillDate: validTillDate ?? this.validTillDate,
          brandId: brandId ?? this.brandId,
          challengePreviewId: challengePreviewId ?? this.challengePreviewId,
          avatarBrandId: avatarBrandId ?? this.avatarBrandId,
          tag: tag ?? this.tag,
          challengeType: challengeType ?? this.challengeType);

  factory Award.fromJson(String str) => Award.fromMap(json.decode(str));

  factory Award.fromMap(Map<String, dynamic> json) => Award(
        id: json["promo_code"]["id"],
        userId: json["promo_code"]["user_id"],
        listId: json["promo_code"]["list_id"],
        applicationId: json["promo_code"]["application_id"],
        challengeId: json["promo_code"]["challenge_id"],
        createDate: TimeHelper.intToDateTime(json["promo_code"]["create_ts"]),
        type: checkShowType(json["promo_code"]["type"]),
        mode: checkMode(json["promo_code"]["mode"]),
        isUsed: json["promo_code"]["is_used"],
        useDate: TimeHelper.intToDateTime(json["promo_code"]["use_ts"]),
        value: json["promo_code"]["value"],
        validTillDate:
            TimeHelper.intToDateTime(json["promo_code"]["valid_till_ts"]),
        brandId: json["brand_id"],
        avatarBrandId: json["brand_avatar_id"],
        challengePreviewId: json["challenge_preview_id"],
        //awardPreviewId: json["award_preview_id"],
        tag: json["hash_tag"],
        challengeType: checkType(json["challenge_type"]),
      );
}

AwardShowType checkShowType(String showType) {
  if (showType == 'STRING') {
    return AwardShowType.STRING;
  } else if (showType == 'EAN13') {
    return AwardShowType.EAN13;
  } else if (showType == 'QR_CODE') {
    return AwardShowType.QR_CODE;
  } else {
    throw Exception('checkShowType');
  }
}

enum AwardShowType { STRING, EAN13, QR_CODE }
