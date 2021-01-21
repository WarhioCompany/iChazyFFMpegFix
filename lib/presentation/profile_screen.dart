import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ichazy/domain/bloc/feed_bloc.dart';
import 'package:ichazy/domain/model/challenge.dart';
import 'package:ichazy/domain/model/reply_data.dart';
import 'package:ichazy/domain/model/user.dart';
import 'package:ichazy/internal/feed_module.dart';
import 'package:ichazy/presentation/colors/colors.dart';
import 'package:ichazy/presentation/elements/custom_divider.dart';
import 'package:ichazy/presentation/elements/user_reply.dart';

class ProfileScreen extends StatefulWidget {
  final User _user;

  ProfileScreen(this._user);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with TickerProviderStateMixin {
  TabController _nestedTabController;
  final _feedBloc = FeedModule.feedBloc();
  final _scrollController = ScrollController();
  final _scrollThreshold = 300.0;
  //List<Widget> widgets = [];
  List<Reply> repliesShared = [];
  int type = 0;

  @override
  void initState() {
    super.initState();
    _nestedTabController = TabController(length: 2, vsync: this);
    _scrollController.addListener(_onScroll);
    _feedBloc.add(FeedLoadingEvent(Filter.BY_USER, widget._user.id));
  }

  @override
  void dispose() {
    _nestedTabController.dispose();
    _scrollController.dispose();
    _feedBloc.close();
    super.dispose();
  }

  void _onScroll() async {
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;
    if (maxScroll - currentScroll <= _scrollThreshold) {
      _feedBloc.add(FeedAddPosts());
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: _getAppBar(),
        body: _getBody(),
      ),
    );
  }

  Widget _getAppBar() {
    return AppBar(
      brightness: Brightness.light,
      centerTitle: true,
      title: Text(
        'Профиль пользователя',
        style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: AppColor.MAIN,
            fontFamily: 'SF'),
      ),
      shadowColor: Colors.white.withOpacity(0),
      bottom: AppDividerPreferred(),
    );
  }

  Widget _getBody() {
    return BlocProvider(
      create: (BuildContext context) => _feedBloc,
      child: _getContentBuilder(),
    );
  }

  Widget _getContentBuilder() {
    return BlocBuilder<FeedBloc, FeedState>(
      builder: (context, state) {
        if (state is FeedLoadingState) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }
        if (state is FeedRepliesResultState) {
          repliesShared = state.replies;
          //return _getFeedBuilder(challengeShared);
          return _getFeedBuilder(repliesShared);
        }
        return Container();
      },
    );
  }

  Widget _getFeedBuilder(List<Reply> replies) {
    return NestedScrollView(
      controller: _scrollController,
      headerSliverBuilder: (BuildContext context, bool boxIsScrolled) {
        return [
          SliverPadding(
            padding: EdgeInsets.all(0),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _getHeader(),
                _getButtons(),
                AppDivider(),
              ]),
            ),
          ),
        ];
      },
      body: TabBarView(
        controller: _nestedTabController,
        children: [
          _getGrid(_getListSmallChallenges(replies)),
          _getFeed(_getListChallenges(replies)),
        ],
      ),
    );
  }

  List<Widget> _getListChallenges(List<Reply> replies) {
    return replies.map((reply) => _getReplyItem(reply)).toList(growable: true);
  }

  List<Widget> _getListSmallChallenges(List<Reply> replies) {
    return replies
        .map((reply) => _getSmallReplyItem(reply))
        .toList(growable: true);
  }

  Widget _getReplyItem(Reply reply) {
    return UserReply(reply: reply);
  }

  Widget _getSmallReplyItem(Reply reply) {
    return UserReply(
      reply: reply,
      small: true,
    );
  }

  Widget _getFeed(List<Widget> widgets) {
    List<Widget> temp = [];
    for (int i = 0; i < widgets.length; i++) {
      temp.add(widgets[i]);
      if (i != widgets.length - 1) {
        temp.add(SizedBox(
          height: 18,
        ));
      }
    }
    return ListView(children: temp);
  }

  Widget _getGrid(List<Widget> widgets) {
    return GridView(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 2,
        mainAxisSpacing: 2,
      ),
      children: widgets,
    );
  }

  Widget _getHeader() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: EdgeInsets.symmetric(vertical: 20),
          height: 190,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _getAvatar(),
              Spacer(),
              _getName(),
              //if (desc.length > 0) _getDescription(desc)
            ],
          ),
        ),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          alignment: Alignment(-1, 0),
          child: Text(
            'Выполненные челленджи',
            style: TextStyle(fontSize: 20),
          ),
        ),
        AppDivider(),
      ],
    );
  }

  Widget _getAvatar() {
    final avatar = widget._user.avatarId;
    if (avatar != null) {
      return FutureBuilder<Image>(
          future: widget._user.getProfileImage(),
          builder: (context, AsyncSnapshot<Image> snapshot) {
            if (snapshot.connectionState == ConnectionState.done ||
                snapshot.hasData) {
              return CircleAvatar(
                backgroundColor: Colors.white,
                radius: 50,
                child: ClipOval(
                  child: snapshot.data,
                ),
              );
            } else {
              return CircularProgressIndicator();
            }
          });
    } else {
      return Container(
        margin: EdgeInsets.symmetric(vertical: 15),
        height: 32,
        child: GestureDetector(
          onTap: () {},
          child: Image.asset('assets/icons/png/tab-profile-off.png'),
        ),
      );
    }
  }

  Widget _getName() {
    return Text(
      widget._user.nickname,
      style: TextStyle(
          fontWeight: FontWeight.w600, fontFamily: 'SF', fontSize: 20),
    );
  }

  Widget _getButtons() {
    return Container(
      constraints: BoxConstraints.expand(height: 50),
      child: TabBar(
        controller: _nestedTabController,
        //isScrollable: true,
        tabs: <Widget>[
          Tab(
            child: Image.asset(
              'assets/icons/png/icon-tiles.png',
              height: 25,
            ),
          ),
          Tab(
            child: Image.asset(
              'assets/icons/png/tab-list-off.png',
              height: 25,
            ),
          ),
        ],
      ),
    );
  }
}
