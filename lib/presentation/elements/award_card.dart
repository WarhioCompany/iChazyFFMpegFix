import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ichazy/domain/bloc/award_cubit.dart';
import 'package:ichazy/domain/model/award.dart';
import 'package:ichazy/domain/model/brand.dart';
import 'package:ichazy/domain/model/challenge.dart';
import 'package:ichazy/presentation/colors/colors.dart';
import 'package:ichazy/presentation/elements/video_emded.dart';
import 'package:ichazy/presentation/show_qr_screen.dart';
import 'package:ichazy/presentation/style/date_time.dart';

class AwardCard extends StatelessWidget {
  final Award award;

  AwardCard(this.award);

  @override
  Widget build(BuildContext context) {
    AwardCubit bloc = AwardCubit();
    return BlocProvider<AwardCubit>(
      create: (context) {
        return bloc;
      },
      child: BlocListener(
        cubit: bloc,
        listener: (context, state) {
          if (state is ShowConfirmAwardState) showConfirmDialog(context);
        },
        child: Container(
          child: Column(
            children: [
              _getTitle(award.brandId, award.avatarBrandId),
              Stack(
                children: [
                  if (award.challengeType != ChallengeType.VIDEO) _getImage(),
                  if (award.challengeType == ChallengeType.VIDEO) _getVideo(),
                  Positioned(
                      left: 12,
                      bottom: 12,
                      child: _getButton('Показать код', () => _show(context))),
                  Positioned(
                    bottom: 16,
                    right: 12,
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.rectangle,
                        color: AppColor.MAIN.withOpacity(0.8),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      padding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      alignment: Alignment.center,
                      //color: Color.fromRGBO(78, 120, 146, 0.8),
                      child: Row(
                        children: [
                          Text(
                              'действует до ${Date.startDate(award.validTillDate)}',
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
              Align(
                  alignment: Alignment.centerRight,
                  child: Container(
                      margin: EdgeInsets.all(12),
                      child: _getButton('Подтвердить использование',
                          () => bloc.askConfirm()))),
            ],
          ),
        ),
      ),
    );
  }

  Widget _getTitle(String brandId, String avatarBrandId) {
    return Container(
      padding: EdgeInsets.fromLTRB(8, 14, 8, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.only(left: 5),
            child: Text(
              '#${award.tag}',
              style: TextStyle(
                fontFamily: 'Montserrat',
                fontSize: 19,
                fontWeight: FontWeight.w600,
                color: AppColor.TITLE_TEXT_GRAY,
              ),
            ),
          ),
          Spacer(),
          FutureBuilder<Image>(
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
                  return Container();
                }
              }),
        ],
      ),
    );
  }

  Widget _getImage() {
    return FutureBuilder<Image>(
        future: Brand.getImage(award.challengePreviewId),
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

  Widget _getVideo() {
    return FutureBuilder<File>(
        future: Challenge.getFile(award.challengePreviewId),
        builder: (context, AsyncSnapshot<File> snapshot) {
          if (snapshot.connectionState == ConnectionState.done ||
              snapshot.hasData) {
            return _getPreview(snapshot.data);
          } else {
            return Container();
          }
        });
  }

  Widget _getPreview(File file) {
    return VideoEmbed(
      file,
      main: true,
    );
  }

  Widget _getButton(String text, VoidCallback voidCallback) {
    return RaisedButton(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      color: AppColor.BLUE2,
      onPressed: voidCallback,
      child: Text(
        text,
        style: TextStyle(color: Colors.white),
      ),
    );
  }

  void _show(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => ShowQrScreen(award.value, award.type)),
    );
  }

  showConfirmDialog(BuildContext context) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: Text('Вы действительно использовали код?'),
          actions: <Widget>[
            TextButton(
              child: Text('Нет'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Да'),
              onPressed: () {
                BlocProvider.of<AwardCubit>(context).sendIsUsed(award.id, true);
              },
            ),
          ],
        );
      },
    );
  }
}
