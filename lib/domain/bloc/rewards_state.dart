part of 'rewards_bloc.dart';

@immutable
abstract class RewardsState {}

class RewardsInitial extends RewardsState {}

class RewardsLoadingState extends RewardsState {}

class RewardsHardLoadingState extends RewardsLoadingState {}

class RewardsResultState extends RewardsState {
  final List<Award> rewards;
  final bool hasReachedThreshold;
  RewardsResultState(this.rewards, this.hasReachedThreshold);

  RewardsResultState copyWith({
    List<Award> rewards,
    bool hasReachedThreshold,
  }) {
    return RewardsResultState(rewards ?? this.rewards,
        hasReachedThreshold ?? this.hasReachedThreshold);
  }
}

class RewardsErrorState extends RewardsState {
  final error;
  RewardsErrorState(this.error);
}
