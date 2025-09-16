
import 'package:flutter/material.dart';

class Restaurant {
  final String id;
  final String name;
  final String? slug;
  final String? crtDescription;
  final String? address;
  final String? destinationId;
  final String? destinationName;
  final String? cityId;
  final String? ville;
  final String? villeAr;
  final String? villeEn;
  final String? villeRu;
  final String? villeZh;
  final String? villeKo;
  final String? villeJa;
  final String? cover;
  final String? vignette;
  final List<String> images;
  final String lat;
  final String lng;
  final dynamic rate;
  final dynamic startingPrice;
  final Map<String, String?> openingHours;
  final String? phone;
  final String? email;
  final String? website;
  final String? videoLink;
  final bool isSpecial;
  final bool reservable;
  final String? status;

  // English fields
  final String? nameEn;
  final String? crtDescriptionEn;
  final String? addressEn;

  // Arabic fields
  final String? nameAr;
  final String? crtDescriptionAr;
  final String? addressAr;

  // Russian fields
  final String? nameRu;
  final String? crtDescriptionRu;
  final String? addressRu;

  // Japanese fields
  final String? nameJa;
  final String? crtDescriptionJa;
  final String? addressJa;

  //Korean Fields
  final String? nameKo;
  final String? crtDescriptionKo;
  final String? addressKo;

  //Chinese Fields
  Restaurant({
    required this.id,
    required this.name,
    this.slug,
    this.crtDescription,
    this.address,
    this.destinationId,
    this.destinationName,
    this.cityId,
    this.ville,
    this.cover,
    this.vignette,
    required this.images,
    required this.lat,
    required this.lng,
    this.rate,
    this.startingPrice,
    required this.openingHours,
    this.phone,
    this.email,
    this.website,
    this.videoLink,
    required this.isSpecial,
    required this.reservable,
    this.status,
    this.nameEn,
    this.crtDescriptionEn,
    this.addressEn,
    this.nameAr,
    this.crtDescriptionAr,
    this.addressAr,
    this.nameRu,
    this.crtDescriptionRu,
    this.addressRu,
    this.nameJa,
    this.crtDescriptionJa,
    this.addressJa,
    this.nameKo,
    this.crtDescriptionKo,
    this.addressKo,
    this.nameZh,
    this.crtDescriptionZh,
    this.addressZh,
    this.villeAr,
    this.villeEn,
    this.villeRu,
    this.villeZh,
    this.villeKo,
    this.villeJa,
  });
  final String? nameZh;
  final String? crtDescriptionZh;




  final String? addressZh;

  factory Restaurant.fromJson(Map<String, dynamic> json) {
    // Helper to safely parse double
    double? _parseDouble(dynamic value) {
      if (value is String) {
        return double.tryParse(value);
      } else if (value is num) {
        return value.toDouble();
      }
      return null;
    }

    Map<String, String?> oh = {};
    if (json['opening_hours'] is Map) {
      (json['opening_hours'] as Map).forEach((key, value) {
        oh[key.toString()] = value?.toString();
      });
    }

    List<String> imageList = [];
    if (json['images'] is List) {
      imageList = List<String>.from(json['images'].map((img) => img.toString()));
    }

    String? destName;
    if (json['destination'] is Map && json['destination']['name'] != null) {
      destName = json['destination']['name'] as String?;
    }

    return Restaurant(
      id: json['id'] as String? ?? '', // ID should ideally always be present
      name: json['name'] as String? ?? 'Unnamed Restaurant',
      slug: json['slug'] as String?,
      crtDescription: json['crt_description'] as String?,
      address: json['address'] as String?,
      destinationId: json['destination_id'] as String?,
      destinationName: destName,
      cityId: json['city_id'] as String?,
      ville: json['ville'] as String?,
      cover: json['cover'] as String?,
      vignette: json['vignette'] as String?,
      images: imageList,
      lat: json['lat'] ?? '',
      lng: json['lng'] ?? '',
      rate: json['rate'], // Keep as dynamic or parse to double/int as needed
      startingPrice: json['starting_price'], // Keep as dynamic or parse
      openingHours: oh,
      phone: json['phone'] as String?,
      email: json['email'] as String?,
      website: json['website'] as String?,
      videoLink: json['video_link'] as String?,
      isSpecial: (json['is_special'] == 'yes' || json['is_special'] == true),
      reservable: (json['reservable'] == 'yes' || json['reservable'] == true), // Assuming 'yes' or boolean
      status: json['status'] as String?,
      nameEn: json['name_en'] as String?,
      crtDescriptionEn: json['crt_description_en'] as String?,
      addressEn: json['address_en'] as String?,
      nameAr: json['name_ar'] as String?,
      crtDescriptionAr: json['crt_description_ar'] as String?,
      addressAr: json['address_ar'] as String?,
      nameRu: json['name_ru'] as String?,
      crtDescriptionRu: json['crt_description_ru'] as String?,
      addressRu: json['address_ru'] as String?,
      nameJa: json['name_ja'] as String?,
      crtDescriptionJa: json['crt_description_ja'] as String?,
      addressJa: json['address_ja'] as String?,
      nameKo: json['name_ko'] as String?,
      crtDescriptionKo: json['crt_description_ko'] as String?,
      addressKo: json['address_ko'] as String?,
      nameZh: json['name_zh'] as String?,
      crtDescriptionZh: json['crt_description_zh'] as String?,
      addressZh: json['address_zh'] as String?,
    );
  }
  String getName(Locale locale) {
    switch (locale.languageCode) {
      case 'ar':
        return (nameAr != null && nameAr!.isNotEmpty) ? nameAr! : name;
      case 'en':
        return (nameEn != null && nameEn!.isNotEmpty) ? nameEn! : name;
      case 'ru':
        return (nameRu != null && nameRu!.isNotEmpty) ? nameRu! : name;
      case 'ko':
        return (nameKo != null && nameKo!.isNotEmpty) ? nameKo! : name;
      case 'zh':
        return (nameZh != null && nameZh!.isNotEmpty) ? nameZh! : name;
      case 'ja':
        return (nameJa != null && nameJa!.isNotEmpty) ? nameJa! : name;
      default:
        return name;
    }
  }
  String getAddress(Locale locale) {
    switch (locale.languageCode) {
      case 'ar':
        return (addressAr != null && addressAr!.isNotEmpty) ? addressAr! : (address ?? '');
      case 'en':
        return (addressEn != null && addressEn!.isNotEmpty) ? addressEn! : (address ?? '');
      case 'ru':
        return (addressRu != null && addressRu!.isNotEmpty) ? addressRu! : (address ?? '');
      case 'ko':
        return (addressKo != null && addressKo!.isNotEmpty) ? addressKo! : (address ?? '');
      case 'zh':
        return (addressZh != null && addressZh!.isNotEmpty) ? addressZh! : (address ?? '');
      case 'ja':
        return (addressJa != null && addressJa!.isNotEmpty) ? addressJa! : (address ?? '');
      default:
        return address ?? '';
    }
  }

  String getVille(Locale locale) {
    switch (locale.languageCode) {
      case 'ar':
        return (villeAr != null && villeAr!.isNotEmpty) ? villeAr! : (ville ?? '');
      case 'en':
        return (villeEn != null && villeEn!.isNotEmpty) ? villeEn! : (ville ?? '');
      case 'ru':
        return (villeRu != null && villeRu!.isNotEmpty) ? villeRu! : (ville ?? '');
      case 'zh':
        return (villeZh != null && villeZh!.isNotEmpty) ? villeZh! : (ville ?? '');
      case 'ko':
        return (villeKo != null && villeKo!.isNotEmpty) ? villeKo! : (ville ?? '');
      case 'ja':
        return (villeJa != null && villeJa!.isNotEmpty) ? villeJa! : (ville ?? '');
      default:
        return ville ?? '';
    }
  }

  String getDescription(Locale locale) {
    switch (locale.languageCode) {
      case 'ar':
        return (crtDescriptionAr != null && crtDescriptionAr!.isNotEmpty) ? crtDescriptionAr! : (crtDescription ?? '');
      case 'en':
        return (crtDescriptionEn != null && crtDescriptionEn!.isNotEmpty) ? crtDescriptionEn! : (crtDescription ?? '');
      case 'ru':
        return (crtDescriptionRu != null && crtDescriptionRu!.isNotEmpty) ? crtDescriptionRu! : (crtDescription ?? '');
      case 'zh':
        return (crtDescriptionZh != null && crtDescriptionZh!.isNotEmpty) ? crtDescriptionZh! : (crtDescription ?? '');
      case 'ko':
        return (crtDescriptionKo != null && crtDescriptionKo!.isNotEmpty) ? crtDescriptionKo! : (crtDescription ?? '');
      case 'ja':
        return (crtDescriptionJa != null && crtDescriptionJa!.isNotEmpty) ? crtDescriptionJa! : (crtDescription ?? '');

      default:
        return crtDescription ?? '';
    }
  }


  // For debugging purposes
  @override
  String toString() {
    return 'Restaurant(id: $id, name: $name, destinationId: $destinationId)';
  }
}
