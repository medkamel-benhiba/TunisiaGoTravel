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

  final String? population;
  final String? updatedAt;
  final String? createdAt;

  final String? metaTagDescription;
  final String? metaTagKeywords;
  final String? metaTagTitle;

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

  // Multilingue - noms
  final String? nameAr;
  final String? nameEn;
  final String? nameRu;
  final String? nameZh;
  final String? nameKo;
  final String? nameJa;

  Destination({
    required this.id,
    required this.name,
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
    this.metaTagDescription,
    this.metaTagKeywords,
    this.metaTagTitle,
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
    this.vignette,
    required this.gallery,
    this.isSpecial,
    required this.destinationServices,
    this.nameAr,
    this.nameEn,
    this.nameRu,
    this.nameZh,
    this.nameKo,
    this.nameJa,
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
      descriptionAr: json["description_ar"],
      descriptionRu: json["description_ru"],
      descriptionZh: json["description_zh"],
      descriptionKo: json["description_ko"],
      descriptionJa: json["description_ja"],
      population: json["population"],
      updatedAt: json["updated_at"],
      createdAt: json["created_at"],
      metaTagDescription: json["meta_tag_description"],
      metaTagKeywords: json["meta_tag_keywords"],
      metaTagTitle: json["meta_tag_title"],
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
}

class DestinationSelection {
  final String id;
  final String name;
  bool isStart;
  int days;

  DestinationSelection({
    required this.id,
    required this.name,
    this.isStart = false,
    this.days = 0,
  });

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "name": name,
      "isStart": isStart,
      "days": days,
    };
  }
}
