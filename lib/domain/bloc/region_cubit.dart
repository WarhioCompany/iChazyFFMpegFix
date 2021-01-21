import 'package:bloc/bloc.dart';
import 'package:ichazy/domain/model/region.dart';
import 'package:meta/meta.dart';

part 'region_state.dart';

class RegionCubit extends Cubit<RegionState> {
  RegionCubit(this.currentRegion) : super(RegionInitial());
  Region currentRegion;

  void changeRegion(String id) {
    currentRegion = RegionSingleton().regions[id];
    emit(RefreshRegion());
  }
}
