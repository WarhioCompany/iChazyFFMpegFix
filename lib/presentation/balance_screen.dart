import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ichazy/domain/bloc/balance_bloc.dart';
import 'package:ichazy/domain/model/balance_response.dart';
import 'package:ichazy/internal/dependencies/main_repository_module.dart';
import 'package:ichazy/presentation/colors/colors.dart';
import 'package:ichazy/presentation/style/date_time.dart';

class BalanceScreen extends StatefulWidget {
  final int _balance;

  BalanceScreen(this._balance);

  @override
  _BalanceScreenState createState() => _BalanceScreenState();
}

class _BalanceScreenState extends State<BalanceScreen> {
  final _scrollController = ScrollController();
  final _balanceBloc = BalanceBloc(MainRepositoryModule.mainRepository());

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _balanceBloc.add(BalanceLoadingEvent());
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _balanceBloc.close();
    super.dispose();
  }

  void _onScroll() async {
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;
    if (maxScroll == currentScroll) {
      _balanceBloc.add(BalanceAddOperations());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _getAppBar(),
      body: _getBody(context),
    );
  }

  Widget _getAppBar() {
    return AppBar(
      brightness: Brightness.light,
      elevation: 0,
      centerTitle: true,
      title: Text(
        'Баланс',
        style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: AppColor.MAIN,
            fontFamily: 'SF'),
      ),
    );
  }

  Widget _getBody(BuildContext context) {
    return SafeArea(
      child: BlocConsumer(
        cubit: _balanceBloc,
        listener: (context, state) {},
        builder: (context, state) {
          if (state is BalanceLoadingState) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          if (state is BalanceResultState) {
            print(state.operations);
            return _getFeedBuilder(state.operations);
          }
          return Container();
        },
      ),
    );
  }

  Widget _getFeedBuilder(List<BalanceOperation> operations) {
    return ListView(
      controller: _scrollController,
      children: [
        Row(
          mainAxisSize: MainAxisSize.max,
          children: [
            Expanded(
              child: Container(
                padding: EdgeInsets.fromLTRB(20, 25, 0, 20),
                color: AppColor.ORANGE,
                child: Text(
                  '${widget._balance} M',
                  style: TextStyle(
                    fontSize: 25,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            )
          ],
        ),
        ..._getListChallenges(operations),
      ],
    );
  }

  List<Widget> _getListChallenges(List<BalanceOperation> operations) {
    return operations
        .map((operation) => _getReplyItem(operation))
        .toList(growable: true);
  }

  Widget _getReplyItem(BalanceOperation operation) {
    return _getTile(operation);
  }

  Widget _getTile(BalanceOperation operation) {
    return ListTile(
      title:
          Text('${BalanceOperation.reasonToText(operation.reason)}#челлендж'),
      subtitle: Text(Date.dateFromInt(operation.createTs)),
      trailing: Text(
        '${operation.value > 0 ? '+' : ''}${operation.value}',
        style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24,
            color: operation.value > 0
                ? Color.fromRGBO(33, 190, 136, 1)
                : Color.fromRGBO(224, 0, 0, 1)),
      ),
    );
  }
}
