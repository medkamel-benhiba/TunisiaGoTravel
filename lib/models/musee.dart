class Musees {
  final String id;
  final String name;
  final String description;
  final String situation;
  final List<String> aVoir;
  final String droitsEntree;
  final List<String> horairesOuverture;
  final double lat;
  final double lng;
  final List<String> commodites;
  final List<String> images;
  final String vignette;
  final String cover;
  final String destinationId;
  final String slug;
  final String observations;

  // Champs en différentes langues
  final String nameEn;
  final String descriptionEn;
  final String situationEn;
  final List<String> aVoirEn;
  final List<String> horairesOuvertureEn;
  final String observationsEn;

  final String nameAr;
  final String descriptionAr;
  final String situationAr;
  final List<String> aVoirAr;
  final List<String> horairesOuvertureAr;
  final String observationsAr;

  final String nameRu;
  final String descriptionRu;
  final String situationRu;
  final List<String> aVoirRu;
  final List<String> horairesOuvertureRu;
  final String observationsRu;

  // Constructor
  Musees({
    required this.id,
    required this.name,
    required this.description,
    required this.situation,
    required this.aVoir,
    required this.droitsEntree,
    required this.horairesOuverture,
    required this.lat,
    required this.lng,
    required this.commodites,
    required this.images,
    required this.vignette,
    required this.cover,
    required this.destinationId,
    required this.slug,
    required this.observations,
    required this.nameEn,
    required this.descriptionEn,
    required this.situationEn,
    required this.aVoirEn,
    required this.horairesOuvertureEn,
    required this.observationsEn,
    required this.nameAr,
    required this.descriptionAr,
    required this.situationAr,
    required this.aVoirAr,
    required this.horairesOuvertureAr,
    required this.observationsAr,
    required this.nameRu,
    required this.descriptionRu,
    required this.situationRu,
    required this.aVoirRu,
    required this.horairesOuvertureRu,
    required this.observationsRu,
  });

  factory Musees.fromJson(Map<String, dynamic> json) {
    List<String> parseList(dynamic value) {
      if (value is List) return value.map((e) => e.toString()).toList();
      return [];
    }

    return Musees(
      id: json['id']?.toString() ?? '',
      name: json['Name']?.toString() ?? '',
      description: json['Description']?.toString() ?? '',
      situation: json['Situation']?.toString() ?? '',
      aVoir: parseList(json['A_voir']),
      droitsEntree: json['Droits_d_entre']?.toString() ?? '',
      horairesOuverture: parseList(json['Horaires_d_ouverture']),
      lat: double.tryParse(json['lat']?.toString() ?? '0') ?? 0,
      lng: double.tryParse(json['lng']?.toString() ?? '0') ?? 0,
      commodites: parseList(json['Commodites']),
      images: parseList(json['images']),
      vignette: json['vignette']?.toString() ?? '',
      cover: json['cover']?.toString() ?? '',
      destinationId: json['destination_id']?.toString() ?? '',
      slug: json['slug']?.toString() ?? '',
      observations: json['Observations']?.toString() ?? '',

      nameEn: json['Name_en']?.toString() ?? '',
      descriptionEn: json['Description_en']?.toString() ?? '',
      situationEn: json['Situation_en']?.toString() ?? '',
      aVoirEn: parseList(json['A_voir_en']),
      horairesOuvertureEn: parseList(json['Horaires_d_ouverture_en']),
      observationsEn: json['Observations_en']?.toString() ?? '',

      nameAr: json['Name_ar']?.toString() ?? '',
      descriptionAr: json['Description_ar']?.toString() ?? '',
      situationAr: json['Situation_ar']?.toString() ?? '',
      aVoirAr: parseList(json['A_voir_ar']),
      horairesOuvertureAr: parseList(json['Horaires_d_ouverture_ar']),
      observationsAr: json['Observations_ar']?.toString() ?? '',

      nameRu: json['Name_ru']?.toString() ?? '',
      descriptionRu: json['Description_ru']?.toString() ?? '',
      situationRu: json['Situation_ru']?.toString() ?? '',
      aVoirRu: parseList(json['A_voir_ru']),
      horairesOuvertureRu: parseList(json['Horaires_d_ouverture_ru']),
      observationsRu: json['Observations_ru']?.toString() ?? '',
    );
  }

  // Méthode utilitaire pour récupérer les champs selon la langue
  String getName(String lang) {
    switch (lang) {
      case 'en':
        return nameEn.isNotEmpty ? nameEn : name;
      case 'ar':
        return nameAr.isNotEmpty ? nameAr : name;
      case 'ru':
        return nameRu.isNotEmpty ? nameRu : name;
      default:
        return name;
    }
  }

  String getDescription(String lang) {
    switch (lang) {
      case 'en':
        return descriptionEn.isNotEmpty ? descriptionEn : description;
      case 'ar':
        return descriptionAr.isNotEmpty ? descriptionAr : description;
      case 'ru':
        return descriptionRu.isNotEmpty ? descriptionRu : description;
      default:
        return description;
    }
  }

  List<String> getAVoir(String lang) {
    switch (lang) {
      case 'en':
        return aVoirEn.isNotEmpty ? aVoirEn : aVoir;
      case 'ar':
        return aVoirAr.isNotEmpty ? aVoirAr : aVoir;
      case 'ru':
        return aVoirRu.isNotEmpty ? aVoirRu : aVoir;
      default:
        return aVoir;
    }
  }

  String getObservations(String lang) {
    switch (lang) {
      case 'en':
        return observationsEn.isNotEmpty ? observationsEn : observations;
      case 'ar':
        return observationsAr.isNotEmpty ? observationsAr : observations;
      case 'ru':
        return observationsRu.isNotEmpty ? observationsRu : observations;
      default:
        return observations;
    }
  }
}
