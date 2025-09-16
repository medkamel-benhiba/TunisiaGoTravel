import 'dart:convert';
import 'package:flutter/material.dart';

import 'destination.dart';

class Monument {
  final String id;
  final String name;
  final String? nameAr;
  final String? nameEn;
  final String? nameRu;
  final String? nameJa;
  final String? nameKo;
  final String? nameZh;
  final String description;
  final String? descriptionAr;
  final String? descriptionEn;
  final String? descriptionRu;
  final String? descriptionJa;
  final String? descriptionKo;
  final String? descriptionZh;
  final String categories;
  final String? categoriesAr;
  final String? categoriesEn;
  final String? categoriesRu;
  final String? categoriesJa;
  final String? categoriesKo;
  final String? categoriesZh;
  final double? lat;
  final double? lng;
  final List<String> images;
  final String cover;
  final String vignette;
  final String slug;
  final Destination destination;
  final Destination? destinationAr;
  final Destination? destinationEn;
  final Destination? destinationRu;
  final Destination? destinationJa;
  final Destination? destinationKo;
  final Destination? destinationZh;

  Monument({
    required this.id,
    required this.name,
    this.nameAr,
    this.nameEn,
    this.nameRu,
    this.nameJa,
    this.nameKo,
    this.nameZh,

    required this.description,
    this.descriptionAr,
    this.descriptionEn,
    this.descriptionRu,
    this.descriptionJa,
    this.descriptionKo,
    this.descriptionZh,

    required this.categories,
    required this.lat,
    required this.lng,
    required this.images,
    required this.cover,
    required this.vignette,
    required this.slug,
    required this.destination,
    this.categoriesAr,
    this.categoriesEn,
    this.categoriesRu,
    this.categoriesJa,
    this.categoriesKo,
    this.categoriesZh,
    this.destinationAr,
    this.destinationEn,
    this.destinationRu,
    this.destinationJa,
    this.destinationKo,
    this.destinationZh,
  });

  factory Monument.fromJson(Map<String, dynamic> json) {
    return Monument(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      nameAr: json['name_ar'] ?? '',
      nameEn: json['name_en'] ?? '',
      nameRu: json['name_ru'] ?? '',
      nameJa: json['name_ja'] ?? '',
      nameKo: json['name_ko'] ?? '',
      nameZh: json['name_zh'] ?? '',
      description: json['description'] ?? '',
      descriptionAr: json['description_ar'] ?? '',
      descriptionEn: json['description_en'] ?? '',
      descriptionRu: json['description_ru'] ?? '',
      descriptionJa: json['description_ja'] ?? '',
      descriptionKo: json['description_ko'] ?? '',
      descriptionZh: json['description_zh'] ?? '',
      categories: json['categories'] ?? '',
      categoriesAr: json['categories_ar'] ?? '',
      categoriesEn: json['categories_en'] ?? '',
      categoriesRu: json['categories_ru'] ?? '',
      categoriesJa: json['categories_ja'] ?? '',
      categoriesKo: json['categories_ko'] ?? '',
      categoriesZh: json['categories_zh'] ?? '',
      lat: double.tryParse(json['lat']?.toString() ?? ''),
      lng: double.tryParse(json['lng']?.toString() ?? ''),
      images: List<String>.from(json['images'] ?? []),
      cover: json['cover'] ?? '',
      vignette: json['vignette'] ?? '',
      slug: json['slug'] ?? '',
      destination: Destination.fromJson(json['destination'] ?? {}),
      destinationAr: Destination.fromJson(json['destination_ar'] ?? {}),
      destinationEn: Destination.fromJson(json['destination_en'] ?? {}),
      destinationRu: Destination.fromJson(json['destination_ru'] ?? {}),
      destinationJa: Destination.fromJson(json['destination_ja'] ?? {}),
      destinationKo: Destination.fromJson(json['destination_ko'] ?? {}),
      destinationZh: Destination.fromJson(json['destination_zh'] ?? {}),

    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'categories': categories,
      'lat': lat,
      'lng': lng,
      'images': images,
      'cover': cover,
      'vignette': vignette,
      'slug': slug,
      'destination': destination,
    };
  }
  String getName(Locale Locale){
    switch (Locale.languageCode){
      case 'ar':
        return nameAr!;
      case 'en':
        return nameEn!;
      case 'ru':
        return nameRu!;
      case 'ja':
        return nameJa!;
      case 'ko':
        return nameKo!;
      case 'zh':
        return nameZh!;
      default:
        return name;
    }
  }

  String getDescription(Locale Locale){
    switch (Locale.languageCode){
      case 'ar':
        return descriptionAr!;
      case 'en':
        return descriptionEn!;
      case 'ru':
        return descriptionRu!;
      case 'ja':
        return descriptionJa!;
      case 'ko':
        return descriptionKo!;
      case 'zh':
        return descriptionZh!;
      default:
        return description;
    }
  }
  String getCategories(Locale Locale){
    switch (Locale.languageCode){
      case 'ar':
        return categoriesAr!;
      case 'en':
        return categoriesEn!;
      case 'ru':
        return categoriesRu!;
      case 'ja':
        return categoriesJa!;
      case 'ko':
        return categoriesKo!;
      case 'zh':
        return categoriesZh!;
      default:
        return categories;
    }
  }
  String getDestinationName(Locale Locale){
    switch (Locale.languageCode){
      case 'ar':
        return destinationAr!.name;
      case 'en':
        return destinationEn!.name;
      case 'ru':
        return destinationRu!.name;
      case 'ja':
        return destinationJa!.name;
      case 'ko':
        return destinationKo!.name;
      case 'zh':
        return destinationZh!.name;
      default:
        return destination.name;
    }
  }
}

List<Monument> parseMonuments(String responseBody) {
  try {
    final Map<String, dynamic> parsed = json.decode(responseBody);
    final List<dynamic> data = parsed['monument']?['data'] ?? [];
    return data.map((json) => Monument.fromJson(json)).toList();
  } catch (e) {
    print('Error parsing monuments: $e');
    return [];
  }
}
