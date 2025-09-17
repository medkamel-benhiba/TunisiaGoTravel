import 'dart:ui';

class Destination {
  final String id;
  final String name;
  final List<String> idCityBbx;
  final double lat;
  final double lng;
  final String country;
  final String iso2;
  final String state;
  final String status;

  final String? description;
  final String? descriptionEn;
  final String? descriptionMobile;
  final String? descriptionAr;
  final String? descriptionRu;
  final String? descriptionZh;
  final String? descriptionKo;
  final String? descriptionJa;

  // Multilingual names
  final String? nameAr;
  final String? nameEn;
  final String? nameRu;
  final String? nameZh;
  final String? nameKo;
  final String? nameJa;

  final String? population;
  final String? updatedAt;
  final String? createdAt;

  final String? homeDescription;
  final String? homeDescriptionEn;
  final String? homeDescriptionAr;
  final String? homeDescriptionRu;
  final String? homeDescriptionZh;
  final String? homeDescriptionKo;
  final String? homeDescriptionJa;

  final String? shortDescription;
  final String? shortDescriptionEn;
  final String? shortDescriptionAr;
  final String? shortDescriptionRu;
  final String? shortDescriptionZh;
  final String? shortDescriptionKo;
  final String? shortDescriptionJa;

  final String? slug;
  final String? subtitle;
  final String? subtitleEn;
  final String? subtitleAr;
  final String? subtitleJa;

  final String? title;
  final String? titleEn;
  final String? titleAr;

  final String? videoLink;
  final String? mobileVideo;

  final String? cover;
  final String? vignette;
  final List<String> gallery;

  final String? isSpecial;
  final List<String> destinationServices;

  Destination({
    required this.id,
    required this.name,
    this.nameAr,
    this.nameEn,
    this.nameRu,
    this.nameZh,
    this.nameKo,
    this.nameJa,
    required this.idCityBbx,
    required this.lat,
    required this.lng,
    required this.country,
    required this.iso2,
    required this.state,
    required this.status,
    this.description,
    this.descriptionEn,
    this.descriptionMobile,
    this.descriptionAr,
    this.descriptionRu,
    this.descriptionZh,
    this.descriptionKo,
    this.descriptionJa,
    this.population,
    this.updatedAt,
    this.createdAt,
    this.homeDescription,
    this.homeDescriptionEn,
    this.homeDescriptionAr,
    this.homeDescriptionRu,
    this.homeDescriptionZh,
    this.homeDescriptionKo,
    this.homeDescriptionJa,
    this.shortDescription,
    this.shortDescriptionEn,
    this.shortDescriptionAr,
    this.shortDescriptionRu,
    this.shortDescriptionZh,
    this.shortDescriptionKo,
    this.shortDescriptionJa,
    this.slug,
    this.subtitle,
    this.subtitleEn,
    this.subtitleAr,
    this.subtitleJa,
    this.title,
    this.titleEn,
    this.titleAr,
    this.videoLink,
    this.mobileVideo,
    this.cover,
    required this.gallery,
    this.vignette,
    this.isSpecial,
    required this.destinationServices,
  });

  factory Destination.fromJson(Map<String, dynamic> json) {
    return Destination(
      id: json["id"] ?? "",
      name: json["name"] ?? "",
      idCityBbx: List<String>.from(json["id_city_bbx"] ?? []),
      lat: (json["lat"] as num?)?.toDouble() ?? 0.0,
      lng: (json["lng"] as num?)?.toDouble() ?? 0.0,
      country: json["country"] ?? "",
      iso2: json["iso2"] ?? "",
      state: json["state"] ?? "",
      status: json["status"] ?? "",
      description: json["description"],
      descriptionEn: json["description_en"],
      descriptionMobile: json["description_mobile"],
      descriptionAr: json["description_mobile_ar"],
      descriptionRu: json["description_mobile_ru"],
      descriptionZh: json["description_mobile_zh"],
      descriptionKo: json["description_mobile_ko"],
      descriptionJa: json["description_mobile_ja"],
      population: json["population"],
      updatedAt: json["updated_at"],
      createdAt: json["created_at"],
      homeDescription: json["home_description"],
      homeDescriptionEn: json["home_description_en"],
      homeDescriptionAr: json["home_description_ar"],
      homeDescriptionRu: json["home_description_ru"],
      homeDescriptionZh: json["home_description_zh"],
      homeDescriptionKo: json["home_description_ko"],
      homeDescriptionJa: json["home_description_ja"],
      shortDescription: json["short_description"],
      shortDescriptionEn: json["short_description_en"],
      shortDescriptionAr: json["short_description_ar"],
      shortDescriptionRu: json["short_description_ru"],
      shortDescriptionZh: json["short_description_zh"],
      shortDescriptionKo: json["short_description_ko"],
      shortDescriptionJa: json["short_description_ja"],
      slug: json["slug"],
      subtitle: json["subtitle"],
      subtitleEn: json["subtitle_en"],
      subtitleAr: json["subtitle_ar"],
      subtitleJa: json["subtitle_ja"],
      title: json["title"],
      titleEn: json["title_en"],
      titleAr: json["title_ar"],
      videoLink: json["video_link"],
      mobileVideo: json["mobile_video"],
      cover: json["cover"],
      vignette: json["vignette"],
      gallery: List<String>.from(json["gallery"] ?? []),
      isSpecial: json["is_special"],
      destinationServices: List<String>.from(json["destinationservices"] ?? []),
      nameAr: json["name_ar"],
      nameEn: json["name_en"],
      nameRu: json["name_ru"],
      nameZh: json["name_zh"],
      nameKo: json["name_ko"],
      nameJa: json["name_ja"],
    );
  }

  // Multilingual helpers
  String getName(Locale locale) {
    switch (locale.languageCode) {
      case 'en':
        return nameEn ?? name;
      case 'ar':
        return nameAr ?? name;
      case 'ru':
        return nameRu ?? name;
      case 'zh':
        return nameZh ?? name;
      case 'ko':
        return nameKo ?? name;
      case 'ja':
        return nameJa ?? name;
      default:
        return name;
    }
  }

  String? getDescription(Locale locale) {
    switch (locale.languageCode) {
      case 'en':
        return descriptionEn ?? description;
      case 'ar':
        return descriptionAr ?? description;
      case 'ru':
        return descriptionRu ?? description;
      case 'zh':
        return descriptionZh ?? description;
      case 'ko':
        return descriptionKo ?? description;
      case 'ja':
        return descriptionJa ?? description;
      default:
        return description;
    }
  }

  String? getTitle(Locale locale) {
    switch (locale.languageCode) {
      case 'en':
        return titleEn ?? title;
      case 'ar':
        return titleAr ?? title;
      default:
        return title;
    }
  }

  String? getSubtitle(Locale locale) {
    switch (locale.languageCode) {
      case 'en':
        return subtitleEn ?? subtitle;
      case 'ar':
        return subtitleAr ?? subtitle;
      case 'ja':
        return subtitleJa ?? subtitle;
      default:
        return subtitle;
    }
  }
}

// DestinationSelection remains simple
class DestinationSelection {
  final String id;
  final String name;
  final String? nameAr;
  final String? nameEn;
  final String? nameRu;
  final String? nameZh;
  final String? nameKo;
  final String? nameJa;
  bool isStart;
  int days;

  DestinationSelection({
    required this.id,
    required this.name,
    this.nameAr,
    this.nameEn,
    this.nameRu,
    this.nameZh,
    this.nameKo,
    this.nameJa,
    this.isStart = false,
    this.days = 0,
  });

  factory DestinationSelection.fromDestination(Destination destination) {
    return DestinationSelection(
      id: destination.id,
      name: destination.name,
      nameAr: destination.nameAr,
      nameEn: destination.nameEn,
      nameRu: destination.nameRu,
      nameZh: destination.nameZh,
      nameKo: destination.nameKo,
      nameJa: destination.nameJa,
      isStart: false,
      days: 0,
    );
  }

  String getName(Locale locale) {
    switch (locale.languageCode) {
      case 'en':
        return nameEn ?? name;
      case 'ar':
        return nameAr ?? name;
      case 'ru':
        return nameRu ?? name;
      case 'zh':
        return nameZh ?? name;
      case 'ko':
        return nameKo ?? name;
      case 'ja':
        return nameJa ?? name;
      default:
        return name;
    }
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "nameAr": nameAr,
    "nameEn": nameEn,
    "nameRu": nameRu,
    "nameZh": nameZh,
    "nameKo": nameKo,
    "nameJa": nameJa,
    "isStart": isStart,
    "days": days,
  };


}
