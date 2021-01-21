import 'dart:convert';

import 'package:ichazy/domain/model/reply_data.dart';

class LikeModel {
  LikeModel({
    this.id,
    this.userId,
    this.applicationId,
    this.likeStatus,
    this.createTs,
    this.updateTs,
  });

  final String id;
  final String userId;
  final String applicationId;
  final LikeStatus likeStatus;
  final int createTs;
  final int updateTs;

  LikeModel copyWith({
    String id,
    String userId,
    String applicationId,
    LikeStatus likeStatus,
    int createTs,
    int updateTs,
  }) =>
      LikeModel(
        id: id ?? this.id,
        userId: userId ?? this.userId,
        applicationId: applicationId ?? this.applicationId,
        likeStatus: likeStatus ?? this.likeStatus,
        createTs: createTs ?? this.createTs,
        updateTs: updateTs ?? this.updateTs,
      );

  factory LikeModel.fromJson(String str) => LikeModel.fromMap(json.decode(str));

  factory LikeModel.fromMap(Map<String, dynamic> json) => LikeModel(
    id: json["id"],
    userId: json["user_id"],
    applicationId: json["application_id"],
    likeStatus: checkLike(json["action"]),
    createTs: json["create_ts"],
    updateTs: json["update_ts"],
  );
}

class LikeResponse {
  final LikeModel likeModel;
  final int value;
  LikeResponse(this.likeModel, this.value);
}