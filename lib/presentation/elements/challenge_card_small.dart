import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ichazy/domain/bloc/challenge_bloc.dart';
import 'package:ichazy/domain/model/challenge.dart';
import 'package:ichazy/internal/challenge_module.dart';
import 'package:ichazy/presentation/challenge_screen.dart';
import 'package:ichazy/presentation/colors/colors.dart';

class ChallengeCardSmall extends StatefulWidget {
  final Challenge _challenge;
  final bool _clickable;
  ChallengeCardSmall(this._challenge, this._clickable);

  @override
  _ChallengeCardSmallState createState() => _ChallengeCardSmallState();
}

class _ChallengeCardSmallState extends State<ChallengeCardSmall> {
  //VideoViewController videoController;
  final _challengeBloc = ChallengeModule.challengeBloc();

  @override
  void initState() {
    super.initState();
    _challengeBloc.add(ChallengeLoadingEvent(
        widget._challenge.previewUuid, widget._challenge.challengeType, true));
  }

  @override
  void dispose() {
    _challengeBloc.close();
    //videoController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _getBody();
  }

  Widget _getBody() {
    return BlocProvider(
      create: (BuildContext context) => _challengeBloc,
      child: _getContentBuilder(),
    );
  }

  Widget _getContentBuilder() {
    return BlocBuilder<ChallengeBloc, ChallengeState>(
      builder: (context, state) {
        if (state is ChallengeLoadingState) {
          return _getPlaceholderWidget();
        }
        if (state is ChallengeResultState) {
          final file = state.file;
          return _getResultWidget(file);
        }
        if (state is ChallengeErrorState) {
          print(state.error);
          return Container();
        }
        return Container();
      },
    );
  }

  Widget _getResultWidget(File file) {
    return InkWell(
      onTap: () {
        if (widget._clickable) {
          _openChallenge(widget._challenge, context);
        }
      },
      child: Stack(
        children: [
          AspectRatio(aspectRatio: 1),
          _getPreview(file, widget._challenge.challengeType),
          Positioned(
            bottom: 6,
            left: 5,
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.rectangle,
                color: AppColor.MAIN.withOpacity(0.8),
                borderRadius: BorderRadius.circular(30),
              ),
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              alignment: Alignment.center,
              //color: Color.fromRGBO(78, 120, 146, 0.8),
              child: Text(
                widget._challenge.name,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w300,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _getPlaceholderWidget() {
    return InkWell(
      onTap: () {
        if (widget._clickable) {
          _openChallenge(widget._challenge, context);
        }
      },
      child: Stack(
        fit: StackFit.expand,
        children: [
          AspectRatio(aspectRatio: 1),
          Container(
            alignment: Alignment.center,
            child: CircularProgressIndicator(),
          ),
          Container(
            alignment: Alignment(-0.8, 0.9),
            child: Text(
              widget._challenge.name,
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _getPreview(File file, ChallengeType challengeType) {
    if (widget._challenge.challengeType == ChallengeType.IMAGE) {
      return _getImage(file);
    } else if (widget._challenge.challengeType == ChallengeType.VIDEO) {
      return _getVideoPreview(file);
    } else {
      return _getImage(file);
    }
  }

  Widget _getImage(File file) {
    return Image.file(
      file,
      fit: BoxFit.cover,
    );
  }

  Widget _getVideoPreview(File file) {
    return Stack(
      children: [
        Image.file(file, fit: BoxFit.cover),
        Align(
          alignment: Alignment(0.9, -0.9),
          child: Icon(
            Icons.play_arrow_rounded,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  _openChallenge(Challenge challenge, BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => ChallengeScreen(challenge)),
    );
  }
}
