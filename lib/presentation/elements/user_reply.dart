import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ichazy/domain/bloc/reply_card_bloc.dart';
import 'package:ichazy/domain/model/challenge.dart';
import 'package:ichazy/domain/model/create_reply_data.dart';
import 'package:ichazy/domain/model/reply_data.dart';
import 'package:ichazy/presentation/colors/colors.dart';
import 'package:ichazy/presentation/elements/video_emded.dart';
import 'package:ichazy/presentation/reply_screen.dart';

import 'like.dart';

class UserReply extends StatelessWidget with RouteAware {
  final Reply reply;
  final bool small;

  UserReply({this.reply, this.small = false});
  @override
  Widget build(BuildContext context) {
    ReplyCardCubit _cubit = ReplyCardCubit();

    return BlocListener(
      cubit: _cubit,
      listener: (context, state) {
        if (state is OpenReplyState) {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => ReplyScreen(state.reply, state.userId)),
          );
        }
      },
      child: GestureDetector(
        onTap: () {
          _cubit.openReply(reply.createReply.id);
        },
        child: Container(
          color: Colors.transparent,
          child: AspectRatio(
            aspectRatio: 1,
            child: Stack(
              fit: StackFit.expand,
              children: [
                if (reply.challengeType != ChallengeType.VIDEO || small)
                  FutureBuilder<Image>(
                      future: reply.getReplyPreview(),
                      builder: (context, AsyncSnapshot<Image> snapshot) {
                        if (snapshot.connectionState == ConnectionState.done ||
                            snapshot.hasData) {
                          return Stack(
                            children: [
                              snapshot.data ??
                                  Center(
                                    child: Text('Ошибка'),
                                  ),
                              if (small &&
                                  reply.challengeType == ChallengeType.VIDEO)
                                Align(
                                  alignment: Alignment(0.9, -0.9),
                                  child: Icon(
                                    Icons.play_arrow_rounded,
                                    color: Colors.white,
                                  ),
                                ),
                            ],
                          );
                        } else {
                          return Container();
                        }
                      }),
                if (reply.challengeType == ChallengeType.VIDEO && !small)
                  FutureBuilder<File>(
                      future: reply.getReplyVideo(),
                      builder: (context, AsyncSnapshot<File> snapshot) {
                        if (snapshot.data != null &&
                                snapshot.connectionState ==
                                    ConnectionState.done ||
                            snapshot.hasData && snapshot.data != null) {
                          return VideoEmbed(snapshot.data);
                        }
                        return Center(
                          child: Text('Ошибка'),
                        );
                      }),
                if (reply.createReply.winState == WinState.PROCESSING)
                  Center(
                      child: Image.asset(
                    'assets/icons/wo bg/settings.png',
                    width: 50,
                  )),
                Positioned(
                  bottom: !small ? 12 : 5,
                  left: !small ? 12 : 5,
                  child: Container(
                    alignment: Alignment.center,
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      shape: BoxShape.rectangle,
                      color: AppColor.MAIN.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '#${reply.hashTag}' ?? '#тэг',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
                if (!small)
                  Positioned(
                    bottom: 12,
                    right: 12,
                    child: Container(
                      child: Like(
                          applicationId: reply.createReply.id,
                          stats: reply.stats,
                          initValue: reply.likeStatus),
                    ),
                  ),
                if (!small)
                  Positioned(
                    top: 12,
                    left: 12,
                    child: Container(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          GestureDetector(
                            onTap: () => print('tapName'),
                            child: CircleAvatar(
                              radius: 20,
                              child: ClipOval(
                                child: FutureBuilder<Image>(
                                    future: reply.getReplyImage(),
                                    builder: (context,
                                        AsyncSnapshot<Image> snapshot) {
                                      if (snapshot.connectionState ==
                                              ConnectionState.done ||
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
                            ),
                          ),
                          SizedBox(width: 5),
                          Text(
                            reply.userName,
                            style: TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
