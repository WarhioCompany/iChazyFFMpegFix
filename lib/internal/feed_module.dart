import 'package:ichazy/domain/bloc/feed_bloc.dart';
import 'package:ichazy/domain/bloc/feed_main_bloc.dart';
import 'package:ichazy/domain/bloc/feed_waiting_bloc.dart';
import 'package:ichazy/domain/bloc/feed_win_bloc.dart';
import 'package:ichazy/domain/bloc/reply_feed_bloc.dart';

import './dependencies/main_repository_module.dart';

class FeedModule {
  static FeedBloc feedBloc() {
    return FeedBloc(MainRepositoryModule.mainRepository());
  }

  static FeedMainBloc feedMainBloc() {
    return FeedMainBloc(MainRepositoryModule.mainRepository());
  }

  static ReplyFeedBloc replyFeedBloc() {
    return ReplyFeedBloc(MainRepositoryModule.mainRepository());
  }

  static FeedWaitingBloc feedWaitingBloc() {
    return FeedWaitingBloc(MainRepositoryModule.mainRepository());
  }

  static FeedWinBloc feedWinBloc() {
    return FeedWinBloc(MainRepositoryModule.mainRepository());
  }
}
