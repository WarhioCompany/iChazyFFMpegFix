import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ichazy/domain/bloc/feed_bloc.dart';
import 'package:ichazy/domain/model/brand.dart';
import 'package:ichazy/domain/model/challenge.dart';
import 'package:ichazy/internal/feed_module.dart';
import 'package:ichazy/presentation/colors/colors.dart';
import 'package:ichazy/presentation/elements/challenge_card.dart';
import 'package:ichazy/presentation/elements/challenge_card_small.dart';
import 'package:ichazy/presentation/elements/custom_divider.dart';
import 'package:url_launcher/url_launcher.dart';

class BrandScreen extends StatefulWidget {
  final Brand _brand;

  BrandScreen(this._brand);

  @override
  _BrandScreenState createState() => _BrandScreenState();
}

class _BrandScreenState extends State<BrandScreen>
    with TickerProviderStateMixin {
  TabController _nestedTabController;
  final _feedBloc = FeedModule.feedBloc();
  final _scrollController = ScrollController();
  List<Challenge> challengeShared = [];
  int type = 0;

  @override
  void initState() {
    super.initState();
    _nestedTabController = TabController(length: 2, vsync: this);
    _scrollController.addListener(_onScroll);
    _feedBloc
        .add(FeedLoadingEvent(Filter.ALL_ACTIVE_BY_REGIONS, widget._brand.id));
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
    if (maxScroll == currentScroll) {
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
        'Профиль бренда',
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
        if (state is FeedResultState) {
          challengeShared = state.challenges;
          return _getFeedBuilder(challengeShared);
        }
        return Container();
      },
    );
  }

  Widget _getFeedBuilder(List<Challenge> challenges) {
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
      body: _getTabBarView(challenges),
    );
  }

  TabBarView _getTabBarView(List<Challenge> challenges) {
    print(challenges.length);
    if (challenges.length == 1) {
      return TabBarView(
        controller: _nestedTabController,
        children: [
          _getGrid(_getListSmallChallenges(challenges)),
          Container(
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _getChallengeItem(challenges.single),
                ],
              ),
            ),
          ),
        ],
      );
    }
    return TabBarView(
      controller: _nestedTabController,
      children: [
        _getGrid(_getListSmallChallenges(challenges)),
        _getFeed(_getListChallenges(challenges)),
      ],
    );
  }

  List<Widget> _getListChallenges(List<Challenge> challenges) {
    return challenges
        .map((challenge) => _getChallengeItem(challenge))
        .toList(growable: true);
  }

  List<Widget> _getListSmallChallenges(List<Challenge> challenges) {
    return challenges
        .map((challenge) => _getSmallChallengeItem(challenge))
        .toList(growable: true);
  }

  Widget _getChallengeItem(Challenge challenge) {
    return ChallengeCard(challenge, true, true);
  }

  Widget _getSmallChallengeItem(Challenge challenge) {
    return ChallengeCardSmall(challenge, true);
  }

  Widget _getFeed(List<Widget> widgets) {
    List<Widget> temp = [];
    for (int i = 0; i < widgets.length; i++) {
      temp.add(widgets[i]);
      if (i != widgets.length - 1) {
        temp.add(AppDivider());
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
          height: 320,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _getAvatar(),
              SizedBox(
                height: 15,
              ),
              _getName(),
              SizedBox(
                height: 15,
              ),
              _getDescription(),
              SizedBox(
                height: 15,
              ),
              _getUrl(),
              SizedBox(
                height: 15,
              ),
              //if (desc.length > 0) _getDescription(desc)
            ],
          ),
        ),
        AppDivider(),
      ],
    );
  }

  Widget _getAvatar() {
    final avatar = widget._brand.uuidLogo1;
    if (avatar == null) {
      return Container(
        margin: EdgeInsets.symmetric(vertical: 15),
        height: 60,
        child: GestureDetector(
          onTap: () {},
          child: Image.asset('assets/icons/png/tab-profile-off.png'),
        ),
      );
    } else {
      return FutureBuilder<Image>(
          future: widget._brand.getProfileImage(),
          builder: (context, AsyncSnapshot<Image> snapshot) {
            if (snapshot.connectionState == ConnectionState.done ||
                snapshot.hasData) {
              return Container(height: 110, child: snapshot.data);
            } else {
              return CircularProgressIndicator();
            }
          });
    }
  }

  Widget _getName() {
    return Text(
      widget._brand.name,
      style: TextStyle(
          fontWeight: FontWeight.w600, fontFamily: 'SF', fontSize: 20),
    );
  }

  Widget _getDescription() {
    return Text(
      widget._brand.description,
      textAlign: TextAlign.center,
      style: TextStyle(fontSize: 18),
    );
  }

  Widget _getUrl() {
    return GestureDetector(
      onTap: () => _launchURL(widget._brand.url),
      child: Text(widget._brand.url,
          style: TextStyle(color: Colors.blue, fontSize: 18)),
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

  _launchURL(String url) async {
    String _url = 'https://$url';
    if (await canLaunch(_url)) {
      await launch(_url);
    } else {
      throw 'Could not launch $_url';
    }
  }
}
