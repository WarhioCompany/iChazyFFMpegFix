import 'dart:convert';

import 'package:dio/dio.dart' hide Headers;
import 'package:ichazy/data/api/ethernet/response.dart';

class Ethernet {
  static const String _url = 'https://api.ichazy.com/srv2/';
  bool debug = true;
  Dio _dio = Dio();

  Future<List<dynamic>> getChallenges(String textFilter, String uid,
      int regionMask, int startPointId, int offset) async {
    String json = '''
{
      "method": "challenge_select",
      "sid": null,
      "data": {
        "usage": "$textFilter",
        "uid": "$uid",
        "regions_mask":$regionMask,
        "start_point_id": $startPointId,
        "limit": 10,
        "offset": $offset
      }
}
    ''';
    print(json);
    List<dynamic> temp = await _get(json);
    return temp;
  }

  Future<List<dynamic>> getUserAuth(String sessionId) async {
    String json = '''
{
      "method": "user_select_auth",
      "sid": "$sessionId",
      "data": {
      }
}
    ''';

    Map<String, dynamic> temp = await post(json);
    return temp['data']['auth'];
  }

  Future<List<dynamic>> getReplies(String sessionId, String textFilter,
      String uid, int startPointId, int offset) async {
    String temp;
    if (sessionId == null) {
      temp = 'null';
    } else {
      temp = '"$sessionId"';
    }
    print('sessionId = $sessionId');
    print('temp = $temp');
    String json = '''
{
      "method": "application_select",
      "sid": $temp,
      "data": {
        "usage":"$textFilter",
        "uid": "$uid",
        "start_point_id": $startPointId,
        "limit": 10,
        "offset": $offset
      }
}
    ''';
    return await _get(json);
  }

  Future<Map<String, dynamic>> getReply(
      String sessionId, String replyId) async {
    String temp;
    if (sessionId == null) {
      temp = 'null';
    } else {
      temp = '"$sessionId"';
    }
    print('sessionId = $sessionId');
    print('temp = $temp');
    String json = '''
{
      "method": "application_select",
      "sid": $temp,
      "data": {
        "usage":"BY_ID",
        "uid": "$replyId",
        "start_point_id": 6,
        "limit": 1,
        "offset": 0
      }
}
    ''';
    List<dynamic> list = await _get(json);
    print(list);
    return list.first;
  }

  Future<void> getUploadInfo(String sessionId, String fileId) async {
    String json = '''
{
    "method":"file_upload_status",
    "sid":"$sessionId",
    "data":{
      "file_id":"$fileId"
    }
}
    ''';
    Map<String, dynamic> data = await post(json);
    print(data);
  }

  Future<Map<String, dynamic>> getProfile(String sessionId) async {
    String temp;
    if (sessionId == null) {
      temp = 'null';
    } else {
      temp = '"$sessionId"';
    }
    String json = '''
{
      "method": "user_info",
      "sid": $temp,
      "data": {
      }
}
    ''';

    Map<String, dynamic> data = await post(json);
    print(data);
    return data['data'];
  }

  Future<Map<String, dynamic>> setLike(
      String sessionId, String applicationId, String action) async {
    String json = '''
{
    "method":"application_like_update",
    "sid":"$sessionId",
    "data":{
        "application_id":"$applicationId",
        "action":"$action"
    }
}
    ''';
    Map<String, dynamic> data = await post(json);
    return data['data'];
  }

  Future<Map<String, dynamic>> getBalance(String sessionId) async {
    String json = '''
{
    "method":"user_balance",
    "sid":"$sessionId",
    "data":{}
}
    ''';
    Map<String, dynamic> data = await post(json);
    return data['data'];
  }

  Future<List<dynamic>> getBalanceHistory(
      String sessionId, int startPointId, int offset) async {
    String json = '''
{
    "method":"user_balance_txs",
    "sid":"$sessionId",
    "data":{
      "start_point_id":$startPointId,
      "limit":100,
      "offset":$offset
    }
}
    ''';
    return await _get(json);
  }

  Future<Map<String, dynamic>> getUserProfile(
      String sessionId, String uuid) async {
    String json = '''
{
    "method":"user_select",
    "sid":"$sessionId",
    "data":{
        "user_id":"$uuid"
    }
}
    ''';
    Map<String, dynamic> data = await post(json);
    return data['data'];
  }

  Future<void> confirmEmail(String sessionId, String email) async {
    String json = '''
{
    "method":"user_confirm_primary_id_stage1",
    "sid":"$sessionId",
    "ts":0,
    "args":null,
    "data":{
        "primary_id":"$email"
    }
}
    ''';
    await post(json);
    //return data['data'];
  }

  Future<Map<String, dynamic>> getBrandProfile(
      String sessionId, String uuid) async {
    String temp;
    if (sessionId == null) {
      temp = 'null';
    } else {
      temp = '"$sessionId"';
    }
    String json = '''
{
      "method": "brand_select",
      "sid": $temp,
      "data": {
        "usage":"BY_ID",
        "uid": "$uuid",
        "start_point_id":0,
        "limit":1
      }
}
    ''';
    Map<String, dynamic> data = await post(json);
    List tempList = data['data'];
    return tempList.first['brand'];
  }

  Future<Map<String, dynamic>> createReply(
      String sessionId, String challengeId) async {
    print('application_create');
    print(sessionId);
    String json = '''
{
      "method":"application_create",
      "sid":"$sessionId",
      "data":{
        "challenge_id":"$challengeId"
      }
}
    ''';

    Map<String, dynamic> data = await post(json);
    print('application_create = $data');
    return data['data'];
  }

  Future<int> getApplicationStartPointId(
      String sessionId, String textFilter, String uid,
      [DateTime dateTime]) async {
    int _dateTime;
    if (dateTime == null) {
      _dateTime = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    } else {
      _dateTime = dateTime.millisecondsSinceEpoch ~/ 1000;
    }
    String temp;
    if (sessionId == null) {
      temp = 'null';
    } else {
      temp = '"$sessionId"';
    }
    String json = '''
{
      "method": "application_select_start_point",
      "sid": $temp,
      "data": {
        "usage":"$textFilter",
        "uid": "$uid",
        "timestamp": $_dateTime
      }
}
    ''';
    Map<String, dynamic> data = await post(json);
    return data['data']['start_point_id'];
  }

  Future<int> getBalanceStartPointId(String sessionId,
      [DateTime dateTime]) async {
    int _dateTime;
    if (dateTime == null) {
      _dateTime = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    } else {
      _dateTime = dateTime.millisecondsSinceEpoch ~/ 1000;
    }
    String json = '''
{
      "method":"user_balance_txs_start_point",
      "sid":"$sessionId",
      "data":{
        "timestamp":$_dateTime
    }
}
    ''';
    Map<String, dynamic> data = await post(json);
    return data['data']['start_point_id'];
  }

  Future<int> getStartPointId(String sessionId, String textFilter, String uid,
      [DateTime dateTime]) async {
    int _dateTime;
    if (dateTime == null) {
      _dateTime = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    } else {
      _dateTime = dateTime.millisecondsSinceEpoch ~/ 1000;
    }
    String temp;
    if (sessionId == null) {
      temp = 'null';
    } else {
      temp = '"$sessionId"';
    }
    String json = '''
{
      "method": "challenge_select_start_point",
      "sid": $temp,
      "data": {
        "usage":"$textFilter",
        "uid":"$uid",
        "timestamp": $_dateTime
      }
}
    ''';
    Map<String, dynamic> data = await post(json);
    return data['data']['start_point_id'];
  }

  Future<Map<String, dynamic>> editAccount(String sessionId, String nickname,
      int birthdate, String sex, String regionId) async {
    String json = '''
{
    "method":"user_info_update",
    "sid":"$sessionId",
    "data":
    {
        "nickname":"$nickname",
        "birth_date":$birthdate,
        "sex_type":"$sex",
        "geo_region_id":"$regionId"
    }
}
    ''';
    Map<String, dynamic> data = await post(json);
    print(data.toString());
    return data['data'];
  }

  Future<Map<String, dynamic>> signUp(
      String primaryId, String secret, String nickname, String regionId) async {
    String json = '''
{ 
      "method": "user_sign_up", 
      "sid": "", 
      "data": { 
        "type": "EMAIL", 
        "primary_id": "$primaryId", 
        "secret": "$secret", 
        "nickname": "$nickname", 
        "birth_date": 0, 
        "is_accept_license_agreement": true,
        "geo_region_id": "$regionId"
      } 
} 
    ''';
    Map<String, dynamic> data = await post(json);
    return data['data'];
  }

  Future<List<dynamic>> getUserWinReplies(String sessionId, int offset) async {
    String json = '''
{
  "method":"user_select_applications",
  "sid":"$sessionId",
  "data":{
    "states":["WIN"],
    "approve_states":["APPROVED"],
    "limit":10,
    "offset":$offset
  }
}
    ''';
    return await _get(json);
  }

  Future<List<dynamic>> getUserRewards(
      String sessionId, bool isUsed, int offset) async {
    String json = '''
{
  "method":"user_select_promo_codes",
  "sid":"$sessionId",
  "data":{
    "is_used":$isUsed,
    "limit":10,
    "offset":$offset
  }
}
    ''';
    return await _get(json);
  }

  Future<void> replyCancel(String sessionId, String challengeId) async {
    String json = '''
{
  "method":"application_cancel",
  "sid":"$sessionId",
  "data":{
    "challenge_id":"$challengeId"
  }
}
    ''';
    await post(json);
  }

  Future<Map<String, dynamic>> setIsUsedPromoCode(
      String sessionId, String promoCodeId, bool isUsed) async {
    String json = '''
{
  "method":"user_update_promo_code",
  "sid":"$sessionId",
  "data":{
    "promo_code_id":"$promoCodeId",
    "is_used":$isUsed
  }
}
    ''';
    Map<String, dynamic> data = await post(json);
    return data['data'];
  }

  Future<List<dynamic>> getUserWaitingReplies(
      String sessionId, int offset) async {
    String json = '''
{
  "method":"user_select_applications",
  "sid":"$sessionId",
  "data":{
    "states":["NEW", "APPLIED", "PROCESSING"],
    "approve_states":["APPROVED", "REJECTED", "NEW"],
    "limit":10,
    "offset":$offset
  }
}
    ''';
    return await _get(json);
  }

  Future<Map<String, dynamic>> signIn(String primaryId, String secret) async {
    String json = '''
{ 
      "method": "user_sign_in", 
      "sid": "", 
      "data": { 
        "primary_id": "$primaryId", 
        "secret": "$secret"
      } 
} 
    ''';
    Map<String, dynamic> data = await post(json);
    return data['data'];
  }

  Future<List<dynamic>> getRegions() async {
    String json = '''
{
      "method": "geo_region_select",
      "sid": "",
      "args": null,
      "data": {}
}
    ''';
    return await _get(json);
  }

  Future<Map<String, dynamic>> restoreAuth(String id) async {
    String json = '''
{
  "method":"user_restore_auth_secret",
  "args":null,
  "data":{
    "primary_id":"$id"
  }
}
    ''';
    Map<String, dynamic> data = await post(json);
    return data['data'];
  }

  Future<String> uploadAvatar(String sessionId, int fileSize) async {
    print('file_upload_new');
    print(sessionId);

    ///fileSize - bytes
    String json = '''
{
      "method":"file_upload_new",
      "sid":"$sessionId",
      "data":{
        "total_size":$fileSize,
        "type":"WEBP",
        "use_type":"AVATAR",
        "use_id":null,
        "hash":"F5E72E24332CEEEB0D0AF7303A885CBDE89585FD5EF29FA434CFEAD5779FD7EE",
        "chunk_size":524288
      }
}
    ''';
    Map<String, dynamic> data = await post(json);
    return data['data']['file_id'];
  }

  Future<String> uploadNewFile(String sessionId, String challengeId,
      int fileSize, String challengeType) async {
    ///challengeType - webp || webm
    print(sessionId);
    String json = '''
{
      "method":"file_upload_new",
      "sid":"$sessionId",
      "data":{
        "total_size":$fileSize,
        "type":"$challengeType",
        "use_type":"APPLICATION",
        "use_id":"$challengeId",
        "hash":"0000000000000000000000000000000000000000000000000000000000000000",
        "chunk_size":524288
      }
}
    ''';
    Map<String, dynamic> data = await post(json);
    return data['data']['file_id'];
  }

  Future<String> replyIsApplied(String sessionId, String challengeId) async {
    String json = '''
{
    "method":"application_is_applicable",
    "sid":"$sessionId",
    "data":{
      "challenge_id":"$challengeId"
    }
}
    ''';
    Map<String, dynamic> data = await post(json);
    print(data['data']);
    return data['data']['res'];
  }

  Future<Map<String, dynamic>> uploadFileChunk(
      String sessionId, String fileId, int chunkId, String hexData) async {
    String json = '''
{
    "method":"file_upload_chunk",
    "sid":"$sessionId",
    "data":
    {
        "file_id":"$fileId",
        "chunk_id":$chunkId,
        "data":"$hexData"
    }
}
    ''';
    Map<String, dynamic> data = await post(json);
    return data['data'];
  }

  Future<List<dynamic>> _get(String jsonString) async {
    Map<String, dynamic> temp = await post(jsonString);
    print(temp['data']);
    return temp['data'];
  }

  Future<Map<String, dynamic>> post(jsonString) async {
    if (debug) {
      print(jsonString);
    }
    ArgumentError.checkNotNull(jsonString, 'jsonString');
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _data = jsonString;
    final _result = await _dio.request<String>(_url,
        queryParameters: queryParameters,
        options: RequestOptions(
            method: 'POST',
            headers: <String, dynamic>{},
            extra: _extra,
            baseUrl: _url),
        data: _data);
    final value = _result.data;
    Map<String, dynamic> data = jsonDecode(value).cast<String, dynamic>();
    final String code = data['result']['code'];
    print(code);
    if (!CustomResponse.success.contains(code)) {
      print(data);
      if (CustomResponse.exceptions.containsKey(code)) {
        throw CustomResponse.exceptions[code];
      } else
        throw UnknownException();
    } else {
      print(data);
      return data;
    }
  }
}
