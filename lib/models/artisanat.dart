import 'package:flutter/material.dart';

class Artisanat {
  final String id;
  final String name;
  final String nameEn;
  final String nameKo;
  final String nameAr;
  final String nameZh;
  final String nameRu;
  final String nameJa;
  final String description;
  final String descriptionEn;
  final String descriptionKo;
  final String descriptionAr;
  final String descriptionZh;
  final String descriptionRu;
  final String descriptionJa;
  final String slug;
  final String videoLink;
  final String cover;
  final String vignette;
  final List<String> images;

  Artisanat({
    required this.id,
    required this.name,
    required this.nameEn,
    required this.nameKo,
    required this.nameAr,
    required this.nameZh,
    required this.nameRu,
    required this.nameJa,
    required this.description,
    required this.descriptionEn,
    required this.descriptionKo,
    required this.descriptionAr,
    required this.descriptionZh,
    required this.descriptionRu,
    required this.descriptionJa,
    required this.slug,
    required this.videoLink,
    required this.cover,
    required this.vignette,
    required this.images,
  });

  factory Artisanat.fromJson(Map<String, dynamic> json) {
    return Artisanat(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      nameEn: json['name_en'] ?? '',
      nameKo: json['name_ko'] ?? '',
      nameAr: json['name_ar'] ?? '',
      nameZh: json['name_zh'] ?? '',
      nameRu: json['name_ru'] ?? '',
      nameJa: json['name_ja'] ?? '',
      description: json['description'] ?? '',
      descriptionEn: json['description_en'] ?? '',
      descriptionKo: json['description_ko'] ?? '',
      descriptionAr: json['description_ar'] ?? '',
      descriptionZh: json['description_zh'] ?? '',
      descriptionRu: json['description_ru'] ?? '',
      descriptionJa: json['description_ja'] ?? '',
      slug: json['slug'] ?? '',
      videoLink: json['video_link'] ?? '',
      cover: json['cover'] ?? '',
      vignette: json['vignette'] ?? '',
      images: List<String>.from(json['images'] ?? []),
    );
  }

  String getName(Locale locale) {
    switch (locale.languageCode) {
      case 'en':
        return nameEn;
      case 'ar':
        return nameAr;
      case 'ru':
        return nameRu;
      case 'zh':
        return nameZh;
      case 'ko':
        return nameKo;
      case 'ja':
        return nameJa;
      default:
        return name;
    }
  }

  String getDescription(Locale locale) {
    switch (locale.languageCode) {
      case 'en':
        return descriptionEn;
      case 'ar':
        return descriptionAr;
      case 'ru':
        return descriptionRu;
      case 'zh':
        return descriptionZh;
      case 'ko':
        return descriptionKo;
      case 'ja':
        return descriptionJa;
      default:
        return description;
    }
  }
}

