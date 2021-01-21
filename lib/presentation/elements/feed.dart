import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ichazy/domain/bloc/feed_bloc.dart';
import 'package:ichazy/domain/model/challenge.dart';
import 'package:ichazy/internal/feed_module.dart';
import 'package:ichazy/presentation/elements/custom_divider.dart';

import 'challenge_card.dart';

class Feed extends StatefulWidget {
  @override
  _FeedState createState() => _FeedState();
}

class _FeedState extends State<Feed> {
  final _feedBloc = FeedModule.feedBloc();
  final _scrollController = ScrollController();
  final _scrollThreshold = 800.0;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
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
      child: _getBody(),
    );
  }

  Widget _getBody() {
    return BlocBuilder<FeedBloc, FeedState>(
      builder: (context, state) {
        if (state is FeedLoadingState) {
          Center(
            child: CircularProgressIndicator(),
          );
        }
        if (state is FeedResultState) {
          return ListView.builder(
            padding: EdgeInsets.all(0),
            itemBuilder: (BuildContext context, int index) {
              return index >= state.challenges.length
                  ? _loader()
                  : _getChallengeItem(state.challenges[index]);
            },
            itemCount: state.challenges.length,
            controller: _scrollController,
          );
        }
        return Container();
      },
    );
  }

  // List<Widget> _getListChallenges(List<Challenge> challenges) {
  //   return challenges
  //       .map((challenge) => _getChallengeItem(challenge))
  //       .toList(growable: true);
  // }

  Widget _getChallengeItem(Challenge challenge) {
    return Column(
      children: [
        ChallengeCard(challenge, true, true),
        AppDivider(),
      ],
    );
  }

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
