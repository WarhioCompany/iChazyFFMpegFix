import 'dart:io';

import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ichazy/domain/bloc/challenge_bloc.dart';
import 'package:ichazy/domain/model/brand.dart';
import 'package:ichazy/domain/model/challenge.dart';
import 'package:ichazy/internal/challenge_module.dart';
import 'package:ichazy/presentation/challenge_screen.dart';
import 'package:ichazy/presentation/colors/colors.dart';
import 'package:ichazy/presentation/elements/video_emded.dart';
import 'package:ichazy/presentation/registration_screen.dart';
import 'package:ichazy/presentation/style/date_time.dart';

import '../brand_screen.dart';

class ChallengeCard extends StatefulWidget {
  final Challenge _challenge;
  final bool _clickable;
  final bool _showTitle;

  ChallengeCard(this._challenge, this._clickable, this._showTitle);

  @override
  _ChallengeCardState createState() => _ChallengeCardState();
}

class _ChallengeCardState extends State<ChallengeCard>
    with AutomaticKeepAliveClientMixin {
  final _challengeBloc = ChallengeModule.challengeBloc();

  @override
  void initState() {
    super.initState();
    _challengeBloc.add(ChallengeLoadingEvent(
        widget._challenge.previewUuid, widget._challenge.challengeType, false));
    print(
        'challenge id = ${widget._challenge.uuid} ${widget._challenge.brandId}');
    //player.dataSource = file.path;
  }

  @override
  void dispose() {
    _challengeBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return _getBody();
  }

  Widget _getBody() {
    return BlocProvider(
      create: (BuildContext context) => _challengeBloc,
      child: _getContentBuilder(),
    );
  }

  Widget _getContentBuilder() {
    return BlocConsumer<ChallengeBloc, ChallengeState>(
      listener: (context, state) {
        if (state is ChallengeOpenProfileState) {
          print('challenge = ${widget._challenge.brandId}');
          print('challenge state.brand = ${state.brand.id}');
          _openProfilePage(context, state.brand);
        }
        if (state is ChallengeLoginState) _openLoginScreen(context);
        if (state is ChallengeClosePopup) _closePopup(context);
        if (state is ChallengeMessageState)
          _showMessage(state.message, state.pop);
        if (state is ChallengeOpenChallengeState) {
          var newChallenge = widget._challenge.copyWith(brand: state.brand);
          _openChallenge(newChallenge, context);
        }
        if (state is ChallengeUploadDialogState)
          _openUploadDialog(context, widget._challenge.challengeType);
      },
      buildWhen: (previous, current) {
        if (current is! ChallengeMessageState) {
          return true;
        } else
          return false;
      },
      builder: (context, state) {
        if (state is ChallengeErrorState) {
          return Center(child: Text('Error'));
        }
        return _getResultWidget();
      },
    );
  }

  Widget _getResultWidget() {
    return InkWell(
      onTap: () {
        if (widget._clickable) {
          _challengeBloc
              .add(ChallengeOpenChallengeEvent(widget._challenge.brandId));
        }
      },
      child: Container(
        child: Column(
          children: [
            if (widget._showTitle)
              _getTitle(context, widget._challenge.brandId,
                  widget._challenge.brandAvatarId),
            _getPreview(
                widget._challenge.previewUuid, widget._challenge.challengeType),
            _getNavBar(context),
          ],
        ),
      ),
    );
  }

  Widget _getImagePlaceholder(String id) {
    return FutureBuilder<Image>(
        future: Brand.getImage(id),
        builder: (context, AsyncSnapshot<Image> snapshot) {
          if (snapshot.connectionState == ConnectionState.done ||
              snapshot.hasData) {
            return snapshot.data ??
                Center(
                  child: Text('Ошибка'),
                );
          } else {
            return Container();
          }
        });
  }

  Widget _getVideoPlaceholder(String id) {
    return FutureBuilder<File>(
        future: Challenge.getFile(id),
        builder: (context, AsyncSnapshot<File> snapshot) {
          if (snapshot.connectionState == ConnectionState.done ||
              snapshot.hasData) {
            return _getVideo(snapshot.data);
          } else {
            return Container();
          }
        });
  }

  Widget _getTitle(BuildContext context, String brandId, String avatarBrandId) {
    return Container(
      padding: EdgeInsets.fromLTRB(8, 14, 8, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.only(left: 5),
            child: Text(
              widget._challenge.name,
              style: TextStyle(
                fontFamily: 'Montserrat',
                fontSize: 19,
                fontWeight: FontWeight.w600,
                color: AppColor.TITLE_TEXT_GRAY,
              ),
            ),
          ),
          Spacer(),
          GestureDetector(
            onTap: () => _challengeBloc.add(ChallengeOpenProfileEvent(brandId)),
            child: FutureBuilder<Image>(
                future: Brand.getImage(avatarBrandId),
                builder: (context, AsyncSnapshot<Image> snapshot) {
                  if (snapshot.connectionState == ConnectionState.done ||
                      snapshot.hasData) {
                    return CircleAvatar(
                      backgroundColor: Colors.white,
                      radius: 15,
                      child: ClipOval(
                        child: snapshot.data,
                      ),
                    );
                  } else {
                    return CircularProgressIndicator();
                  }
                }),
          ),
        ],
      ),
    );
  }

  Widget _getPreview(String id, ChallengeType challengeType) {
    Widget preview;
    if (challengeType == ChallengeType.IMAGE) {
      preview = _getImagePlaceholder(id);
    } else if (challengeType == ChallengeType.VIDEO) {
      preview = _getVideoPlaceholder(id);
    } else {
      preview = _getImagePlaceholder(id);
    }

    return AspectRatio(
      aspectRatio: 1,
      child: Stack(
        fit: StackFit.expand,
        children: [
          AspectRatio(aspectRatio: 1),
          preview,
          if (widget._challenge.coinsAmount > 0)
            Positioned(
              top: 12,
              right: 12,
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.rectangle,
                  color: AppColor.BLUE2_OPACITY,
                  borderRadius: BorderRadius.circular(30),
                ),
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                alignment: Alignment.center,
                //color: Color.fromRGBO(78, 120, 146, 0.8),
                child: Row(
                  children: [
                    Image.asset(
                      'assets/icons/png/icon-cost.png',
                      height: 22,
                    ),
                    SizedBox(width: 5),
                    Text('${widget._challenge.coinsAmount} M',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w300)),
                  ],
                ),
              ),
            ),
          Positioned(
            bottom: 12,
            left: 12,
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.rectangle,
                color: AppColor.MAIN.withOpacity(0.8),
                borderRadius: BorderRadius.circular(30),
              ),
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              alignment: Alignment.center,
              child: Row(
                children: [
                  Image.asset(
                    'assets/icons/png/icon-my-awards.png',
                    height: 22,
                  ),
                  SizedBox(width: 5),
                  Text(
                      '${widget._challenge.applicationCount} / ${widget._challenge.applicationCountLimit}',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w300)),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 12,
            right: 12,
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.rectangle,
                color: AppColor.MAIN.withOpacity(0.8),
                borderRadius: BorderRadius.circular(30),
              ),
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              alignment: Alignment.center,
              //color: Color.fromRGBO(78, 120, 146, 0.8),
              child: Row(
                children: [
                  Image.asset(
                    'assets/icons/png/icon-date.png',
                    height: 22,
                  ),
                  SizedBox(width: 5),
                  //    20.09.20 - 31.12.21 04:00
                  Text(
                      '${Date.startDate(widget._challenge.startDate)} - ${Date.stopDate(widget._challenge.stopDate)}',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w300)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _getNavBar(BuildContext context) {
    String path = '';
    if (widget._challenge.challengeType == ChallengeType.VIDEO) {
      path = 'assets/icons/wo bg/добавить видео без фона.png';
    } else {
      path = 'assets/icons/wo bg/добавить фото без фона.png';
    }
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            height: 36,
            width: 36,
            padding: EdgeInsets.only(right: 21),
            child: GestureDetector(
              child: _getDifficultyIcon(widget._challenge.challengeDifficulty),
            ),
          ),
          _getIconButton(
              () => _openGiftDialog(context, widget._challenge.awardPreviewId),
              'assets/icons/png/icon-award.png',
              AppColor.LIGHT_BLUE3),
          _getIconButton(
              () => _challengeBloc
                  .add(ChallengeUploadDialogEvent(widget._challenge.uuid)),
              path,
              AppColor.LIGHT_BLUE4),
        ],
      ),
    );
  }

  Widget _getDifficultyIcon(ChallengeDifficulty difficulty) {
    if (difficulty == ChallengeDifficulty.EASY) {
      return Image.asset(
        'assets/icons/png/compexity-1.png',
        width: 15,
      );
    } else if (difficulty == ChallengeDifficulty.NORMAL) {
      return Image.asset(
        'assets/icons/png/compexity-2.png',
        width: 15,
      );
    } else if (difficulty == ChallengeDifficulty.HARD) {
      return Image.asset(
        'assets/icons/png/compexity-3.png',
        width: 15,
        color: Colors.red[900],
      );
    } else {
      throw Exception('_getDifficultyIcon');
    }
  }

  Widget _getIconButton(VoidCallback onPressed, String path, Color color) {
    return Container(
      height: 36,
      width: 36,
      margin: EdgeInsets.zero,
      //width: 50,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color.fromRGBO(117, 110, 100, 0.41),
            offset: Offset(0, 5),
            blurRadius: 14,
          ),
          BoxShadow(
            color: Color.fromRGBO(255, 255, 255, 0.83),
            offset: Offset(-5, -5),
            blurRadius: 14,
          ),
        ],
      ),
      child: IconButton(
        padding: EdgeInsets.all(6),
        onPressed: onPressed,
        icon: Image.asset(
          path,
          filterQuality: FilterQuality.high,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _getVideo(File file) {
    return VideoEmbed(
      file,
      main: true,
    );
  }

  Widget _getGalleryPhotoButton(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        print('gallery');
        _challengeBloc.add(ChallengeGetPhotoEvent(widget._challenge.uuid));
      },
      child: Container(
        alignment: Alignment.center,
        height: 65,
        //width: 200,
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        margin: EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          shape: BoxShape.rectangle,
          color: AppColor.ORANGE,
          borderRadius: BorderRadius.circular(25),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.photo_outlined,
              color: Colors.white,
            ),
            SizedBox(
              width: 10,
            ),
            Text(
              'Выбрать фото из галереи',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  Widget _getGalleryVideoButton(BuildContext context) {
    return GestureDetector(
      onTap: () {
        print('gallery');
        _challengeBloc.add(ChallengeGetVideoEvent(widget._challenge.uuid));
      },
      child: Container(
        alignment: Alignment.center,
        height: 65,
        //width: 200,
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        margin: EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          shape: BoxShape.rectangle,
          color: AppColor.ORANGE,
          borderRadius: BorderRadius.circular(25),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.photo_outlined,
              color: Colors.white,
            ),
            SizedBox(
              width: 10,
            ),
            Text(
              'Выбрать видео из галереи',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  Widget _getCameraPhotoButton(BuildContext context) {
    return GestureDetector(
      onTap: () {
        print('open camera');
        _challengeBloc
            .add(ChallengeCreatePhotoEvent(context, widget._challenge.uuid));
      },
      child: Container(
        alignment: Alignment.center,
        height: 65,
        //width: 200,
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        margin: EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          shape: BoxShape.rectangle,
          color: AppColor.LIGHT_BLUE4,
          borderRadius: BorderRadius.circular(25),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.camera_alt_outlined,
              color: Colors.white,
            ),
            SizedBox(
              width: 10,
            ),
            Text(
              'Сделать фото',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  Widget _getCameraVideoButton(BuildContext context) {
    return GestureDetector(
      onTap: () {
        print('open camera');
        _challengeBloc
            .add(ChallengeCreateVideoEvent(context, widget._challenge.uuid));
      },
      child: Container(
        alignment: Alignment.center,
        height: 65,
        //width: 200,
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        margin: EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          shape: BoxShape.rectangle,
          color: AppColor.LIGHT_BLUE4,
          borderRadius: BorderRadius.circular(25),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.camera_alt_outlined,
              color: Colors.white,
            ),
            SizedBox(
              width: 10,
            ),
            Text(
              'Cнять видео',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  _openGiftDialog(BuildContext context, String id) {
    print('gift');
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          insetPadding: EdgeInsets.all(8),
          child: Container(
            margin: EdgeInsets.all(8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  //mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(
                      width: 30,
                    ),
                    Spacer(),
                    Text(
                      'Ваша награда',
                      style: TextStyle(fontSize: 16),
                    ),
                    Spacer(),
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: Icon(
                        Icons.cancel_sharp,
                        color: AppColor.ORANGE2,
                        size: 30,
                      ),
                    ),
                  ],
                ),
                Container(
                  margin: EdgeInsets.all(10),
                  child: FutureBuilder<Image>(
                      future: Brand.getImage(id),
                      builder: (context, AsyncSnapshot<Image> snapshot) {
                        if (snapshot.connectionState == ConnectionState.done ||
                            snapshot.hasData) {
                          //Image image =  snapshot.data;
                          return snapshot.data ??
                              Center(
                                child: Text('Ошибка'),
                              );
                        } else {
                          return Container();
                        }
                      }),
                ),
              ],
            ),
          ),
        );
      },
      barrierDismissible: true,
    );
  }

  _openUploadDialog(BuildContext context, ChallengeType type) {
    print('upload');
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          insetPadding: EdgeInsets.all(8),
          child: Container(
            margin: EdgeInsets.all(10),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Align(
                  alignment: Alignment(1, 1),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Icon(
                      Icons.cancel_sharp,
                      color: AppColor.ORANGE2,
                      size: 30,
                    ),
                  ),
                ),
                SizedBox(
                  height: 40,
                ),
                if (type == ChallengeType.VIDEO)
                  _getGalleryVideoButton(context),
                if (type == ChallengeType.IMAGE || type == ChallengeType.SURVEY)
                  _getGalleryPhotoButton(context),
                SizedBox(
                  height: 40,
                ),
                if (type == ChallengeType.VIDEO) _getCameraVideoButton(context),
                if (type == ChallengeType.IMAGE || type == ChallengeType.SURVEY)
                  _getCameraPhotoButton(context),
                SizedBox(
                  height: 80,
                ),
              ],
            ),
          ),
        );
      },
      barrierDismissible: true,
    );
  }

  _openChallenge(Challenge challenge, BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ChallengeScreen(challenge)),
    );
  }

  _openLoginScreen(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => RegistrationScreen()),
    );
  }

  _showMessage(String message, bool pop) {
    if (pop) Navigator.pop(context);
    Flushbar(
      backgroundColor: AppColor.DARK_BLUE2,
      message: message,
      isDismissible: true,
      duration: Duration(seconds: 3),
      dismissDirection: FlushbarDismissDirection.HORIZONTAL,
    )..show(context);
  }

  _closePopup(BuildContext context) {
    Navigator.pop(
      context,
    );
  }

  _openProfilePage(BuildContext context, Brand brand) {
    print('open profile');
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => BrandScreen(brand)),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
