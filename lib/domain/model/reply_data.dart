import 'dart:io';

import 'package:flutter/material.dart';
import 'package:ichazy/data/api/cache/cache.dart';
import 'package:ichazy/domain/model/challenge.dart';
import 'package:ichazy/domain/model/create_reply_data.dart';
import 'package:ichazy/domain/model/stats.dart';

class Reply {
  final CreateReply createReply;
  final Stats stats;
  final String userName;
  final String avatarUserId;
  final LikeStatus likeStatus;
  final String avatarBrandId;
  final String hashTag;
  final ChallengeType challengeType;

  Reply({
    this.createReply,
    this.stats,
    this.userName,
    this.avatarUserId,
    this.likeStatus,
    this.avatarBrandId,
    this.hashTag,
    this.challengeType,
  });

  Reply copyWith({
    CreateReply createReply,
    Stats stats,
    String userName,
    String avatarUserId,
    LikeStatus likeStatus,
    String avatarBrandId,
    String hashTag,
    ChallengeType challengeType,
  }) =>
      Reply(
        createReply: createReply ?? this.createReply,
        stats: stats ?? this.stats,
        userName: userName ?? this.userName,
        avatarUserId: avatarUserId ?? this.avatarUserId,
        likeStatus: likeStatus ?? this.likeStatus,
        avatarBrandId: avatarBrandId ?? this.avatarBrandId,
        hashTag: hashTag ?? this.hashTag,
        challengeType: challengeType ?? this.challengeType,
      );

  factory Reply.fromMap(Map<String, dynamic> json) => Reply(
        createReply: CreateReply.fromMap(json["application"]),
        stats: Stats.fromMap(json["stats"]),
        userName: json["user_name"],
        avatarUserId: json["user_avatar_id"],
        likeStatus: checkLike(json["self_like_action"]),
        avatarBrandId: json["brand_avatar_id"],
        hashTag: json["hash_tag"],
        challengeType: checkType(json["challenge_type"]),
      );

  Future<Image> getReplyImage() async {
    return await Cache.getImage('${Cache.getUrl(avatarUserId)}.webp');
  }

  Future<Image> getReplyPreview() async {
    if (challengeType == ChallengeType.VIDEO) {
      return await Cache.getImage(
          '${Cache.getUrl(createReply.fileId)}.preview.webp');
    }
    return await Cache.getImage('${Cache.getUrl(createReply.fileId)}.webp');
  }

  Future<File> getReplyVideo() async {
    print('fileId ${createReply.fileId}');
    return await Cache.getFile('${Cache.getUrl(createReply.fileId)}.mp4');
  }
}

LikeStatus checkLike(String likeStatus) {
  if (likeStatus == 'NOT_SET') {
    return LikeStatus.NOT_SET;
  } else if (likeStatus == 'LIKE') {
    return LikeStatus.LIKE;
  } else if (likeStatus == 'DISLIKE') {
    return LikeStatus.DISLIKE;
  } else {
    throw Exception('checkLike');
  }
}

enum LikeStatus {
  NOT_SET,
  LIKE,
  DISLIKE,
}
