import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ichazy/data/age_count.dart';
import 'package:ichazy/domain/bloc/account_screen_bloc.dart';
import 'package:ichazy/domain/bloc/feed_waiting_bloc.dart';
import 'package:ichazy/domain/bloc/feed_win_bloc.dart';
import 'package:ichazy/domain/bloc/sex_choice_cubit.dart';
import 'package:ichazy/domain/model/auth.dart';
import 'package:ichazy/domain/model/region.dart';
import 'package:ichazy/domain/model/reply_data.dart';
import 'package:ichazy/domain/model/user.dart';
import 'package:ichazy/internal/account_module.dart';
import 'package:ichazy/internal/feed_module.dart';
import 'package:ichazy/presentation/colors/colors.dart';
import 'package:ichazy/presentation/elements/custom_buttons.dart';
import 'package:ichazy/presentation/elements/custom_divider.dart';
import 'package:ichazy/presentation/registration_screen.dart';
import 'package:route_observer_mixin/route_observer_mixin.dart';

import 'elements/user_reply.dart';

class AccountScreen extends StatefulWidget {
  final User _user;

  AccountScreen(this._user);

  @override
  _AccountScreenState createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen>
    with TickerProviderStateMixin, RouteAware, RouteObserverMixin {
  TabController _nestedTabController;
  final _feedWaitingBloc = FeedModule.feedWaitingBloc();
  final _feedWinBloc = FeedModule.feedWinBloc();
  final _accountBloc = AccountModule.accountBloc();
  final _scrollController = ScrollController();
  TextEditingController _nicknameController;
  final _scrollThreshold = 300.0;
  DateTime birthday;
  Sex localSex;
  User user;
  bool canUse = true;
  int type = 0;

  @override
  void initState() {
    super.initState();
    _nestedTabController = TabController(length: 2, vsync: this);
    _scrollController.addListener(_onScroll);
    _nicknameController = TextEditingController(text: widget._user.nickname);
    birthday =
        DateTime.fromMillisecondsSinceEpoch(widget._user.birthday * 1000);
    localSex = widget._user.sex;
    _feedWaitingBloc.add(FeedWaitingLoadingEvent());
    _feedWinBloc.add(FeedWinLoadingEvent());
    _accountBloc.add(InitEvent(widget._user));
  }

  @override
  void dispose() {
    _nestedTabController.dispose();
    _scrollController.dispose();
    _feedWaitingBloc.close();
    _feedWinBloc.close();
    _accountBloc.close();
    super.dispose();
  }

  @override
  void didPopNext() {
    _feedWaitingBloc.add(FeedWaitingLoadingEvent());
    _feedWinBloc.add(FeedWinLoadingEvent());
    super.didPopNext();
  }

  void _onScroll() async {
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;
    if (maxScroll - currentScroll <= _scrollThreshold) {
      if (_nestedTabController.index == 0) {
        _feedWaitingBloc.add(FeedWaitingAddPosts());
      } else {
        _feedWinBloc.add(FeedWinAddPosts());
      }
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
        'Мой профиль',
        style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: AppColor.MAIN,
            fontFamily: 'SF'),
      ),
      shadowColor: Colors.white.withOpacity(0),
      actions: [
        RegionSingleton()
                .regions[widget._user.regionId]
                ?.getRegionImage(size: 30) ??
            Container(),
        _getMoreButton(),
      ],
      bottom: AppDividerPreferred(),
    );
  }

  Widget _getBody() {
    return BlocProvider(
      create: (BuildContext context) => _accountBloc,
      child: _getFeedBuilder(),
    );
  }

  Widget _getFeedBuilder() {
    return NestedScrollView(
      controller: _scrollController,
      headerSliverBuilder: (BuildContext context, bool boxIsScrolled) {
        return [
          SliverPadding(
            padding: EdgeInsets.all(0),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _getHeaderBuilder(),
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
          _getWaitingList(),
          _getWinList(),
        ],
      ),
    );
  }

  Widget _getWaitingList() {
    return BlocBuilder<FeedWaitingBloc, FeedWaitingState>(
      cubit: _feedWaitingBloc,
      builder: (context, state) {
        if (state is FeedWaitingLoadingState) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }
        if (state is FeedWaitingRepliesResultState) {
          if (state.replies.isEmpty) return _getEmptyText();
          return _getGrid(_getListReplies(state.replies));
        }
        return Container();
      },
    );
  }

  Widget _getWinList() {
    return BlocBuilder<FeedWinBloc, FeedWinState>(
      cubit: _feedWinBloc,
      builder: (context, state) {
        if (state is FeedWinLoadingState) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }
        if (state is FeedWinRepliesResultState) {
          if (state.replies.isEmpty) return _getEmptyText();
          return _getGrid(_getListReplies(state.replies));
        }
        return Container();
      },
    );
  }

  Widget _getEmptyText() {
    return Center(
      child: Container(
        padding: EdgeInsets.all(18),
        child: Text(
          'Вы еще не приняли участия ни в одном челлендже',
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  List<Widget> _getListReplies(List<Reply> replies) {
    return replies
        .map((reply) => _getSmallReplyItem(reply))
        .toList(growable: true);
  }

  Widget _getSmallReplyItem(Reply reply) {
    return UserReply(
      reply: reply,
      small: true,
    );
  }

  Widget _getMoreButton() {
    return Container(
      child: PopupMenuButton<String>(
        icon: Icon(Icons.more_vert),
        onSelected: (string) => choiceAction(string),
        itemBuilder: (context) => [
          PopupMenuItem(
            value: 'error',
            child: Text('Сообщить об ошибке'),
          ),
          if (!_accountBloc.isConfirmedEmail)
            PopupMenuItem(
              value: 'confirm',
              child: Text('Подтвердить email'),
            ),
          PopupMenuItem(
            value: 'exit',
            child: Text('Выйти'),
          ),
        ],
      ),
    );
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

  Widget _getHeaderBuilder() {
    return BlocConsumer(
      cubit: _accountBloc,
      listener: (context, state) {
        if (state is AccountScreenErrorState) _showError(state.error);
        if (state is ExitState) _exit();
      },
      buildWhen: (previous, current) {
        if (current is InitScreenState) {
          return true;
        }
        if (current is InfoScreenState) {
          return true;
        }
        if (current is ChangeScreenState) {
          return true;
        }
        if (previous is RefreshScreenState && current is ChangeScreenState) {
          return true;
        }
        return false;
      },
      builder: (context, state) {
        if (state is InitScreenState) {
          return _getHeader(widget._user);
        }
        if (state is InfoScreenState) {
          return _getHeader(state.user);
        }
        if (state is ChangeScreenState) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.symmetric(vertical: 20),
                //height: 360,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _getAvatar(state.user, true),
                    SizedBox(
                      height: 20,
                    ),
                    _getEditAccount(state.auth),
                  ],
                ),
              ),
              AppDivider(),
            ],
          );
        }
        return Container();
      },
    );
  }

  Widget _getHeader(User user) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: EdgeInsets.symmetric(vertical: 20),
          height: 250,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _getAvatar(user, false),
              SizedBox(
                height: 21,
              ),
              _getName(user),
              SizedBox(
                height: 7,
              ),
              AppButtons.circleButton(
                'Редактировать',
                () {
                  _accountBloc.add(OpenChangeScreenEvent(user));
                },
                AppColor.ORANGE3,
                160,
              ),
            ],
          ),
        ),
        AppDivider(),
      ],
    );
  }

  Widget _getAvatar(User user, bool edit) {
    if (user.avatarId != null || user.avatarId == '') {
      if (edit) {
        return Stack(
          children: [
            Container(
              foregroundDecoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.black.withAlpha(35),
              ),
              child: GestureDetector(
                onTap: () => _accountBloc.add(AvatarChangeEvent()),
                child: FutureBuilder<Image>(
                    future: user.getProfileImage(),
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
                    }),
              ),
            ),
            Positioned(
              child: Icon(
                Icons.add,
                color: Colors.white,
              ),
              top: 37.5,
              left: 37.5,
            ),
          ],
        );
      } else {
        return FutureBuilder<Image>(
            future: user.getProfileImage(),
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
      }
    } else {
      if (edit) {
        return Ink(
          child: GestureDetector(
            onTap: () => _accountBloc.add(AvatarChangeEvent()),
            child: Container(
              margin: EdgeInsets.symmetric(vertical: 15),
              height: 62,
              child: GestureDetector(
                onTap: () {},
                child: Image.asset('assets/icons/png/tab-profile-off.png'),
              ),
            ),
          ),
        );
      } else {
        return Container(
          margin: EdgeInsets.symmetric(vertical: 15),
          height: 62,
          child: GestureDetector(
            onTap: () {},
            child: Image.asset('assets/icons/png/tab-profile-off.png'),
          ),
        );
      }
    }
  }

  Widget _getName(User user) {
    String name = user.nickname ?? 'undefined';
    return Text(
      name,
      style: TextStyle(
        fontWeight: FontWeight.w500,
        fontFamily: 'SF',
        fontSize: 20,
        color: AppColor.DARK_BLUE2,
      ),
    );
  }

  Widget _getEditAccount(List<Auth> auth) {
    List<Auth> cleared = clearedAuth(auth);
    print(cleared.length);
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (cleared.isNotEmpty) _getAuthRows(cleared),
          if (cleared.isNotEmpty)
            SizedBox(
              height: 30,
            ),
          _getRow('Никнейм', _getField(_nicknameController)),
          SizedBox(
            height: 30,
          ),
          _getRow('Возраст', _getDatePicker(birthday)),
          SizedBox(
            height: 20,
          ),
          _getRow('Пол', _getSexChoice(localSex)),
          SizedBox(
            height: 10,
          ),
          _getSaveButton(),
        ],
      ),
    );
  }

  List<Auth> clearedAuth(List<Auth> auth) {
    if (auth.isEmpty) return auth;
    final List<Auth> localAuth = auth;
    localAuth.removeWhere((login) =>
        login.authType != AuthType.CELLPHONE_SMS &&
        login.authType != AuthType.EMAIL);
    return localAuth;
  }

  Widget _getAuthRows(List<Auth> auth) {
    print(auth.length);
    if (auth.length == 1) {
      return _getAuthRow(auth.first);
    } else if (auth.length == 2) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _getAuthRow(auth.first),
          SizedBox(
            height: 30,
          ),
          _getAuthRow(auth.last),
        ],
      );
    } else
      throw Exception('auth > 2');
  }

  Widget _getAuthRow(Auth auth) {
    String name;
    if (auth.authType == AuthType.CELLPHONE_SMS) {
      name = 'Телефон';
    } else if (auth.authType == AuthType.EMAIL) {
      name = 'Почта';
    }
    return _getRow(
        name,
        Text(
          auth.primaryId,
          style: TextStyle(
              //fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Colors.black54),
        ));
  }

  Widget _getField(TextEditingController _controller) {
    return Container(
      width: 200,
      child: TextField(
        decoration: InputDecoration(
          isDense: true,
          isCollapsed: true,
          border: InputBorder.none,
          floatingLabelBehavior: FloatingLabelBehavior.never,
        ),
        autocorrect: false,
        maxLines: 1,
        controller: _controller,
        keyboardType: TextInputType.text,
        textAlign: TextAlign.end,
        style: TextStyle(
          fontSize: 16,
        ),
      ),
    );
  }

  Widget _getSexChoice(Sex sex) {
    return BlocProvider<SexChoiceCubit>(
      create: (context) {
        return SexChoiceCubit(sex);
      },
      child: BlocConsumer<SexChoiceCubit, Sex>(
        listener: (context, state) {
          if (state == Sex.FEMALE) localSex = Sex.FEMALE;
          if (state == Sex.MALE) localSex = Sex.MALE;
        },
        builder: (context, state) {
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Radio(
                onChanged: (value) {
                  BlocProvider.of<SexChoiceCubit>(context).setMale();
                },
                value: Sex.MALE,
                groupValue: BlocProvider.of<SexChoiceCubit>(context).state,
              ),
              Text('М'),
              SizedBox(
                width: 25,
              ),
              Radio(
                onChanged: (value) {
                  BlocProvider.of<SexChoiceCubit>(context).setFemale();
                },
                value: Sex.FEMALE,
                groupValue: BlocProvider.of<SexChoiceCubit>(context).state,
              ),
              Text('Ж'),
            ],
          );
        },
      ),
    );
  }

  Widget _getDatePicker(DateTime dateTime) {
    birthday = dateTime;
    final DateTime lastDate = AgeCount.lastDate();
    return GestureDetector(
      onTap: () async {
        DateTime newDate = await showDatePicker(
          context: context,
          initialDate: dateTime,
          firstDate: DateTime(1950),
          lastDate: lastDate,
        );
        birthday = newDate ?? birthday;
        _accountBloc.add(RefreshPageEvent());
      },
      child: Text(
        '${AgeCount.countAge(birthday)}',
        style: TextStyle(fontSize: 16),
      ),
    );
  }

  Widget _getRow(String name, Widget field) {
    return Row(
      children: [
        Text(
          '$name:',
          textAlign: TextAlign.left,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        Expanded(child: Container()),
        field,
      ],
    );
  }

  Widget _getSaveButton() {
    return AppButtons.circleButton(
        'Сохранить',
        () => _accountBloc.add(SaveChangesEvent(
            _nicknameController.text,
            birthday,
            localSex,
            widget._user.regionId,
            widget._user.regionMask)),
        AppColor.LIGHT_BLUE2,
        120);
  }

  Widget _getButtons() {
    return Container(
      constraints: BoxConstraints.expand(height: 50),
      child: TabBar(
        controller: _nestedTabController,
        tabs: <Widget>[
          Tab(
            child: Image.asset(
              'assets/icons/png/icon-my-moder-off.png',
              height: 25,
            ),
          ),
          Tab(
            child: Image.asset(
              'assets/icons/png/icon-my-awards-off.png',
              height: 25,
            ),
          ),
        ],
      ),
    );
  }

  _getBugDialog() {
    return Dialog(
      insetPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
      elevation: 3,
      //backgroundColor: Colors.white.withOpacity(0.9),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Align(
              alignment: Alignment(0.94, 0.88),
              child: Container(
                width: 32,
                padding: EdgeInsets.zero,
                child: Material(
                  color: AppColor.ORANGE2,
                  shape: CircleBorder(),
                  child: IconButton(
                    iconSize: 21,
                    padding: EdgeInsets.all(5),
                    icon: Icon(
                      Icons.clear,
                      color: Colors.white,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 22, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.all(Radius.circular(20)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.grey[200],
                      border: InputBorder.none,
                      hintMaxLines: 2,
                      hintText: 'Возникли ошибки? \nНапишите нам',
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide(
                          color: Colors.grey[200],
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide(
                          color: Colors.grey[200],
                        ),
                      ),
                    ),
                    maxLines: 4,
                  ),
                  SizedBox(
                    height: 40,
                  ),
                  _getDialogButton(),
                  SizedBox(
                    height: 60,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  _getDialogButton() {
    return Ink(
      //width: 160,
      decoration: const ShapeDecoration(
        //color: AppColor.LIGHT_BLUE2,
        shape: RoundedRectangleBorder(),
      ),
      child: RaisedButton(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(40),
        ),
        color: AppColor.BLUE2,
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        onPressed: () => print('hi'),
        child: Text(
          'Отправить сообщение',
          style: TextStyle(
              fontFamily: 'SF',
              fontSize: 20,
              color: Colors.white,
              fontWeight: FontWeight.w300),
        ),
      ),
    );
  }

  _showError(error) {
    Flushbar(
      backgroundColor: AppColor.DARK_BLUE2,
      message: error,
      isDismissible: true,
      duration: Duration(seconds: 3),
      dismissDirection: FlushbarDismissDirection.HORIZONTAL,
    )..show(context);
  }

  void choiceAction(String command) {
    if (command == 'error') {
      _openBugDialog();
    } else if (command == 'log') {
      _openLogReport();
    } else if (command == 'confirm') {
      _accountBloc.add(ConfirmEmailEvent());
    } else if (command == 'exit') {
      _accountBloc.add(ExitEvent());
    }
  }

  _getLogDialog() {
    return BlocBuilder(
      cubit: _accountBloc,
      builder: (context, state) {
        if (state is LogState) {
          return Dialog(
            backgroundColor: Colors.white,
            child: Ink(
              child: GestureDetector(
                onTap: () {
                  Clipboard.setData(ClipboardData(text: state.log));
                  _showError('Текст скопирован');
                },
                child: SingleChildScrollView(
                  child: Container(
                    margin: EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                    child: Text(
                      state.log,
                      style: TextStyle(
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        } else {
          return Container();
        }
      },
    );
  }

  void _openLogReport() async {
    _accountBloc.add(LogEvent());
    await showDialog(context: context, builder: (_) => _getLogDialog());
  }

  void _openBugDialog() async {
    await showDialog(context: context, builder: (_) => _getBugDialog());
  }

  _exit() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => RegistrationScreen()),
    );
  }
}
