import 'package:flutter/material.dart';
import 'package:ichazy/data/api/cache/cache.dart';
import 'package:ichazy/internal/dependencies/main_repository_module.dart';
import 'package:meta/meta.dart';

class Region {
  final String name;
  final String imageUrl;
  final String id;
  Region({@required this.id, @required this.name, @required this.imageUrl});

  factory Region.fromJson(Map<String, dynamic> json) {
    return Region(
      name: json["name"],
      imageUrl: json["flag_url"],
      id: json["id"],
    );
  }
//

  Widget getRegionImage({double size}) {
    return FutureBuilder<Image>(
        future: Cache.getImage(imageUrl, fit: BoxFit.contain),
        builder: (context, AsyncSnapshot<Image> snapshot) {
          if (snapshot.connectionState == ConnectionState.done ||
              snapshot.hasData) {
            return Container(
                width: size ?? 35, height: size ?? 35, child: snapshot.data);
          } else {
            return Container();
          }
        });
  }
}

class RegionSingleton {
  final _mainRepository = MainRepositoryModule.mainRepository();
  static final RegionSingleton _singleton = RegionSingleton._internal();
  Map<String, Region> _regions;
  Map<String, Region> get regions => _regions;
  RegionSingleton._internal();
  factory RegionSingleton() {
    return _singleton;
  }
  Future<void> init() async {
    final tempRegions = await _mainRepository.getRegions();
    this._regions = Map<String, Region>.fromIterable(tempRegions,
        key: (e) => e.id, value: (e) => e);
  }
}
