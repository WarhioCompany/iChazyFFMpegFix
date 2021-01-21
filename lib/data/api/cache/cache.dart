import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:ichazy/data/api/cache/cache_manager.dart';

class Cache {
  static String getUrl(String uuid) {
    return 'https://data.ichazy.com/${uuid[0]}/$uuid';
  }

  static Future<File> getFile(String url) async {
    CacheManager _cacheManager = CustomCacheManager.instance;
    FileInfo fileInfo = await _cacheManager.getFileFromCache(url);
    if (fileInfo == null) {
      FileInfo newFileInfo = await _cacheManager.downloadFile(url);
      return newFileInfo.file;
    } else {
      return fileInfo.file;
    }
  }

  static Future<Image> getImage(String url, {BoxFit fit}) async {
    CacheManager _cacheManager = CustomCacheManager.instance;
    File file = await _cacheManager.getSingleFile(url);
    return Image.file(file, fit: fit ?? BoxFit.cover);
  }
}
