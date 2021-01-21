import 'dart:convert';

class BalanceResponse {
  BalanceResponse({
    this.id,
    this.brandId,
    this.challengeId,
    this.userId,
    this.coinTypeId,
    this.createTs,
    this.balanceValue,
  });

  final String id;
  final String brandId;
  final String challengeId;
  final String userId;
  final String coinTypeId;
  final int createTs;
  final int balanceValue;

  BalanceResponse copyWith({
    String id,
    String brandId,
    String challengeId,
    String userId,
    String coinTypeId,
    int createTs,
    int balanceValue,
  }) =>
      BalanceResponse(
        id: id ?? this.id,
        brandId: brandId ?? this.brandId,
        challengeId: challengeId ?? this.challengeId,
        userId: userId ?? this.userId,
        coinTypeId: coinTypeId ?? this.coinTypeId,
        createTs: createTs ?? this.createTs,
        balanceValue: balanceValue ?? this.balanceValue,
      );

  factory BalanceResponse.fromJson(String str) =>
      BalanceResponse.fromMap(json.decode(str));

  factory BalanceResponse.fromMap(Map<String, dynamic> json) => BalanceResponse(
        id: json["id"],
        brandId: json["brand_id"],
        challengeId: json["challenge_id"],
        userId: json["user_id"],
        coinTypeId: json["coin_type_id"],
        createTs: json["create_ts"],
        balanceValue: json["balance"],
      );
}

class BalanceOperation {
  BalanceOperation({
    this.id,
    this.linkedTxId,
    this.userId,
    this.balanceId,
    this.createTs,
    this.value,
    this.reason,
  });

  final String id;
  final String linkedTxId;
  final String userId;
  final String balanceId;
  final int createTs;
  final int value;
  final Reason reason;

  BalanceOperation copyWith({
    String id,
    String linkedTxId,
    String userId,
    String balanceId,
    int createTs,
    int value,
    Reason reason,
  }) =>
      BalanceOperation(
        id: id ?? this.id,
        linkedTxId: linkedTxId ?? this.linkedTxId,
        userId: userId ?? this.userId,
        balanceId: balanceId ?? this.balanceId,
        createTs: createTs ?? this.createTs,
        value: value ?? this.value,
        reason: reason ?? this.reason,
      );

  factory BalanceOperation.fromJson(String str) =>
      BalanceOperation.fromMap(json.decode(str));

  //String toJson() => json.encode(toMap());

  factory BalanceOperation.fromMap(Map<String, dynamic> json) =>
      BalanceOperation(
        id: json["id"],
        linkedTxId: json["linked_tx_id"],
        userId: json["user_id"],
        balanceId: json["balance_id"],
        createTs: json["create_ts"],
        value: json["value"],
        reason: checkReason(json["reason"]),
      );

  // Map<String, dynamic> toMap() => {
  //       "id": id,
  //       "linked_tx_id": linkedTxId,
  //       "user_id": userId,
  //       "balance_id": balanceId,
  //       "create_ts": createTs,
  //       "value": value,
  //       "reason": reason,
  //     };

  static String reasonToText(Reason reason) {
    if (reason == Reason.REWARD_FOR_APPLICATION) {
      return 'Начисление монет за победу: ';
    } else if (reason == Reason.PAYMENT_FOR_APPLICATION) {
      return 'Списание монет за участие: ';
    } else if (reason == Reason.RETURN_FOR_APPLICATION) {
      return 'Возврат монет за участие: ';
    } else if (reason == Reason.PAYMENT_FOR_CHALLENGE) {
      return 'Плата за создание челленджа: ';
    } else if (reason == Reason.EMISSION) {
      return 'Начисление монет от iChazy: ';
    } else
      throw Exception('reasonToText');
  }

  static Reason checkReason(String reason) {
    if (reason == 'EMISSION') {
      return Reason.EMISSION;
    } else if (reason == 'REWARD_FOR_APPLICATION') {
      return Reason.REWARD_FOR_APPLICATION;
    } else if (reason == 'PAYMENT_FOR_APPLICATION') {
      return Reason.PAYMENT_FOR_APPLICATION;
    } else if (reason == 'RETURN_FOR_APPLICATION') {
      return Reason.RETURN_FOR_APPLICATION;
    } else if (reason == 'PAYMENT_FOR_CHALLENGE') {
      return Reason.PAYMENT_FOR_CHALLENGE;
    } else
      throw Exception('checkReason');
  }
}

enum Reason {
  EMISSION,
  REWARD_FOR_APPLICATION,
  PAYMENT_FOR_APPLICATION,
  RETURN_FOR_APPLICATION,
  PAYMENT_FOR_CHALLENGE,
}
