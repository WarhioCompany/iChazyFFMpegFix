import 'package:ichazy/data/api/api_util.dart';
import 'package:ichazy/domain/repository/main_repository.dart';
import 'package:ichazy/data/repository/main_data_repository.dart';
import 'package:ichazy/internal/dependencies/util_module.dart';

class MainRepositoryModule {
  static MainRepository _mainDataRepository;

  static MainRepository mainRepository() {
    if (_mainDataRepository == null) {
      _mainDataRepository = MainDataRepository(
        UtilModule.util(),
        ApiUtil(),
      );
    }
    return _mainDataRepository;
  }
}