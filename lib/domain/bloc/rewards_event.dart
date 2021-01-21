part of 'rewards_bloc.dart';

@immutable
abstract class RewardsEvent {}

class RewardsInitEvent extends RewardsEvent {}

class RewardsLoadingEvent extends RewardsEvent {}

class RewardsAddPostsEvent extends RewardsEvent {}

class RewardsGetBrandEvent extends RewardsEvent {}
