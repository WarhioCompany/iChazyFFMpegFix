import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ichazy/data/api/ethernet/response.dart';
import 'package:ichazy/internal/dependencies/main_repository_module.dart';

class BalanceCubit extends Cubit<BalanceState> {
  final _mainRepository = MainRepositoryModule.mainRepository();
  int _balanceValue = 0;
  BalanceCubit() : super(null);

  int get balanceValue => _balanceValue;

  Future<void> init() async {
    print('getBalance');
    try {
      int value = await _mainRepository.getBalance();
      print(value);
      _balanceValue = value;
      emit(RefreshBalanceState());
    } catch (e, s) {
      print(e);
      _mainRepository.addLogString('BalanceCubit');
      _mainRepository.addLogString('$e\n$s');
    }
  }

  Future<void> openBalanceScreen() async {
    try {
      await _mainRepository.getBalance();
      emit(OpenBalanceState());
    } on SessionIdNotFoundException {
      _mainRepository.disconnect();
      emit(OpenLoginState());
    } catch (e, s) {
      print(e);
      _mainRepository.addLogString('BalanceCubit');
      _mainRepository.addLogString('$e\n$s');
      emit(ErrorBalanceState(e));
    }
  }
}

abstract class BalanceState {}

class RefreshBalanceState extends BalanceState {}

class OpenBalanceState extends BalanceState {}

class OpenLoginState extends BalanceState {}

class ErrorBalanceState extends BalanceState {
  final error;
  ErrorBalanceState(this.error);
}
