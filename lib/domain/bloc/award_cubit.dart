import 'package:bloc/bloc.dart';
import 'package:ichazy/domain/model/brand.dart';
import 'package:ichazy/internal/dependencies/main_repository_module.dart';
import 'package:meta/meta.dart';

part 'award_state.dart';

class AwardCubit extends Cubit<AwardState> {
  final _mainRepository = MainRepositoryModule.mainRepository();

  AwardCubit() : super(AwardInitial());

  void sendIsUsed(String promoCodeId, bool isUsed) async {
    await _mainRepository.setIsUsedPromoCode(promoCodeId, isUsed);
  }

  void askConfirm() {
    emit(ShowConfirmAwardState());
  }

  void openBrandPage(String brandId) async {
    try {
      //await _mainRepository.checkSession();
      var brand = await _mainRepository.getBrandProfile(brandId);
      emit(OpenBrandAwardState(brand));
    }
    // on SessionIdNotFoundException {
    //   yield ChallengeLoginState();
    // }
    catch (e, s) {
      print(e);
      _mainRepository.addLogString('ChallengeBloc');
      _mainRepository.addLogString('$e\n$s');
    }
  }
}
