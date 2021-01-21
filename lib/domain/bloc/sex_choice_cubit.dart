import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ichazy/domain/model/user.dart';

class SexChoiceCubit extends Cubit<Sex> {
  final Sex initState;
  SexChoiceCubit(this.initState) : super(initState);

  void setMale() => emit(Sex.MALE);
  void setFemale() => emit(Sex.FEMALE);
}
