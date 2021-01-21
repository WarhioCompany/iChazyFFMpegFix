import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ichazy/domain/bloc/reply_feed_bloc.dart';
import 'package:ichazy/domain/model/challenge.dart';
import 'package:ichazy/domain/model/reply_data.dart';
import 'package:ichazy/internal/feed_module.dart';
import 'package:ichazy/presentation/colors/colors.dart';
import 'package:ichazy/presentation/elements/custom_divider.dart';
import 'package:ichazy/presentation/elements/user_reply.dart';

class IntegratedReplyFeed extends StatefulWidget {
  final String challengeId;
  final ScrollController _scrollController;
  IntegratedReplyFeed(this.challengeId, this._scrollController);

  @override
  _IntegratedReplyFeedState createState() => _IntegratedReplyFeedState();
}

class _IntegratedReplyFeedState extends State<IntegratedReplyFeed> {
  final _replyFeedBloc = FeedModule.replyFeedBloc();
  final _scrollThreshold = 300.0;
  Map<String, Reply> replies = {};

  @override
  void initState() {
    super.initState();
    print('feed');
    widget._scrollController.addListener(_onScroll);
    _replyFeedBloc
        .add(ReplyFeedLoadingEvent(Filter.BY_CHALLENGE, widget.challengeId));
  }

  @override
  void dispose() {
    widget._scrollController.dispose();
    _replyFeedBloc.close();
    super.dispose();
  }

  void _onScroll() {
    final maxScroll = widget._scrollController.position.maxScrollExtent;
    final currentScroll = widget._scrollController.position.pixels;
    if (maxScroll - currentScroll <= _scrollThreshold) {
      _replyFeedBloc.add(ReplyFeedAddPosts());
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (BuildContext context) => _replyFeedBloc,
      child: _getContentBuilder(),
    );
  }

  Widget _getContentBuilder() {
    const Key centerKey = ValueKey('bottom-sliver-list');
    return BlocConsumer<ReplyFeedBloc, ReplyFeedState>(
        listener: (context, state) {
      if (state is ReplyFeedErrorState) {
        Flushbar(
          backgroundColor: AppColor.DARK_BLUE2,
          message: "При загрузке данных что-то пошло не так",
          mainButton: FlatButton(
            onPressed: () => _replyFeedBloc.add(
                ReplyFeedLoadingEvent(Filter.BY_CHALLENGE, widget.challengeId)),
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
      if (previous is ReplyFeedHardLoadingState &&
          current is ReplyFeedResultState) {
        return true;
      }
      if (previous is ReplyFeedHardLoadingState &&
          current is ReplyFeedErrorState) {
        return true;
      }
      if (previous is ReplyFeedLoadingState &&
          current is ReplyFeedResultState) {
        return true;
      }
      if (previous is ReplyFeedResultState && current is ReplyFeedResultState) {
        return true;
      }
      return false;
    }, builder: (context, state) {
      if (state is ReplyFeedHardLoadingState) {
        replies.clear();
        Center(child: CircularProgressIndicator());
      }
      if (state is ReplyFeedResultState) {
        return ListView.builder(
          key: centerKey,
          itemBuilder: (BuildContext context, int index) {
            return index >= state.replies.length
                ? _loader()
                : _getReplyItem(state.replies[index]);
          },
          itemCount: state.replies.length,
        );
      }
      if (state is ReplyFeedErrorState) {
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
                onPressed: () => _replyFeedBloc.add(ReplyFeedLoadingEvent(
                    Filter.BY_CHALLENGE, widget.challengeId)),
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

  Widget _getReplyItem(Reply reply) {
    return Column(
      children: [
        UserReply(
          reply: reply,
        ),
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
