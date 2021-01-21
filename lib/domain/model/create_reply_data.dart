import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:ichazy/data/api/cache/cache.dart';

CreateReply createReplyDataFromMap(String str) =>
    CreateReply.fromMap(json.decode(str));

class CreateReply {
  CreateReply({
    this.id,
    //this.createTs,
    //this.publicationTs,
    //this.isPublished,
    this.brandId,
    this.challengeId,
    this.userId,
    this.winState,
    this.approveState,
    this.fileId,
    this.avatarId,
    this.tag,
  });

  final String id;
  //final int createTs;
  //final int publicationTs;
  //final bool isPublished;
  final String brandId;
  final String challengeId;
  final String userId;
  final WinState winState;
  final ApproveState approveState;
  final String fileId;
  final String avatarId;
  final String tag;

  CreateReply copyWith(
          {String id,
          //int createTs,
          //int publicationTs,
          //bool isPublished,
          String brandId,
          String challengeId,
          String userId,
          WinState state,
          ApproveState approveState,
          String fileId,
          String avatarId,
          String tag}) =>
      CreateReply(
        id: id ?? this.id,
        //createTs: createTs ?? this.createTs,
        //publicationTs: publicationTs ?? this.publicationTs,
        //isPublished: isPublished ?? this.isPublished,
        brandId: brandId ?? this.brandId,
        challengeId: challengeId ?? this.challengeId,
        userId: userId ?? this.userId,
        winState: state ?? this.winState,
        approveState: approveState ?? this.approveState,
        fileId: fileId ?? this.fileId,
        avatarId: avatarId ?? this.avatarId,
        tag: tag ?? this.tag,
      );

  factory CreateReply.fromMap(Map<String, dynamic> json) => CreateReply(
        id: json["id"],
        //createTs: json["create_ts"],
        //publicationTs: json["publication_ts"],
        //isPublished: json["is_published"],
        brandId: json["brand_id"],
        challengeId: json["challenge_id"],
        userId: json["user_id"],
        winState: _checkWinState(json["state"]),
        approveState: _checkApproveState(json["approve_state"]),
        fileId: json["file_id"],
        //TODO
      );

  Future<Image> getReplyImage() async {
    print(fileId);
    return await Cache.getImage('${Cache.getUrl(fileId)}.webp');
  }
}

WinState _checkWinState(String winState) {
  if (winState == 'NEW') {
    return WinState.NEW;
  } else if (winState == 'PROCESSING') {
    return WinState.PROCESSING;
  } else if (winState == 'APPLIED') {
    return WinState.APPLIED;
  } else if (winState == 'WIN') {
    return WinState.WIN;
  } else {
    throw Exception('_checkWinState');
  }
}

ApproveState _checkApproveState(String approveState) {
  if (approveState == 'NEW') {
    return ApproveState.NEW;
  } else if (approveState == 'APPROVED') {
    return ApproveState.APPROVED;
  } else if (approveState == 'REJECTED') {
    return ApproveState.REJECTED;
  } else {
    throw Exception('_checkApproveState');
  }
}

enum WinState { NEW, APPLIED, PROCESSING, WIN }

enum ApproveState { NEW, APPROVED, REJECTED }
