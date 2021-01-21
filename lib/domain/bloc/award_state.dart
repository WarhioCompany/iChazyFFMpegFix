part of 'award_cubit.dart';

@immutable
abstract class AwardState {}

class AwardInitial extends AwardState {}

class OpenBrandAwardState extends AwardState {
  final Brand brand;
  OpenBrandAwardState(this.brand);
}

class ShowConfirmAwardState extends AwardState {}
