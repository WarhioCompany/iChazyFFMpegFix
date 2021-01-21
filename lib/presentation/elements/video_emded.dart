import 'dart:io';

import 'package:fijkplayer/fijkplayer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ichazy/domain/bloc/video_controller_cubit.dart';
import 'package:ichazy/presentation/colors/colors.dart';
import 'package:route_observer_mixin/route_observer_mixin.dart';

class VideoEmbed extends StatefulWidget {
  final File file;
  final bool main;
  VideoEmbed(this.file, {this.main = false});

  @override
  _VideoEmbedState createState() => _VideoEmbedState();
}

class _VideoEmbedState extends State<VideoEmbed>
    with AutomaticKeepAliveClientMixin, RouteAware, RouteObserverMixin {
  final VideoControllerCubit _controller = VideoControllerCubit();
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    _controller.player.release();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return BlocProvider<VideoControllerCubit>(
      create: (context) {
        return _controller..init(widget.file);
      },
      child: BlocBuilder<VideoControllerCubit, VideoControllerState>(
        buildWhen: (previous, current) => current is! VideoVolumeState,
        builder: (context, state) {
          return Stack(
            children: [
              AbsorbPointer(
                  absorbing: true,
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: FijkView(
                      color: Colors.white,
                      player:
                          BlocProvider.of<VideoControllerCubit>(context).player,
                    ),
                  )),
              Positioned(
                top: 12,
                right: widget.main ? null : 12,
                left: widget.main ? 12 : null,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    if (BlocProvider.of<VideoControllerCubit>(context).volume) {
                      BlocProvider.of<VideoControllerCubit>(context)
                          .offVolume();
                    } else {
                      BlocProvider.of<VideoControllerCubit>(context).onVolume();
                    }
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.rectangle,
                      color: AppColor.DARK_BLUE2_OPACITY,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    alignment: Alignment.center,
                    //color: Color.fromRGBO(78, 120, 146, 0.8),
                    child:
                        BlocBuilder<VideoControllerCubit, VideoControllerState>(
                      buildWhen: (previous, current) =>
                          current is VideoVolumeState,
                      //listener: (context, state) {},
                      builder: (context, state) {
                        return Text(
                            BlocProvider.of<VideoControllerCubit>(context)
                                    .volume
                                ? 'Вкл. звук'
                                : 'Выкл. звук',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.w300));
                      },
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  void didPushNext() {
    print('didPushNext');
    _controller.pause();
  }

  @override
  void didPopNext() {
    print('didPopNext');
    _controller.play();
  }

  @override
  bool get wantKeepAlive => true;
}
