import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ichazy/domain/bloc/reply_card_bloc.dart';
import 'package:ichazy/domain/model/brand.dart';
import 'package:ichazy/domain/model/create_reply_data.dart';
import 'package:ichazy/domain/model/reply_data.dart';
import 'package:ichazy/domain/model/user.dart';
import 'package:ichazy/presentation/colors/colors.dart';
import 'package:ichazy/presentation/elements/custom_divider.dart';
import 'package:ichazy/presentation/profile_screen.dart';

import 'brand_screen.dart';
import 'elements/reply_card.dart';

class ReplyScreen extends StatefulWidget {
  final Reply _reply;
  final String userId;
  ReplyScreen(this._reply, this.userId);

  @override
  _ReplyScreenState createState() => _ReplyScreenState();
}

class _ReplyScreenState extends State<ReplyScreen> {
  ReplyCardCubit _cubit = ReplyCardCubit();
  String replyUserId;

  @override
  void initState() {
    super.initState();
    replyUserId = widget._reply.createReply.userId;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _getAppBar(),
      body: _getBody(),
    );
  }

  Widget _getAppBar() {
    if (widget.userId == replyUserId) {
      return AppBar(
        brightness: Brightness.light,
        title: _getTitle('Моя заявка'),
        centerTitle: true,
        shadowColor: Colors.white.withOpacity(0),
      );
    } else {
      return AppBar(
        brightness: Brightness.light,
        title: _getTitle('Заявка пользователя'),
        centerTitle: true,
        shadowColor: Colors.white.withOpacity(0),
      );
    }
  }

  Widget _getBody() {
    return BlocProvider<ReplyCardCubit>(
      create: (context) {
        return _cubit;
      },
      child: BlocListener<ReplyCardCubit, ReplyCardState>(
        listener: (context, state) {
          print('state = $state');
          if (state is OpenProfileState) _openProfilePage(state.user);
          if (state is OpenBrandState) _openBrandProfile(state.brand);
          if (state is ErrorReplyCardState) print(state.error);
          if (state is ExitScreen) _exitScreen();
        },
        child: ListView(
          children: [
            ReplyCard(
              reply: widget._reply,
            ),
            _getTitleBar(widget._reply),
            AppDivider(),
            if (widget.userId != replyUserId)
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: GestureDetector(
                  onTap: () {
                    _cubit.openProfile(widget._reply);
                  },
                  child: Container(
                    color: Colors.transparent,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: 20,
                        ),
                        Text(
                          'Профиль пользователя',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 19),
                        ),
                        SizedBox(
                          height: 18,
                        ),
                        Row(
                          children: [
                            _getProfile(widget._reply.avatarUserId),
                            Text(
                              widget._reply.userName,
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                            Spacer(),
                            Icon(
                              Icons.navigate_next,
                              size: 32,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            if (widget.userId == replyUserId &&
                widget._reply.createReply.approveState == ApproveState.NEW)
              _getCancelButton()
          ],
        ),
      ),
    );
  }

  Widget _getTitleBar(Reply reply) {
    return Container(
      padding: EdgeInsets.fromLTRB(8, 14, 8, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.only(left: 5),
            child: Text(
              '#${reply.hashTag}' ?? '#тэг',
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.bold,
                color: AppColor.TEXT_GRAY,
              ),
            ),
          ),
          Spacer(),
          _getBrandProfile(reply.createReply.brandId, reply.avatarBrandId),
        ],
      ),
    );
  }

  Widget _getTitle(String title) {
    return Text(
      title,
      style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 18,
          color: AppColor.DARK_BLUE2),
    );
  }

  Widget _getProfile(String avatarId) {
    return Container(
        margin: EdgeInsets.only(right: 6),
        child: GestureDetector(
          //onTap: () => _openProfilePage(user),
          child: FutureBuilder<Image>(
            future: Brand.getImage(avatarId),
            builder: (context, AsyncSnapshot<Image> snapshot) {
              if (snapshot.connectionState == ConnectionState.done ||
                  snapshot.hasData) {
                return CircleAvatar(
                  backgroundColor: Colors.white,
                  radius: 32,
                  child: ClipOval(
                    child: snapshot.data,
                  ),
                );
              } else {
                return Container();
              }
            },
          ),
        ));
  }

  Widget _getBrandProfile(String brandId, String avatarId) {
    print('avatarId');
    print(avatarId);
    return Container(
        margin: EdgeInsets.only(right: 8),
        child: GestureDetector(
          onTap: () => _cubit.openBrand(brandId),
          child: FutureBuilder<Image>(
            future: Brand.getImage(avatarId),
            builder: (context, AsyncSnapshot<Image> snapshot) {
              if (snapshot.connectionState == ConnectionState.done ||
                  snapshot.hasData) {
                return CircleAvatar(
                  //backgroundColor: Colors.white,
                  radius: 16,
                  child: ClipOval(
                    child: snapshot.data,
                  ),
                );
              } else {
                return Container();
              }
            },
          ),
        ));
  }

  Widget _getCancelButton() {
    return Center(
      child: RaisedButton(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        color: AppColor.ORANGE,
        onPressed: () =>
            _cubit.replyCancel(widget._reply.createReply.challengeId),
        child: Text(
          'Отменить заявку',
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  _openBrandProfile(Brand brand) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => BrandScreen(brand)),
    );
  }

  _openProfilePage(User user) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ProfileScreen(user)),
    );
  }

  _exitScreen() {
    Navigator.pop(
      context,
    );
  }
}
