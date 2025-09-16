import 'package:flutter/material.dart';

class Activity {
  final String id;
  final String title;
  final String? titleEn;
  final String? titleAr;
  final String? titleRu;
  final String? titleZh;
  final String? titleKo;
  final String? titleJa;
  final String? cover;
  final String? description;
  final String? descriptionEn;
  final String? descriptionAr;
  final String? descriptionRu;
  final String? descriptionZh;
  final String? descriptionKo;
  final String? descriptionJa;
  final String? address;
  final String? addressEn;
  final String? addressAr;
  final String? addressRu;
  final String? addressZh;
  final String? addressKo;
  final String? addressJa;
  final double? rate;
  final String? price;
  final String? subtype;
  final String? subtypeEn;
  final String? subtypeAr;
  final String? subtypeRu;
  final String? subtypeZh;
  final String? subtypeKo;
  final String? subtypeJa;
  final List<String>? images;
  final Map<String, dynamic>? links;
  final Map<String, dynamic>? settings;
  final bool? reservable;
  final String? lat;
  final String? lng;
  final String? cityId;
  final String? agencyId;
  final String? categoryId;
  final String? slug;
  final String? destinationId;


  Activity({
    required this.id,
    required this.title,
    this.titleEn,
    this.titleAr,
    this.titleRu,
    this.titleZh,
    this.titleKo,
    this.titleJa,
    this.cover,
    this.description,
    this.descriptionEn,
    this.descriptionAr,
    this.descriptionRu,
    this.descriptionZh,
    this.descriptionKo,
    this.descriptionJa,
    this.address,
    this.addressEn,
    this.addressAr,
    this.addressRu,
    this.addressZh,
    this.addressKo,
    this.addressJa,
    this.rate,
    this.price,
    this.subtype,
    this.subtypeEn,
    this.subtypeAr,
    this.subtypeRu,
    this.subtypeZh,
    this.subtypeKo,
    this.subtypeJa,
    this.images,
    this.links,
    this.settings,
    this.reservable,
    this.lat,
    this.lng,
    this.cityId,
    this.agencyId,
    this.categoryId,
    this.slug,
    this.destinationId
  });

  factory Activity.fromJson(Map<String, dynamic> json) {
    return Activity(
      id: json['id'],
      title: json['title'] ?? '',
      titleEn: json['title_en'],
      titleAr: json['title_ar'],
      titleRu: json['title_ru'],
      titleZh: json['title_zh'],
      titleKo: json['title_ko'],
      titleJa: json['title_ja'],
      cover: json['cover'],
      description: json['description'],
      descriptionEn: json['description_en'],
      descriptionAr: json['description_ar'],
      descriptionRu: json['description_ru'],
      descriptionZh: json['description_zh'],
      descriptionKo: json['description_ko'],
      descriptionJa: json['description_ja'],
      address: json['address'],
      addressEn: json['address_en'],
      addressAr: json['address_ar'],
      addressRu: json['address_ru'],
      addressZh: json['address_zh'],
      addressKo: json['address_ko'],
      addressJa: json['address_ja'],
      rate: json['rate'] != null ? (json['rate'] as num).toDouble() : null,
      price: json['price'],
      subtype: json['subtype'],
      subtypeEn: json['subtype_en'],
      subtypeAr: json['subtype_ar'],
      subtypeRu: json['subtype_ru'],
      subtypeZh: json['subtype_zh'],
      subtypeKo: json['subtype_ko'],
      subtypeJa: json['subtype_ja'],
      images: (json['images'] as List?)?.map((e) => e.toString()).toList(),
      links: json['links'] != null ? Map<String, dynamic>.from(json['links']) : null,
      settings: json['settings'] != null ? Map<String, dynamic>.from(json['settings']) : null,
      reservable: json['reservable'],
      lat: json['lat'],
      lng: json['lng'],
      cityId: json['city_id'],
      agencyId: json['agency_id'],
      categoryId: json['category_id'],
      slug: json['slug'],
      destinationId: json['destination_id'],
    );
  }

  String getName(Locale locale) {
    switch (locale.languageCode) {
      case 'en':
        return titleEn ?? title;
      case 'ar':
        return titleAr ?? title;
      case 'ru':
        return titleRu ?? title;
      case 'zh':
        return titleZh ?? title;
      case 'ko':
        return titleKo ?? title;
      case 'ja':
        return titleJa ?? title;
      default:
        return title;
    }
  }
  String getDescription(Locale locale) {
    switch (locale.languageCode) {
      case 'en':
        return descriptionEn ?? description ?? '';
      case 'ar':
        return descriptionAr ?? description ?? '';
      case 'ru':
        return descriptionRu ?? description ?? '';
      case 'zh':
        return descriptionZh ?? description ?? '';
      case 'ko':
        return descriptionKo ?? description ?? '';
      case 'ja':
        return descriptionJa ?? description ?? '';
      default:
        return description ?? '';
    }
  }
  String getAddress(Locale locale) {
    switch (locale.languageCode) {
      case 'en':
        return addressEn ?? address ?? '';
      case 'ar':
        return addressAr ?? address ?? '';
      case 'ru':
        return addressRu ?? address ?? '';
      case 'zh':
        return addressZh ?? address ?? '';
      case 'ko':
        return addressKo ?? address ?? '';
      case 'ja':
        return addressJa ?? address ?? '';
      default:
        return address ?? '';
    }
  }
  String getSubtype(Locale locale) {
    switch (locale.languageCode) {
      case 'en':
        return subtypeEn ?? subtype ?? '';
      case 'ar':
        return subtypeAr ?? subtype ?? '';
      case 'ru':
        return subtypeRu ?? subtype ?? '';
      case 'zh':
        return subtypeZh ?? subtype ?? '';
      case 'ko':
        return subtypeKo ?? subtype ?? '';
      case 'ja':
        return subtypeJa ?? subtype ?? '';
      default:
        return subtype ?? '';
    }
  }

}
