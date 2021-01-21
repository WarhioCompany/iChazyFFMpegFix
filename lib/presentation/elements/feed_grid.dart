import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ichazy/domain/bloc/feed_bloc.dart';
import 'package:ichazy/internal/feed_module.dart';
import 'package:ichazy/presentation/elements/challenge_card_small.dart';

class FeedGrid extends StatefulWidget {
  FeedGrid();

  @override
  _FeedGridState createState() => _FeedGridState();
}

class _FeedGridState extends State<FeedGrid> {
  final _feedBloc = FeedModule.feedBloc();
  final _scrollController = ScrollController();
  final _scrollThreshold = 600.0;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    //_feedBloc.add(FeedLoadingEvent());
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _feedBloc.close();
    super.dispose();
  }

  void _onScroll() {
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;
    if (maxScroll - currentScroll <= _scrollThreshold) {
      _feedBloc.add(FeedAddPosts());
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (BuildContext context) => _feedBloc,
      child: _getContentBuilder(),
    );
  }

  Widget _getContentBuilder() {
    return BlocBuilder<FeedBloc, FeedState>(builder: (context, state) {
      if (state is FeedLoadingState) {
        Center(child: CircularProgressIndicator());
      }
      if (state is FeedResultState) {
        GridView.builder(
          controller: _scrollController,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 2,
            mainAxisSpacing: 2,
          ),
          itemCount: state.challenges.length,
          itemBuilder: (BuildContext context, int index) {
            return index >= state.challenges.length
                ? _loader()
                : ChallengeCardSmall(state.challenges[index], true);
          },
        );
      }
      return Container();
    });
  }

  // Widget _getBody(List<Widget> widgets) {
  //   return GridView.builder(
  //     controller: _scrollController,
  //     itemCount: widgets.length,
  //     gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
  //       crossAxisCount: 3,
  //       crossAxisSpacing: 2,
  //       mainAxisSpacing: 2,
  //     ),
  //     itemBuilder: (context, index) => widgets[index],
  //   );
  //
  //     // itemBuilder: (context, index) => widgets[index],
  //     // separatorBuilder: (BuildContext context, index) => Divider(),
  //     // itemCount: widgets.length,
  //   //);
  // }

  Widget _loader() {
    return Container(
      alignment: Alignment.center,
      child: Center(
        child: SizedBox(
          width: 33,
          height: 33,
          child: CircularProgressIndicator(
            strokeWidth: 1.5,
          ),
        ),
      ),
    );
  }
}
