import 'dart:io';

import 'package:flutter/material.dart';
import 'package:ichazy/domain/model/challenge.dart';
import 'package:ichazy/domain/model/create_reply_data.dart';
import 'package:ichazy/domain/model/reply_data.dart';
import 'package:ichazy/presentation/elements/video_emded.dart';

import 'like.dart';

class ReplyCard extends StatelessWidget {
  final Reply reply;
  ReplyCard({this.reply});

  @override
  Widget build(BuildContext context) {
    print(reply.createReply.approveState);
    return Container(
      child: AspectRatio(
        aspectRatio: 1,
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (reply.challengeType != ChallengeType.VIDEO)
              FutureBuilder<Image>(
                  future: reply.getReplyPreview(),
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
                  }),
            if (reply.challengeType == ChallengeType.VIDEO)
              FutureBuilder<File>(
                  future: reply.getReplyVideo(),
                  builder: (context, AsyncSnapshot<File> snapshot) {
                    if (snapshot.connectionState == ConnectionState.done ||
                        snapshot.hasData) {
                      print(snapshot.data.path);
                      return VideoEmbed(snapshot.data);
                    }
                    return Center(
                      child: Text('Ошибка'),
                    );
                  }),
            if (reply.createReply.winState == WinState.PROCESSING)
              Center(
                child: Column(
                  children: [
                    Image.asset(
                      'assets/icons/wo bg/settings.png',
                      width: 100,
                    ),
                    Expanded(
                      child: Text(
                        'Видео находится в обработке',
                        style: TextStyle(fontSize: 20),
                        maxLines: 2,
                      ),
                    )
                  ],
                ),
              ),
            if (reply.createReply.approveState != ApproveState.NEW)
              Positioned(
                bottom: 12,
                right: 12,
                child: Container(
                  child: Like(
                      applicationId: reply.createReply.id,
                      stats: reply.stats,
                      initValue: reply.likeStatus),
                ),
              )
          ],
        ),
      ),
    );
  }

  //_openProfile(User user) {}
}
