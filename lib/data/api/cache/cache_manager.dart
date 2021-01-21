//import 'dart:io';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

class CustomCacheManager {
  static const key = 'challengesCacheKey';
  static CacheManager instance = CacheManager(
    Config(
      key,
      stalePeriod: const Duration(days: 7),
      maxNrOfCacheObjects: 50,
      repo: JsonCacheInfoRepository(databaseName: key),
    ),
  );
}
