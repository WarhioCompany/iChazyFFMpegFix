import 'package:flutter/material.dart';
import 'package:ichazy/data/api/cache/cache.dart';

class Brand {
  final String id;
  final String name;
  final String description;
  final String url;
  Image profileImage;
  final String uuidLogo1;
  final String uuidLogo2;

  Brand({
    this.id,
    this.name,
    this.description,
    this.url,
    this.uuidLogo1,
    this.uuidLogo2,
  });

  static Brand fromBrandData(BrandData brandData) => Brand(
    id: brandData.id,
    name: brandData.info.title,
    description: brandData.info.description,
    url: brandData.info.web,
    uuidLogo1: brandData.uuidLogo1,
    uuidLogo2: brandData.uuidLogo2,
  );

  static Future<Image> getImage(String avatarId) async {
    return await Cache.getImage('${Cache.getUrl(avatarId)}.webp');
  }

  Future<Image> getProfileImage() async {
    String uid = uuidLogo1 ?? uuidLogo2;
    return await Cache.getImage('${Cache.getUrl(uid)}.webp');
  }

  Future<Image> getProfileSmallImage() async {
    return await Cache.getImage('${Cache.getUrl(uuidLogo2)}.webp');
  }
}

class BrandData {
  BrandData({
    this.id,
    this.uuidLogo1,
    this.uuidLogo2,
    this.info,
  });

  final String id;
  final String uuidLogo1;
  final String uuidLogo2;
  final Info info;

  BrandData copyWith({
    String id,
    String uuidLogo1,
    String uuidLogo2,
    Info info,
  }) =>
      BrandData(
        id: id ?? this.id,
        uuidLogo1: uuidLogo1 ?? this.uuidLogo1,
        uuidLogo2: uuidLogo2 ?? this.uuidLogo2,
        info: info ?? this.info,
      );

  factory BrandData.fromMap(Map<String, dynamic> json) => BrandData(
    id: json["id"],
    uuidLogo1: json["logo_1"],
    uuidLogo2: json["logo_2"],
    info: Info.fromMap(json["info"]),
  );
}

class Info {
  Info({
    this.title,
    this.description,
    this.web,
    this.company,
  });

  final String title;
  final String description;
  final String web;
  final String company;

  Info copyWith({
    String title,
    String description,
    String web,
    String company,
  }) =>
      Info(
        title: title ?? this.title,
        description: description ?? this.description,
        web: web ?? this.web,
        company: company ?? this.company,
      );

  factory Info.fromMap(Map<String, dynamic> json) => Info(
    title: json["title"],
    description: json["description"],
    web: json["web"],
    company: json["company"],
  );
}