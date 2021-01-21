import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:developer' as dev;
import 'package:camera_camera/camera_camera.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ffmpeg/flutter_ffmpeg.dart';
import 'package:flutter_ffmpeg/media_information.dart';
import 'package:flutter_ffmpeg/stream_information.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:ichazy/data/api/api_util.dart';
import 'package:ichazy/data/api/cache/cache.dart';
import 'package:ichazy/data/api/ethernet/response.dart';
import 'package:ichazy/data/api/shared_preferences/shared.dart';
import 'package:ichazy/domain/model/auth.dart';
import 'package:ichazy/domain/model/award.dart';
import 'package:ichazy/domain/model/balance_response.dart';
import 'package:ichazy/domain/model/brand.dart';
import 'package:ichazy/domain/model/challenge.dart';
import 'package:ichazy/domain/model/create_reply_data.dart';
import 'package:ichazy/domain/model/like_model.dart';
import 'package:ichazy/domain/model/reply_data.dart';
import 'package:ichazy/domain/model/user.dart';
import 'package:ichazy/presentation/record_video_screen.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Util {
  ApiUtil _apiUtil = ApiUtil();
  final FlutterFFmpeg _flutterFFmpeg = new FlutterFFmpeg();
  final FlutterFFprobe _flutterFFprobe = new FlutterFFprobe();
  int oldFileSize;
  int newFileSize;

  Session _session;
  String _log = '';

  Future<List<Challenge>> getChallenges(Filter filter, String uid,
      int regionMask, int startPointId, int offset) async {
    var result = await _apiUtil.getChallenges(
        filter, uid, regionMask, startPointId, offset);
    return result;
  }

  Future<List<Reply>> getReplies(
      Filter filter, String uid, int startPointId, int offset) async {
    Session session = await getSession();
    var result = await _apiUtil.getReplies(
        session.sid, filter, uid, startPointId, offset);
    return result;
  }

  Future<List<Challenge>> userChallenges(User user) async {}

  Future<void> register(
      [String email, String password, String nickname, String regionId]) async {
    SignUpResponse response =
        await _apiUtil.register(email, password, nickname, regionId);
    SharedPreferences prefs = Preferences().getInstance;
    await setShared('localProfile', jsonEncode(response.user.toMap()));
    await setSession(response.session);
    await prefs.reload();
  }

  Future<void> connect([String email, String password]) async {
    if (email != null && password != null) {
      SharedPreferences prefs = Preferences().getInstance;
      Session session = await _apiUtil.connect(email, password);
      print(session.sid);
      await setSession(session);
      await prefs.reload();
      User user = await getProfile();
      await setShared('localProfile', jsonEncode(user.toMap()));
    } else {
      print('connect null');
    }
  }

  Future<User> getLocalProfile() async {
    String localProfile = await getShared('localProfile');
    print('localProfile');
    print(localProfile);
    if (localProfile == null) return null;
    User user = User.fromMap(jsonDecode(localProfile));
    return user;
  }

  Future<User> refreshProfile() async {
    User user = await getProfile();
    await setShared('localProfile', jsonEncode(user.toMap()));
    return user;
  }

  Future<void> setAvatar(File file) async {
    Session session = await getSession();
    await _apiUtil.setAvatar(session.sid, file);
  }

  Future<void> uploadPhoto(String challengeId, File file) async {
    Session session = await getSession();
    await _apiUtil.uploadPhoto(session.sid, challengeId, file);
  }

  Future<void> uploadVideo(String challengeId, File file) async {
    Session session = await getSession();
    await _apiUtil.uploadVideo(session.sid, challengeId, file);
  }

  Future<User> editAccount(User user) async {
    Session session = await getSession();
    User newUser = await _apiUtil.editAccount(session.sid, user);
    setShared('localProfile', jsonEncode(newUser.toMap()));
    return newUser;
  }

  Future<User> getProfile() async {
    Session session = await getSession();
    String sessionId = session.sid;
    print(sessionId);
    UserData userData = await _apiUtil.getProfile(sessionId);
    User user = User.fromUserData(userData);
    return user;
  }

  Future<Reply> getReply(String replyId) async {
    Session session = await getSession();
    return await _apiUtil.getReply(session.sid, replyId);
  }

  Future<User> getUserProfile(String userId) async {
    Session session = await getSession();
    String sessionId = session.sid;
    print(sessionId);
    UserData userData = await _apiUtil.getUserProfile(sessionId, userId);
    User user = User.fromUserData(userData);
    return user;
  }

  Future<Brand> getBrandProfile(String uuid) async {
    Session session = await getSession();
    String sessionId = session.sid;
    print(sessionId);
    BrandData brandData = await _apiUtil.getBrandProfile(sessionId, uuid);
    Brand brand = Brand.fromBrandData(brandData);
    return brand;
  }

  Future<void> disconnect() async {
    SharedPreferences prefs = Preferences().getInstance;
    await prefs.remove('localProfile');
    await prefs.remove('currentSession');
    _session = null;
    return;
  }

  Future<void> newCode() {
    //
  }

  Future<bool> checkValue(User user) async {
    return true;
  } // изменить на проверку значения

  Future<void> deleteSession() {
    //
  }

  void addLogString(String newLog) {
    _log += '\n$newLog';
  }

  String getLog() {
    return _log;
  }

  Future<List<Auth>> getUserAuth() async {
    Session session = await getSession();
    return await _apiUtil.getUserAuth(session.sid);
  }

  Future<List<Award>> getUserRewards(bool isUsed, int offset) async {
    Session session = await getSession();
    return await _apiUtil.getUserRewards(session.sid, isUsed, offset);
  }

  Future<int> getApplicationStartPointId(Filter filter, String uid,
      [DateTime dateTime]) async {
    Session session = await getSession();
    return await _apiUtil.getApplicationStartPointId(
        session.sid, filter, uid, dateTime);
  }

  Future<int> getStartPointId(Filter filter, String uid,
      [DateTime dateTime]) async {
    Session session = await getSession();
    return await _apiUtil.getStartPointId(session.sid, filter, uid, dateTime);
  }

  Future<int> getBalanceStartPointId() async {
    Session session = await getSession();
    return await _apiUtil.getBalanceStartPointId(session.sid);
  }

  Future<void> confirmEmail(String email) async {
    Session session = await getSession();
    await _apiUtil.confirmEmail(session.sid, email);
  }

  Future<Award> setIsUsedPromoCode(String promoCodeId, bool isUsed) async {
    Session session = await getSession();
    return await _apiUtil.setIsUsedPromoCode(session.sid, promoCodeId, isUsed);
  }

  Future<List<BalanceOperation>> getBalanceHistory(
      int startPointId, int offset) async {
    Session session = await getSession();
    return await _apiUtil.getBalanceHistory(session.sid, startPointId, offset);
  }

  setSession(Session session) async {
    await setShared('currentSession', jsonEncode(session.toMap()));
    _session = session;
  }

  Future<CreateReply> createReply(String challengeId) async {
    Session session = await getSession();
    var reply = await _apiUtil.createReply(session.sid, challengeId);
    return reply;
  }

  Future<Session> getSession() async {
    if (_session == null) {
      String json = await getShared('currentSession');
      if (json == null) {
        return Session();
      }
      _session = Session.fromMap(jsonDecode(json));
      return _session;
    } else {
      return _session;
    }
  }

  Future<void> setShared(String key, String value) async {
    SharedPreferences prefs = Preferences().getInstance;
    return await prefs.setString(key, value);
  }

  Future<String> getShared(String key) async {
    SharedPreferences prefs = Preferences().getInstance;
    return prefs.getString(key);
  }

  Future<File> getImageFromGallery() async {
    FilePickerResult result =
        await FilePicker.platform.pickFiles(type: FileType.image);
    if (result == null) {
      throw CancelException();
    }
    return File(result.files.single.path);
  }

  Future<File> getVideoFromGallery() async {
    FilePickerResult result =
        await FilePicker.platform.pickFiles(type: FileType.video);
    if (result == null) {
      throw CancelException();
    }
    return File(result.files.single.path);
  }

  Future<File> cropImage(File file) async {
    File croppedFile = await ImageCropper.cropImage(
      sourcePath: file.path,
      aspectRatio: CropAspectRatio(ratioX: 1, ratioY: 1),
    );
    if (croppedFile == null) {
      throw CancelException();
    }
    return croppedFile;
  }

  Future<bool> replyIsApplied(String challengeId) async {
    Session session = await getSession();
    return await _apiUtil.replyIsApplied(session.sid, challengeId);
  }

  Future<File> compressImage(File file) async {
    var temp = await getTemporaryDirectory();
    var result = await FlutterImageCompress.compressAndGetFile(
      file.absolute.path,
      '${temp.path}/temp.webp',
      quality: 10,
      format: CompressFormat.webp,
    );
    print('before: ${file.lengthSync()}');
    print('after: ${result.lengthSync()}');
    return result;
  }

  Future<void> replyCancel(String challengeId) async {
    Session session = await getSession();
    await _apiUtil.replyCancel(session.sid, challengeId);
  }

  Future<File> compressVideo(File file) async {
    dev.log('Compress Video!');
    if (file == null) {
      throw CancelException();
    }
    //var temp = await getTemporaryDirectory();
    //
    MediaInformation info =
        await _flutterFFprobe.getMediaInformation(file.absolute.path);
    if (info.getStreams() == null) {
      throw Exception();
    }

    List<StreamInformation> prop = info.getStreams();
    int width = prop.first.getAllProperties()['width'];
    int height = prop.first.getAllProperties()['height'];

    dev.log('$width $height');
    int result;
    if (width < 600 || height < 600) {
      if (width < height) {
        result = await _flutterFFmpeg.execute(
            '-i ${file.absolute.path} -b:v 50k -filter:v "crop=iw:iw:0:0" -y ${file.absolute.path}.mp4');
      } else {
        result = await _flutterFFmpeg.execute(
            '-i ${file.absolute.path} -b:v 50k -filter:v "crop=ih:ih:0:0" -y ${file.absolute.path}.mp4');
      }
    } else {
      result = await _flutterFFmpeg.execute(
          '-i ${file.absolute.path} -b:v 50k -filter:v "crop=600:600:0:0" -y ${file.absolute.path}.mp4');
    }

    dev.log(result.toString());
    if (result != 0) {
      throw Exception('Ошибка компрессии');
    }
    return File("${file.absolute.path}.mp4");
  }

  Future<File> recordPhoto(BuildContext context) async {
    File file = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => Camera(
                  mode: CameraMode.normal,
                )));
    return file;
  }

  Future<File> recordVideo(BuildContext context) async {
    Video();
    File file = await Navigator.push(
        context, MaterialPageRoute(builder: (context) => RecordVideoScreen()));
    if (file == null) throw CancelException();
    return file;
  }

  Future<File> getFile(String uuid, ChallengeType previewType,
      [bool thumb = false]) async {
    String url = '';
    if (previewType == ChallengeType.VIDEO && !thumb) {
      url = '${Cache.getUrl(uuid)}.mp4';
    } else if (previewType == ChallengeType.VIDEO && thumb) {
      url = '${Cache.getUrl(uuid)}.preview.webp';
    } else {
      // IMAGE + SURVEY
      url = '${Cache.getUrl(uuid)}.webp';
    }
    return await Cache.getFile(url);
  }

  Future<List<Reply>> getUserWaitingReplies(int offset) async {
    Session session = await getSession();
    return await _apiUtil.getUserWaitingReplies(session.sid, offset);
  }

  Future<List<Reply>> getUserWinReplies(int offset) async {
    Session session = await getSession();
    return await _apiUtil.getUserWinReplies(session.sid, offset);
  }

  Future<LikeResponse> updateLike(String applicationId, LikeStatus type) async {
    Session session = await getSession();
    String sessionId = session.sid;
    print(sessionId);
    LikeResponse likeResponse =
        await _apiUtil.updateLike(sessionId, applicationId, type);
    return likeResponse;
  }

  Future<int> getBalance() async {
    Session session = await getSession();
    String sessionId = session.sid;
    print(sessionId);
    BalanceResponse balanceResponse = await _apiUtil.getBalance(sessionId);
    print('balance = ${balanceResponse.balanceValue}');
    return balanceResponse.balanceValue;
  }
  //
  // Future<void> putFile(String uuid) {
  //
  // }
}
