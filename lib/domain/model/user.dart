import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:ichazy/data/api/cache/cache.dart';

class User {
  final String id;
  final String nickname;
  final int birthday;
  final String avatarId;
  final int createDate;
  final Sex sex;
  final String regionId;
  final int regionMask;

  User(this.id, this.nickname, this.birthday, this.avatarId, this.createDate,
      this.sex, this.regionId, this.regionMask);

  static String userDefaultName() => '00000000-0000-0000-0000-000000000000';

  // "name": "user_11",
  // "surname": "user_sn",
  // "birthday": "1970-01-01",
  // "email": _emailController.text,
  // "password": _passwordController.text

  static User fromUserData(UserData userData) => User(
      userData.id,
      userData.nickname,
      userData.birthDate,
      userData.avatarId,
      userData.createTs,
      userData.sex,
      userData.regionId,
      userData.regionMask);

  factory User.fromMap(Map<String, dynamic> json) => User(
      json["id"],
      json["nickname"],
      json["birthday"],
      json["avatarId"],
      json["createDate"],
      checkSex(json["sex_type"]),
      json["geo_region_id"],
      json["geo_region_mask"]);

  Map<String, dynamic> toMap() => {
        "id": id,
        "nickname": nickname,
        "birthday": birthday,
        "avatarId": avatarId,
        "createDate": createDate,
        "sex_type": sexToString(sex),
        "geo_region_id": regionId,
        "geo_region_mask": regionMask,
      };

  Future<Image> getProfileImage() async {
    return await Cache.getImage('${Cache.getUrl(avatarId)}.webp');
  }
}

SignUp signUpFromMap(String str) => SignUp.fromMap(json.decode(str));

class SignUp {
  SignUp({
    this.data,
  });

  final Data data;

  factory SignUp.fromMap(Map<String, dynamic> json) => SignUp(
        data: Data.fromMap(json["data"]),
      );
}

class Data {
  Data({
    this.session,
    this.userData,
  });

  final Session session;
  final UserData userData;

  factory Data.fromMap(Map<String, dynamic> json) => Data(
        session: Session.fromMap(json["session"]),
        userData: UserData.fromMap(json["user"]),
      );
}

class Session {
  Session({
    this.id,
    this.userId,
    this.userAuthId,
    this.sid,
    this.createTs,
    this.validTillTs,
  });

  final String id;
  final String userId;
  final String userAuthId;
  final String sid;
  final int createTs;
  final int validTillTs;

  factory Session.fromMap(Map<String, dynamic> json) => Session(
        id: json["id"],
        userId: json["user_id"],
        userAuthId: json["user_auth_id"],
        sid: json["sid"],
        createTs: json["create_ts"],
        validTillTs: json["valid_till_ts"],
      );

  Map<String, dynamic> toMap() => {
        "id": id,
        "userId": userId,
        "userAuthId": userAuthId,
        "sid": sid,
        "createTs": createTs,
        "validTillTs": validTillTs,
      };
}

class UserData {
  UserData({
    this.id,
    this.avatarId,
    this.nickname,
    this.createTs,
    this.birthDate,
    this.sex,
    this.regionId,
    this.regionMask,
  });

  final String id;
  final String avatarId;
  final String nickname;
  final int createTs;
  final int birthDate;
  final Sex sex;
  final String regionId;
  final int regionMask;

  factory UserData.fromMap(Map<String, dynamic> json) => UserData(
        id: json["id"],
        avatarId: json["avatar_id"],
        nickname: json["nickname"],
        createTs: json["create_ts"],
        birthDate: json["birth_date"],
        sex: checkSex(json["sex_type"]),
        regionId: json["geo_region_id"],
        regionMask: json["geo_region_mask"],
        //isAcceptLicenseAgreement: json["is_accept_license_agreement"],
      );
}

class Result {
  Result({
    this.code,
    this.msg,
  });

  final String code;
  final String msg;

  factory Result.fromMap(Map<String, dynamic> json) => Result(
        code: json["code"],
        msg: json["msg"],
      );
}

class SignUpResponse {
  SignUpResponse({
    this.user,
    this.session,
  });

  final User user;
  final Session session;

  factory SignUpResponse.fromMap(Map<String, dynamic> json) => SignUpResponse(
        user: User.fromUserData(UserData.fromMap(json["user"])),
        session: Session.fromMap(json["session"]),
      );
}

UploadChunkResponse uploadChunkResponseFromMap(String str) =>
    UploadChunkResponse.fromMap(json.decode(str));

class UploadChunkResponse {
  UploadChunkResponse({
    this.id,
    this.userId,
    //this.type,
    //this.useType,
    this.challengeId,
    this.applicationId,
    this.createTs,
    this.status,
    this.totalSize,
    this.uploadedSize,
    this.uploadedChunks,
    this.chunkSize,
    this.hash,
  });

  final String id;
  final String userId;
  //final String type;
  //final String useType;
  final String challengeId;
  final String applicationId;
  final int createTs;
  final UploadStatus status;
  final int totalSize;
  final int uploadedSize;
  final int uploadedChunks;
  final int chunkSize;
  final String hash;

  factory UploadChunkResponse.fromMap(Map<String, dynamic> json) =>
      UploadChunkResponse(
        id: json["id"],
        userId: json["user_id"],
        //type: json["type"],
        //useType: json["use_type"],
        challengeId: json["challenge_id"],
        applicationId: json["application_id"],
        createTs: json["create_ts"],
        status: _checkUploadStatus(json["status"]),
        totalSize: json["total_size"],
        uploadedSize: json["uploaded_size"],
        uploadedChunks: json["uploaded_chunks"],
        chunkSize: json["chunk_size"],
        hash: json["hash"],
      );
}

UploadStatus _checkUploadStatus(String status) {
  if (status == 'IN_PROGRESS') {
    return UploadStatus.IN_PROGRESS;
  } else if (status == 'DONE') {
    return UploadStatus.DONE;
  } else if (status == 'HASH_ERROR') {
    return UploadStatus.HASH_ERROR;
  } else {
    throw Exception('_checkUploadStatus');
  }
}

Sex checkSex(String sex) {
  if (sex == 'NOT_SET') {
    return Sex.NOT_SET;
  } else if (sex == 'MALE') {
    return Sex.MALE;
  } else if (sex == 'FEMALE') {
    return Sex.FEMALE;
  } else {
    throw Exception('checkSex');
  }
}

String sexToString(Sex sex) {
  if (sex == Sex.NOT_SET) {
    return 'NOT_SET';
  } else if (sex == Sex.MALE) {
    return 'MALE';
  } else if (sex == Sex.FEMALE) {
    return 'FEMALE';
  } else {
    throw Exception('sexToString');
  }
}

enum Sex { NOT_SET, MALE, FEMALE }

enum UploadStatus { IN_PROGRESS, DONE, HASH_ERROR }
