import 'dart:convert';
import 'dart:io';

import 'package:ichazy/data/api/cache/cache.dart';
import 'package:ichazy/domain/model/user.dart';

import 'brand.dart';

class Challenge {
  final String uuid;
  final String previewUuid;
  final ChallengeType challengeType;
  final ChallengeDifficulty challengeDifficulty;
  final String name;
  final String about;
  final DateTime publicationDate;
  final DateTime startDate;
  final DateTime stopDate;
  final Brand brand;
  final String brandId;
  final String brandAvatarId;
  final String awardPreviewId;
  final int applicationCountLimit;
  final int applicationCount;
  final int winnersCountLimit;
  final int winnersCount;
  final int priority;
  final User user;
  final int coinsAmount;

  Challenge({
    this.uuid,
    this.previewUuid,
    this.challengeType,
    this.challengeDifficulty,
    this.name,
    this.about,
    this.publicationDate,
    this.startDate,
    this.stopDate,
    this.brand,
    this.brandId,
    this.brandAvatarId,
    this.awardPreviewId,
    this.applicationCountLimit,
    this.applicationCount,
    this.winnersCountLimit,
    this.winnersCount,
    this.priority,
    this.user,
    this.coinsAmount,
  });

  Challenge copyWith({
    String uuid,
    String previewUuid,
    ChallengeType challengeType,
    ChallengeDifficulty challengeDifficulty,
    String name,
    String about,
    DateTime publicationDate,
    DateTime startDate,
    DateTime stopDate,
    Brand brand,
    String brandId,
    String brandAvatarId,
    String awardPreviewId,
    int applicationCountLimit,
    int applicationCount,
    int winnersCountLimit,
    int winnersCount,
    int priority,
    User user,
    int coinsAmount,
  }) =>
      Challenge(
        uuid: uuid ?? this.uuid,
        previewUuid: previewUuid ?? this.previewUuid,
        challengeType: challengeType ?? this.challengeType,
        challengeDifficulty: challengeDifficulty ?? this.challengeDifficulty,
        name: name ?? this.name,
        about: about ?? this.about,
        publicationDate: publicationDate ?? this.publicationDate,
        startDate: startDate ?? this.startDate,
        stopDate: stopDate ?? this.stopDate,
        brand: brand ?? this.brand,
        brandId: brandId ?? this.brandId,
        brandAvatarId: brandAvatarId ?? this.brandAvatarId,
        awardPreviewId: awardPreviewId ?? this.awardPreviewId,
        applicationCountLimit:
            applicationCountLimit ?? this.applicationCountLimit,
        applicationCount: applicationCount ?? this.applicationCount,
        priority: priority ?? this.priority,
        user: user ?? this.user,
        coinsAmount: coinsAmount ?? this.coinsAmount,
      );

  static Future<File> getFile(String id) async {
    return await Cache.getFile('${Cache.getUrl(id)}.mp4');
  }
}

class ChallengeModel {
  final String uuid;
  final int createTS;
  final int publicationTS;
  final bool isPublished;
  final bool isFinal;
  final bool isActive;
  final String brandID;
  final String previewID;
  final String awardPreviewId;
  final AwardTechInfo awardTechInfo;
  final ChallengeInfo challengeInfo;

  ChallengeModel(
      {this.uuid,
      this.createTS,
      this.publicationTS,
      this.isPublished,
      this.isFinal,
      this.isActive,
      this.brandID,
      this.previewID,
      this.awardPreviewId,
      this.awardTechInfo,
      this.challengeInfo});

  ChallengeModel copyWith({
    String uuid,
    int createTS,
    int publicationTS,
    bool isPublished,
    bool isFinal,
    bool isActive,
    String brandID,
    String previewID,
    String awardPreviewId,
    AwardTechInfo awardTechInfo,
    ChallengeInfo challengeInfo,
  }) =>
      ChallengeModel(
        uuid: this.uuid,
        createTS: this.createTS,
        publicationTS: publicationTS ?? this.publicationTS,
        isPublished: isPublished ?? this.isPublished,
        isFinal: isFinal ?? this.isFinal,
        isActive: isActive ?? this.isActive,
        brandID: brandID ?? this.brandID,
        previewID: previewID ?? this.previewID,
        awardPreviewId: awardPreviewId ?? this.awardPreviewId,
        awardTechInfo: awardTechInfo ?? this.awardTechInfo,
        challengeInfo: challengeInfo ?? this.challengeInfo,
      );

  static fromMap(Map<String, dynamic> json) => ChallengeModel(
        uuid: json["id"],
        createTS: json["create_ts"],
        publicationTS: json["publication_ts"],
        isPublished: json["is_published"],
        isFinal: json["is_final"],
        isActive: json["is_active"],
        brandID: json["brand_id"],
        previewID: json["preview_id"],
        awardPreviewId: json["award_preview_id"],
        awardTechInfo: AwardTechInfo.fromJson(json["award"]),
        challengeInfo: ChallengeInfo.fromJson(json["info"]),
      );
}

class ChallengeInfo {
  final ChallengeType challengeType;
  final ChallengeDifficulty challengeDifficulty;
  final int startTS;
  final int stopTS;
  final int priority;
  final String name;
  final String about;
  final int applicationCountLimit;
  final int winnersCountLimit;
  final int userPayment;

  ChallengeInfo({
    this.challengeType,
    this.challengeDifficulty,
    this.startTS,
    this.stopTS,
    this.priority,
    this.name,
    this.about,
    this.applicationCountLimit,
    this.winnersCountLimit,
    this.userPayment,
  });

  ChallengeInfo copyWith({
    ChallengeType challengeType,
    ChallengeDifficulty challengeDifficulty,
    int startTS,
    int stopTS,
    int priority,
    String name,
    String about,
    int applicationCountLimit,
    int winnersCountLimit,
    int userPayment,
  }) =>
      ChallengeInfo(
        challengeType: challengeType ?? this.challengeType,
        challengeDifficulty: challengeDifficulty ?? this.challengeDifficulty,
        startTS: startTS ?? this.startTS,
        stopTS: stopTS ?? this.stopTS,
        priority: priority ?? this.priority,
        name: name ?? this.name,
        about: about ?? this.about,
        applicationCountLimit:
            applicationCountLimit ?? this.applicationCountLimit,
        winnersCountLimit: winnersCountLimit ?? this.winnersCountLimit,
        userPayment: userPayment ?? this.userPayment,
      );

  static fromJson(Map<String, dynamic> json) => ChallengeInfo(
        challengeType: checkType(json["type"]),
        challengeDifficulty: _checkDifficulty(json["difficulty"]),
        startTS: json["start_ts"],
        stopTS: json["stop_ts"],
        priority: json["priority"],
        name: json["name"],
        about: json["about"],
        applicationCountLimit: json["applications_count_limit"],
        winnersCountLimit: json["winners_count_limit"],
        userPayment: json["user_payment"],
      );
}

class ChallengeStatsInfo {
  final int applicationsCount;
  final int applicationsCountApproved;
  final int winnersCount;

  ChallengeStatsInfo({
    this.applicationsCount,
    this.applicationsCountApproved,
    this.winnersCount,
  });

  ChallengeStatsInfo copyWith(
          {int applicationsCount,
          int applicationsCountApproved,
          int winnersCount}) =>
      ChallengeStatsInfo(
        applicationsCount: applicationsCount ?? this.applicationsCount,
        applicationsCountApproved:
            applicationsCountApproved ?? this.applicationsCountApproved,
        winnersCount: winnersCount ?? this.winnersCount,
      );

  static fromMap(Map<String, dynamic> json) => ChallengeStatsInfo(
        applicationsCount: json["applications_count"],
        applicationsCountApproved: json["applications_count_approved"],
        winnersCount: json["winners_count"],
      );
}

ChallengeSelectRequest challengeSelectRequestFromMap(String str) =>
    ChallengeSelectRequest.fromMap(json.decode(str));

String challengeSelectRequestToMap(ChallengeSelectRequest data) =>
    json.encode(data.toMap());

class ChallengeSelectRequest {
  ChallengeSelectRequest({
    this.method,
    this.sid,
    this.deviceUid,
    this.data,
  });

  String method;
  String sid;
  String deviceUid;
  Data data;

  factory ChallengeSelectRequest.fromMap(Map<String, dynamic> json) =>
      ChallengeSelectRequest(
        method: json["method"],
        sid: json["sid"],
        deviceUid: json["device_uid"],
        data: Data.fromMap(json["data"]),
      );

  Map<String, dynamic> toMap() => {
        "method": method,
        "sid": sid,
        "device_uid": deviceUid,
        "data": data.toMap(),
      };
}

class Data {
  Data({
    this.serializationId,
    this.type,
    this.startTs,
    this.limit,
    this.offset,
  });

  String serializationId;
  String type;
  int startTs;
  int limit;
  int offset;

  factory Data.fromMap(Map<String, dynamic> json) => Data(
        serializationId: json["@"],
        type: json["type"],
        startTs: json["start_ts"],
        limit: json["limit"],
        offset: json["offset"],
      );

  Map<String, dynamic> toMap() => {
        "@": serializationId,
        "type": type,
        "start_ts": startTs,
        "limit": limit,
        "offset": offset,
      };
}

class AwardTechInfo {
  final String balanceID;
  final String promocodesListId;
  final AwardInfo challengeAwardInfo;

  AwardTechInfo({
    this.balanceID,
    this.promocodesListId,
    this.challengeAwardInfo,
  });

  AwardTechInfo copyWith({
    String balanceID,
    String promocodesListId,
    AwardInfo challengeAwardInfo,
  }) =>
      AwardTechInfo(
        balanceID: balanceID ?? this.balanceID,
        promocodesListId: promocodesListId ?? this.promocodesListId,
        challengeAwardInfo: challengeAwardInfo ?? this.challengeAwardInfo,
      );

  static fromJson(Map<String, dynamic> json) => AwardTechInfo(
        balanceID: json["balance_id"],
        promocodesListId: json["promocodes_list_id"],
        challengeAwardInfo: AwardInfo.fromJson(json["info"]),
      );
}

class AwardInfo {
  final AwardPromoCodeMode awardPromoCodeMode;
  final bool useCoins;
  final bool usePromoCodes;
  final List<dynamic> coinsDistribution;
  final int coinsReserved;

  AwardInfo({
    this.awardPromoCodeMode,
    this.useCoins,
    this.usePromoCodes,
    this.coinsDistribution,
    this.coinsReserved,
  });

  AwardInfo copyWith({
    AwardPromoCodeMode awardPromoCodeMode,
    bool useCoins,
    bool usePromoCodes,
    List<int> coinsDistribution,
    int coinsReserved,
  }) =>
      AwardInfo(
        awardPromoCodeMode: awardPromoCodeMode ?? this.awardPromoCodeMode,
        useCoins: useCoins ?? this.useCoins,
        usePromoCodes: usePromoCodes ?? this.usePromoCodes,
        coinsDistribution: coinsDistribution ?? this.coinsDistribution,
        coinsReserved: coinsReserved ?? this.coinsReserved,
      );

  static fromJson(Map<String, dynamic> json) => AwardInfo(
        awardPromoCodeMode: checkMode(json["promocode_mode"]),
        useCoins: json["use_coins"],
        usePromoCodes: json["use_promocodes"],
        coinsDistribution: json["coins_distribution"],
        coinsReserved: json["coins_reserved"],
      );
}

ChallengeType checkType(String type) {
  print(type);
  if (type == 'SURVEY') {
    return ChallengeType.SURVEY;
  } else if (type == 'IMAGE') {
    return ChallengeType.IMAGE;
  } else if (type == 'VIDEO') {
    return ChallengeType.VIDEO;
  } else {
    throw Exception('checkType');
  }
}

AwardPromoCodeMode checkMode(String mode) {
  if (mode == 'SHARED') {
    return AwardPromoCodeMode.SHARED;
  } else if (mode == 'UNIQUE') {
    return AwardPromoCodeMode.UNIQUE;
  } else if (mode == 'NO') {
    return AwardPromoCodeMode.NO;
  } else {
    throw Exception('_checkMode');
  }
}

ChallengeDifficulty _checkDifficulty(String difficulty) {
  if (difficulty == 'EASY') {
    return ChallengeDifficulty.EASY;
  } else if (difficulty == 'NORMAL') {
    return ChallengeDifficulty.NORMAL;
  } else if (difficulty == 'HARD') {
    return ChallengeDifficulty.HARD;
  } else {
    throw Exception('_checkDifficulty');
  }
}

String filterToText(Filter filter) {
  if (filter == Filter.ALL_APPLICATIONS) {
    return 'ALL_APPLICATIONS';
  } else if (filter == Filter.ALL_ACTIVE_BY_REGIONS) {
    return 'ALL_ACTIVE_BY_REGIONS';
  } else if (filter == Filter.BY_BRAND) {
    return 'ALL_ACTIVE_BY_REGIONS';
  } else if (filter == Filter.BY_CHALLENGE) {
    return 'BY_CHALLENGE';
  } else if (filter == Filter.BY_USER) {
    return 'BY_USER';
  } else if (filter == Filter.BY_ID) {
    return 'BY_ID';
  } else
    throw Exception('filterToText');
}

enum Filter {
  ALL_APPLICATIONS,
  ALL_ACTIVE_BY_REGIONS,
  ALL_BRANDS,
  BY_BRAND,
  BY_CHALLENGE,
  BY_USER,
  BY_ID
}

enum AwardPromoCodeMode { SHARED, UNIQUE, NO }

enum ChallengeType { IMAGE, VIDEO, SURVEY }

enum ChallengeDifficulty { EASY, NORMAL, HARD }
