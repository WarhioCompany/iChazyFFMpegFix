import 'dart:async';

import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ichazy/domain/bloc/feed_bloc.dart';
import 'package:ichazy/domain/model/challenge.dart';
import 'package:ichazy/internal/feed_module.dart';
import 'package:ichazy/presentation/colors/colors.dart';
import 'package:ichazy/presentation/elements/custom_divider.dart';

import 'challenge_card.dart';

class IntegratedFeed extends StatefulWidget {
  //final GlobalKey<ScaffoldState> key;
  final Filter filter;
  final String uid;

  IntegratedFeed(this.filter, this.uid);

  @override
  _IntegratedFeedState createState() => _IntegratedFeedState();
}

class _IntegratedFeedState extends State<IntegratedFeed> {
  final _feedBloc = FeedModule.feedBloc();
  final _scrollController = ScrollController();
  final _refreshIndicatorKey = GlobalKey<RefreshIndicatorState>();
  Completer<void> _refreshCompleter;
  Map<String, Challenge> challenges = {};

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _feedBloc.add(FeedLoadingEvent(widget.filter, widget.uid));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshIndicatorKey.currentState?.show();
    });
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
    if (maxScroll == currentScroll) {
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
    const Key centerKey = ValueKey('bottom-sliver-list');
    return BlocConsumer<FeedBloc, FeedState>(listener: (context, state) {
      if (state is FeedErrorState) {
        _refreshCompleter?.complete();
        Flushbar(
          backgroundColor: AppColor.DARK_BLUE2,
          message: "При загрузке данных что-то пошло не так",
          mainButton: FlatButton(
            onPressed: () =>
                _feedBloc.add(FeedLoadingEvent(widget.filter, widget.uid)),
            child: Text(
              'Повторить попытку',
              style: TextStyle(color: Colors.white),
            ),
          ),
          isDismissible: true,
          duration: Duration(seconds: 3),
          dismissDirection: FlushbarDismissDirection.HORIZONTAL,
        )..show(context);
      }
    }, buildWhen: (previous, current) {
      if (previous is FeedHardLoadingState && current is FeedResultState) {
        return true;
      }
      if (previous is FeedHardLoadingState && current is FeedErrorState) {
        return true;
      }
      if (previous is FeedLoadingState && current is FeedResultState) {
        return true;
      }
      if (previous is FeedResultState && current is FeedResultState) {
        return true;
      }
      if (current is FeedErrorState) {
        if (challenges.isEmpty) return true;
      }
      return false;
    }, builder: (context, state) {
      if (state is FeedHardLoadingState) {
        challenges.clear();
        Center(child: CircularProgressIndicator());
      }
      if (state is FeedResultState) {
        _getChallenges(state.challenges);
        if (_refreshCompleter != null && !_refreshCompleter.isCompleted) {
          _refreshCompleter?.complete();
        }
        return RefreshIndicator(
          onRefresh: () {
            _refreshCompleter = Completer();
            _feedBloc.add(FeedLoadingEvent(widget.filter, widget.uid));
            return _refreshCompleter.future;
          },
          child: ListView.builder(
            key: centerKey,
            itemBuilder: (BuildContext context, int index) {
              return index >= state.challenges.length
                  ? _loader()
                  : _getChallengeItem(state.challenges[index]);
            },
            itemCount: state.challenges.length,
            controller: _scrollController,
          ),
        );
      }
      if (state is FeedErrorState) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/icons/png/sleep.png',
                width: 120,
              ),
              SizedBox(
                height: 10,
              ),
              Text('При загрузке данных что-то пошло не так'),
              SizedBox(
                height: 10,
              ),
              RaisedButton(
                color: AppColor.ORANGE3,
                onPressed: () =>
                    _feedBloc.add(FeedLoadingEvent(widget.filter, widget.uid)),
                child: Text(
                  'Повторить попытку',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        );
      }
      return Container();
    });
  }

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

  List<Challenge> _getChallenges(List<Challenge> listChallenges) {
    for (var challenge in listChallenges) {
      if (!challenges.containsKey(challenge.uuid)) {
        challenges[challenge.uuid] = challenge;
      }
    }
    return _getSortedChallenges();
    //temp.sort(dateComparator);
    //temp = temp.reversed.toList();
  }

  List<Challenge> _getSortedChallenges() {
    Comparator<Challenge> dateComparator = (a, b) => a
        .publicationDate.millisecondsSinceEpoch
        .compareTo(b.publicationDate.millisecondsSinceEpoch);
    List<Challenge> result = [];
    result.addAll(challenges.values);
    result.sort(dateComparator);
    result = result.reversed.toList();
    return result;
  }
}
