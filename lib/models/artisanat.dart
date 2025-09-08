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
  final Seo seo;

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
    required this.seo,
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
      seo: Seo.fromJson(json['seo'] ?? {}),
    );
  }
}

class Seo {
  final String metaTitle;
  final String metaDescription;
  final String metaKeywords;
  final String metaTitleEn;
  final String metaDescriptionEn;
  final String metaKeywordsEn;
  final String metaTitleAr;
  final String metaDescriptionAr;
  final String metaKeywordsAr;
  final String metaTitleRu;
  final String metaDescriptionRu;
  final String metaKeywordsRu;
  final String metaTitleKo;
  final String metaDescriptionKo;
  final String metaKeywordsKo;
  final String metaTitleZh;
  final String metaDescriptionZh;
  final String metaKeywordsZh;
  final String metaTitleJa;
  final String metaDescriptionJa;
  final String metaKeywordsJa;

  Seo({
    required this.metaTitle,
    required this.metaDescription,
    required this.metaKeywords,
    required this.metaTitleEn,
    required this.metaDescriptionEn,
    required this.metaKeywordsEn,
    required this.metaTitleAr,
    required this.metaDescriptionAr,
    required this.metaKeywordsAr,
    required this.metaTitleRu,
    required this.metaDescriptionRu,
    required this.metaKeywordsRu,
    required this.metaTitleKo,
    required this.metaDescriptionKo,
    required this.metaKeywordsKo,
    required this.metaTitleZh,
    required this.metaDescriptionZh,
    required this.metaKeywordsZh,
    required this.metaTitleJa,
    required this.metaDescriptionJa,
    required this.metaKeywordsJa,
  });

  factory Seo.fromJson(Map<String, dynamic> json) {
    return Seo(
      metaTitle: json['meta_title'] ?? '',
      metaDescription: json['meta_description'] ?? '',
      metaKeywords: json['meta_keywords'] ?? '',
      metaTitleEn: json['meta_title_en'] ?? '',
      metaDescriptionEn: json['meta_description_en'] ?? '',
      metaKeywordsEn: json['meta_keywords_en'] ?? '',
      metaTitleAr: json['meta_title_ar'] ?? '',
      metaDescriptionAr: json['meta_description_ar'] ?? '',
      metaKeywordsAr: json['meta_keywords_ar'] ?? '',
      metaTitleRu: json['meta_title_ru'] ?? '',
      metaDescriptionRu: json['meta_description_ru'] ?? '',
      metaKeywordsRu: json['meta_keywords_ru'] ?? '',
      metaTitleKo: json['meta_title_ko'] ?? '',
      metaDescriptionKo: json['meta_description_ko'] ?? '',
      metaKeywordsKo: json['meta_keywords_ko'] ?? '',
      metaTitleZh: json['meta_title_zh'] ?? '',
      metaDescriptionZh: json['meta_description_zh'] ?? '',
      metaKeywordsZh: json['meta_keywords_zh'] ?? '',
      metaTitleJa: json['meta_title_ja'] ?? '',
      metaDescriptionJa: json['meta_description_ja'] ?? '',
      metaKeywordsJa: json['meta_keywords_ja'] ?? '',
    );
  }
}
