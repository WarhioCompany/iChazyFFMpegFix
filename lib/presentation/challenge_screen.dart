import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ichazy/domain/bloc/reply_feed_bloc.dart';
import 'package:ichazy/domain/model/brand.dart';
import 'package:ichazy/domain/model/challenge.dart';
import 'package:ichazy/domain/model/reply_data.dart';
import 'package:ichazy/internal/feed_module.dart';
import 'package:ichazy/presentation/brand_screen.dart';
import 'package:ichazy/presentation/colors/colors.dart';
import 'package:ichazy/presentation/elements/challenge_card.dart';
import 'package:ichazy/presentation/elements/custom_divider.dart';
import 'package:route_observer_mixin/route_observer_mixin.dart';

import 'elements/user_reply.dart';

class ChallengeScreen extends StatefulWidget {
  final Challenge _challenge;

  ChallengeScreen(this._challenge);

  @override
  _ChallengeScreenState createState() => _ChallengeScreenState();
}

class _ChallengeScreenState extends State<ChallengeScreen>
    with RouteAware, RouteObserverMixin {
  final _replyBloc = FeedModule.replyFeedBloc();
  final _scrollThreshold = 100.0;
  final ScrollController _scrollController = ScrollController();
  List<Reply> repliesShared = [];

  @override
  void initState() {
    super.initState();
    print('feed');
    _scrollController.addListener(_onScroll);
    _replyBloc.add(
        ReplyFeedLoadingEvent(Filter.BY_CHALLENGE, widget._challenge.uuid));
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _replyBloc.close();
    super.dispose();
  }

  @override
  void didPopNext() {
    _replyBloc.add(
        ReplyFeedLoadingEvent(Filter.BY_CHALLENGE, widget._challenge.uuid));
    super.didPopNext();
  }

  void _onScroll() {
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;
    if (maxScroll - currentScroll <= _scrollThreshold) {
      _replyBloc.add(ReplyFeedAddPosts());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _getAppBar(),
      body: BlocProvider(
        create: (BuildContext context) => _replyBloc,
        child: _getBuilder(),
      ),
    );
  }

  Widget _getBuilder() {
    return BlocBuilder<ReplyFeedBloc, ReplyFeedState>(
        builder: (context, state) {
      if (state is ReplyFeedResultState) {
        repliesShared = state.replies;
        var newShared = _clearRepliesShared();
        if (newShared.isEmpty) {
          return _singleBody();
        }
        if (newShared.length == 1) {
          return _singleBody(reply: newShared.first);
        }
        return _getBody(newShared);
      }
      return Container();
    });
  }

  Widget _getAppBar() {
    return AppBar(
      brightness: Brightness.light,
      title: _getTitle(),
      actions: [
        _getProfile(widget._challenge.brand),
      ],
      centerTitle: true,
      shadowColor: Colors.white.withOpacity(0),
    );
  }

  Widget _getBody(List<Reply> replies) {
    print(replies);
    return NestedScrollView(
      controller: _scrollController,
      headerSliverBuilder: (BuildContext context, bool boxIsScrolled) {
        return [
          SliverPadding(
            padding: EdgeInsets.all(0),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                ChallengeCard(widget._challenge, false, false),
                AppDivider(),
                _getDescription(widget._challenge.about),
                AppDivider(),
                _getRepliesTitle(),
              ]),
            ),
          ),
        ];
      },
      body: _getFeed(_getListReplies(replies)),
    );
  }

  Widget _singleBody({Reply reply}) {
    if (reply != null) {
      return SingleChildScrollView(
        child: Column(
          children: [
            ChallengeCard(widget._challenge, false, false),
            AppDivider(),
            _getDescription(widget._challenge.about),
            AppDivider(),
            _getRepliesTitle(),
            UserReply(reply: reply),
          ],
        ),
      );
    }
    return SingleChildScrollView(
      child: Column(
        children: [
          ChallengeCard(widget._challenge, false, false),
          AppDivider(),
          _getDescription(widget._challenge.about),
          AppDivider(),
          _getRepliesTitle(),
        ],
      ),
    );
  }

  Widget _getFeed(List<Widget> widgets) {
    List<Widget> temp = [];
    for (int i = 0; i < widgets.length; i++) {
      temp.add(widgets[i]);
      temp.add(SizedBox(
        height: 18,
      ));
    }
    temp.remove(temp.last);
    return ListView(
      children: temp,
      shrinkWrap: true,
      addAutomaticKeepAlives: true,
      addRepaintBoundaries: true,
    );
  }

  List<Widget> _getListReplies(List<Reply> replies) {
    return replies
        .map((reply) => UserReply(reply: reply))
        .toList(growable: true);
  }

  Widget _getDescription(String description) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 20, horizontal: 50),
      alignment: Alignment.center,
      child: Text(
        description,
        style: TextStyle(
          fontSize: 15,
        ),
      ),
    );
  }

  Widget _getRepliesTitle() {
    if (widget._challenge.applicationCount != null &&
        widget._challenge.applicationCount != 0) {
      return Column(
        children: [
          SizedBox(
            height: 10,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'Заявки других пользователей',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
                Text(
                  '${widget._challenge.applicationCount} заявок',
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      );
    }
    return Container(
      margin: EdgeInsets.symmetric(vertical: 25, horizontal: 16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Заявки других пользователей',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 20),
          Center(
            child: Text(
              'Здесь ещё нет заявок',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
              maxLines: 2,
              softWrap: true,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _getTitle() {
    return Text(
      widget._challenge.name,
      style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 18,
          color: AppColor.DARK_BLUE2),
    );
  }

  Widget _getProfile(Brand brand) {
    return Container(
      margin: EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: () => _openProfilePage(brand),
        child: FutureBuilder<Image>(
            future: Brand.getImage(widget._challenge.brandAvatarId),
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
                return CircularProgressIndicator();
              }
            }),
      ),
    );
  }

  List<Reply> _clearRepliesShared() {
    List<String> ids = [];
    List<Reply> temp = [];
    repliesShared.forEach((element) {
      if (!ids.contains(element.createReply.id)) {
        ids.add(element.createReply.id);
        temp.add(element);
      }
    });
    return temp;
  }

  _openProfilePage(Brand brand) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => BrandScreen(brand)),
    );
  }
}
