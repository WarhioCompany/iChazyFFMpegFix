import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ichazy/domain/bloc/rewards_bloc.dart';
import 'package:ichazy/domain/model/award.dart';
import 'package:ichazy/internal/dependencies/main_repository_module.dart';
import 'package:ichazy/presentation/colors/colors.dart';
import 'package:ichazy/presentation/elements/award_card.dart';
import 'package:ichazy/presentation/elements/custom_divider.dart';

class IntegratedRewardsFeed extends StatefulWidget {
  final bool isUsed;
  IntegratedRewardsFeed(this.isUsed);

  @override
  _IntegratedRewardsFeedState createState() => _IntegratedRewardsFeedState();
}

class _IntegratedRewardsFeedState extends State<IntegratedRewardsFeed> {
  final _scrollController = ScrollController();
  RewardsBloc _rewardsBloc;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _rewardsBloc =
        RewardsBloc(MainRepositoryModule.mainRepository(), widget.isUsed);
    _rewardsBloc.add(RewardsLoadingEvent());
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _rewardsBloc.close();
    super.dispose();
  }

  void _onScroll() async {
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;
    if (maxScroll == currentScroll) {
      _rewardsBloc.add(RewardsAddPostsEvent());
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (BuildContext context) => _rewardsBloc,
      child: _getContentBuilder(),
    );
  }

  Widget _getContentBuilder() {
    const Key centerKey = ValueKey('bottom-sliver-list');
    return BlocConsumer<RewardsBloc, RewardsState>(listener: (context, state) {
      if (state is RewardsErrorState) {
        Flushbar(
          backgroundColor: AppColor.DARK_BLUE2,
          message: "При загрузке данных что-то пошло не так",
          mainButton: FlatButton(
            onPressed: () => _rewardsBloc.add(RewardsLoadingEvent()),
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
      if (previous is RewardsHardLoadingState &&
          current is RewardsResultState) {
        return true;
      }
      if (previous is RewardsHardLoadingState && current is RewardsErrorState) {
        return true;
      }
      if (previous is RewardsLoadingState && current is RewardsResultState) {
        return true;
      }
      if (previous is RewardsResultState && current is RewardsResultState) {
        return true;
      }
      return false;
    }, builder: (context, state) {
      if (state is RewardsHardLoadingState) {
        Center(child: CircularProgressIndicator());
      }
      if (state is RewardsResultState) {
        if (state.rewards.isEmpty)
          return Center(child: Text('У вас пока нет наград'));
        return ListView.builder(
          key: centerKey,
          itemBuilder: (BuildContext context, int index) {
            return index >= state.rewards.length
                ? _loader()
                : _getReplyItem(state.rewards[index]);
          },
          itemCount: state.rewards.length,
        );
      }
      if (state is RewardsErrorState) {
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
                onPressed: () => _rewardsBloc.add(RewardsLoadingEvent()),
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

  Widget _getReplyItem(Award award) {
    return Column(
      children: [
        AwardCard(award),
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
