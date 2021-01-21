import 'package:camera/camera.dart';
import 'package:camera_camera/page/bloc/bloc_video.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ichazy/data/api/ethernet/response.dart';
import 'package:ichazy/domain/bloc/timer_cubit.dart';
import 'package:ichazy/domain/model/ticker_timer.dart';
import 'package:video_player/video_player.dart';
import 'package:wakelock/wakelock.dart';

class RecordVideoScreen extends StatefulWidget {
  @override
  _RecordVideoScreenState createState() => _RecordVideoScreenState();
}

class _RecordVideoScreenState extends State<RecordVideoScreen> {
  var bloc = BlocVideo();

  @override
  void initState() {
    super.initState();
    Wakelock.enable();
    bloc.getCameras();
    bloc.cameras.listen((data) {
      bloc.controllCamera = CameraController(data[0], ResolutionPreset.medium);
      bloc.cameraOn.sink.add(0);
      bloc.controllCamera.initialize().then((_) {
        bloc.selectCamera.sink.add(true);
      });
    });
  }

  @override
  void dispose() {
    if (bloc == null) {
      throw CancelException();
    }
    bloc.dispose();
    Wakelock.disable();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<TimerCubit>(
      create: (context) {
        return TimerCubit(TickerTimer(), 30);
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        // appBar: PreferredSize(
        //     child: Transform.translate(
        //         offset: Offset(0.0, 0.0),
        //         child: Container(
        //           color: Colors.black,
        //         )),
        //     preferredSize:
        //         Size.fromHeight(MediaQuery.of(context).size.height * 0.12)),
        body: Stack(
          children: <Widget>[
            Center(
              child: StreamBuilder<bool>(
                  stream: bloc.selectCamera.stream,
                  builder: (context, snapshot) {
                    return snapshot.hasData
                        ? StreamBuilder<bool>(
                            stream: bloc.videoOn.stream,
                            builder: (context, snapshot) {
                              if (snapshot.hasData) {
                                if (snapshot.data) {
                                  return Stack(
                                    children: [
                                      Center(
                                        child: AspectRatio(
                                            aspectRatio: bloc.controllCamera
                                                .value.aspectRatio,
                                            child: VideoPlayer(
                                                bloc.controllVideo)),
                                      ),
                                      // _getBlackBorders(),
                                      // _getBottomButtons(),
                                    ],
                                  );
                                } else {
                                  return Stack(
                                    children: [
                                      Center(
                                        child: AspectRatio(
                                            aspectRatio: bloc.controllCamera
                                                .value.aspectRatio,
                                            child: CameraPreview(
                                                bloc.controllCamera)),
                                      ),
                                    ],
                                  );
                                }
                              } else {
                                return Stack(
                                  children: [
                                    Center(
                                      child: AspectRatio(
                                          aspectRatio: bloc
                                              .controllCamera.value.aspectRatio,
                                          child: CameraPreview(
                                              bloc.controllCamera)),
                                    ),
                                    // _getBlackBorders(),
                                    // _getBottomButtons()
                                  ],
                                );
                              }
                            })
                        : Container();
                  }),
            ),
            _getBlackBorders(),
            _getBottomButtons(),
            StreamBuilder<bool>(
              stream: bloc.videoOn.stream,
              builder: (context, snapshot) {
                if (!snapshot.hasData || !snapshot.data)
                  return Align(
                    alignment: Alignment(0, -0.9),
                    child: BlocConsumer<TimerCubit, TimerState>(
                        listener: (_, state) {
                      if (state is Finished) {
                        bloc.stopVideoRecording();
                      }
                    }, builder: (context, state) {
                      print(state);
                      if (state is Running || state is Empty) {
                        return Text(
                          '0:${state.duration}',
                          style: TextStyle(
                              fontSize: 28,
                              color: Colors.white,
                              fontWeight: FontWeight.bold),
                        );
                      }
                      return Text(
                        '0:30',
                        style: TextStyle(
                            fontSize: 28,
                            color: Colors.white,
                            fontWeight: FontWeight.bold),
                      );
                    }),
                  );
                return Container();
              },
            ),
          ],
        ),
        floatingActionButton: StreamBuilder<Object>(
            stream: bloc.videoOn.stream,
            builder: (context, snapshot) {
              return snapshot.hasData
                  ? snapshot.data
                      ? StreamBuilder(
                          stream: bloc.playPause.stream,
                          builder: (context, snapshot) {
                            return snapshot.hasData
                                ? snapshot.data
                                    ? FloatingActionButton(
                                        onPressed: () {
                                          bloc.controllVideo.pause();
                                          bloc.playPause.sink.add(false);
                                        },
                                        child: Stack(
                                          children: <Widget>[
                                            Center(
                                              child: CircleAvatar(
                                                radius: 35.0,
                                                backgroundColor: Colors.white,
                                                child: Icon(
                                                  Icons.pause,
                                                  color: Colors.black,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        backgroundColor: Colors.grey.shade800,
                                      )
                                    : FloatingActionButton(
                                        onPressed: () {
                                          bloc.controllVideo.play();
                                          bloc.playPause.sink.add(true);
                                        },
                                        child: Stack(
                                          children: <Widget>[
                                            Center(
                                              child: CircleAvatar(
                                                radius: 35.0,
                                                backgroundColor: Colors.white,
                                                child: Icon(
                                                  Icons.play_arrow,
                                                  color: Colors.black,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        backgroundColor: Colors.grey.shade800,
                                      )
                                : Container();
                          },
                        )
                      : FloatingActionButton(
                          onPressed: () {
                            bloc.stopVideoRecording();
                            BlocProvider.of<TimerCubit>(context).reset();
                          },
                          child: Stack(
                            children: <Widget>[
                              Center(
                                child: CircleAvatar(
                                  radius: 35.0,
                                  backgroundColor: Colors.white,
                                  child: Icon(
                                    Icons.stop,
                                    color: Colors.red,
                                  ),
                                ),
                              ),
                              SizedBox(
                                  height: 60.0,
                                  width: 60.0,
                                  child: StreamBuilder<bool>(
                                      stream: bloc.videoOn.stream,
                                      builder: (context, snapshot) {
                                        if (snapshot.hasData) {
                                          return StreamBuilder<double>(
                                              stream: bloc.timeVideo.stream,
                                              builder: (context, snapshot) {
                                                return CircularProgressIndicator(
                                                  value: snapshot.data,
                                                  strokeWidth: 6.0,
                                                  valueColor:
                                                      AlwaysStoppedAnimation<
                                                          Color>(Colors.red),
                                                );
                                              });
                                        } else {
                                          return CircularProgressIndicator(
                                            value: 1.0,
                                            strokeWidth: 6.0,
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                                    Colors.grey.shade800),
                                          );
                                        }
                                      }))
                            ],
                          ),
                          backgroundColor: Colors.grey.shade800,
                        )
                  : FloatingActionButton(
                      onPressed: () {
                        BlocProvider.of<TimerCubit>(context).start();
                        bloc.onVideoRecordButtonPressed();
                      },
                      child: Center(
                        child: CircleAvatar(
                          radius: 35.0,
                          backgroundColor: Colors.white,
                          child: Icon(
                            Icons.fiber_manual_record,
                            color: Colors.red,
                          ),
                        ),
                      ),
                      backgroundColor: Colors.grey.shade800,
                    );
            }),
        floatingActionButtonAnimator: FloatingActionButtonAnimator.scaling,
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      ),
    );
  }

  Widget _getBottomButtons() {
    return StreamBuilder<Object>(
        stream: bloc.videoOn.stream,
        builder: (context, snapshot) {
          return snapshot.hasData
              ? snapshot.data
                  ? Align(
                      alignment: Alignment.bottomCenter,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: <Widget>[
                          CircleAvatar(
                            child: IconButton(
                              icon: Icon(Icons.delete, color: Colors.white),
                              onPressed: () {
                                bloc.deleteVideo();
                                bloc.videoOn.sink.add(null);
                              },
                            ),
                            backgroundColor: Colors.red,
                            radius: 25.0,
                          ),
                          CircleAvatar(
                            child: IconButton(
                              icon: Icon(
                                Icons.done_rounded,
                                color: Colors.white,
                              ),
                              onPressed: () {
                                Navigator.pop(context, bloc.videoPath.value);
                              },
                            ),
                            backgroundColor: Colors.grey.shade900,
                            radius: 25.0,
                          )
                        ],
                      ),
                    )
                  : Container(
                      width: 0.0,
                      height: 0.0,
                    )
              : Align(
                  alignment: Alignment.bottomCenter,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: <Widget>[
                      CircleAvatar(
                        child: IconButton(
                          icon: Icon(Icons.arrow_back, color: Colors.white),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                        backgroundColor: Colors.grey.shade900,
                        radius: 25.0,
                      ),
                      CircleAvatar(
                        child: IconButton(
                          icon: StreamBuilder<int>(
                              stream: bloc.cameraOn,
                              builder: (context, snapshot) {
                                return snapshot.hasData
                                    ? snapshot.data == 0
                                        ? Icon(
                                            Icons.camera_front,
                                            color: Colors.white,
                                          )
                                        : Icon(
                                            Icons.camera_rear,
                                            color: Colors.white,
                                          )
                                    : Container();
                              }),
                          onPressed: () {
                            bloc.changeCamera();
                          },
                        ),
                        backgroundColor: Colors.grey.shade900,
                        radius: 25.0,
                      )
                    ],
                  ),
                );
        });
  }

  Widget _getBlackBorders() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AspectRatio(
            aspectRatio: 3.5 / 1,
            child: Container(
              color: Colors.black,
            ),
          ),
          AspectRatio(
            aspectRatio: 1,
            child: Container(
              color: Colors.transparent,
            ),
          ),
          AspectRatio(
            aspectRatio: 3.5 / 1,
            child: Container(
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}
