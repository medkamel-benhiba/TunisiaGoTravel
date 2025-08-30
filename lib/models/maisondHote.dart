import 'destination.dart';

class MaisonDHote {
  final String type;
  final String arabicCrtDescription;
  final String name;
  final String address;
  final String ville;
  final String arabicVille;
  final String phone;
  final String fax;
  final String email;
  final String website;
  final String lat;
  final String lng;
  final String cover;
  final String description;
  final bool isSpecial; // boolean
  final Links links;
  final List<dynamic> options;
  final bool reservable;
  final Settings settings;
  final String slug;
  final String status;
  final bool isShowPrice; // boolean
  final String vignette;
  final String videoLink;
  final List<String> images;
  final double startingPrice;
  final String destinationId;
  final String agencyId;
  final String arabicCategoryCodeDescription;
  final String categoryCodeDescription;
  final String categoryCode;
  final DateTime updatedAt;
  final String nameEn;
  final String villeEn;
  final String addressEn;
  final String nameAr;
  final String villeAr;
  final String addressAr;
  final String descriptionAr;
  final String descriptionEn;
  final String avisGoogle;
  final String noteGoogle;
  final String id;
  final Destination destination;

  MaisonDHote({
    required this.type,
    required this.arabicCrtDescription,
    required this.name,
    required this.address,
    required this.ville,
    required this.arabicVille,
    required this.phone,
    required this.fax,
    required this.email,
    required this.website,
    required this.lat,
    required this.lng,
    required this.cover,
    required this.description,
    required this.isSpecial,
    required this.links,
    required this.options,
    required this.reservable,
    required this.settings,
    required this.slug,
    required this.status,
    required this.isShowPrice,
    required this.vignette,
    required this.videoLink,
    required this.images,
    required this.startingPrice,
    required this.destinationId,
    required this.agencyId,
    required this.arabicCategoryCodeDescription,
    required this.categoryCodeDescription,
    required this.categoryCode,
    required this.updatedAt,
    required this.nameEn,
    required this.villeEn,
    required this.addressEn,
    required this.nameAr,
    required this.villeAr,
    required this.addressAr,
    required this.descriptionAr,
    required this.descriptionEn,
    required this.avisGoogle,
    required this.noteGoogle,
    required this.id,
    required this.destination,
  });

  factory MaisonDHote.fromJson(Map<String, dynamic> json) => MaisonDHote(
    type: json['type'] ?? '',
    arabicCrtDescription: json['arabic_crt_description'] ?? '',
    name: json['name'] ?? '',
    address: json['address'] ?? '',
    ville: json['ville'] ?? '',
    arabicVille: json['arabic_ville'] ?? '',
    phone: json['phone'] ?? '',
    fax: json['fax'] ?? '',
    email: json['email'] ?? '',
    website: json['website'] ?? '',
    lat: json['lat'] ?? '',
    lng: json['lng'] ?? '',
    cover: json['cover'] ?? '',
    description: json['description'] ?? '',
    // Fixed boolean parsing - handle both bool and string values
    isSpecial: _parseBool(json['is_special']),
    links: Links.fromJson(json['links'] ?? {}),
    options: json['options'] ?? [],
    // Fixed boolean parsing
    reservable: _parseBool(json['reservable']),
    settings: Settings.fromJson(json['settings'] ?? {}),
    slug: json['slug'] ?? '',
    status: json['status'] ?? '',
    // Fixed boolean parsing
    isShowPrice: _parseBool(json['is_show_price']),
    vignette: json['vignette'] ?? '',
    videoLink: json['video_link'] ?? '',
    images: (json['images'] as List<dynamic>?)
        ?.map((e) => e.toString())
        .toList() ??
        [],
    startingPrice: (json['starting_price'] ?? 0).toDouble(),
    destinationId: json['destination_id'] ?? '',
    agencyId: json['agency_id'] ?? '',
    arabicCategoryCodeDescription:
    json['arabic_category_code_description'] ?? '',
    categoryCodeDescription: json['category_code_description'] ?? '',
    categoryCode: json['category_code'] ?? '',
    updatedAt: DateTime.tryParse(json['updated_at'] ?? '') ?? DateTime.now(),
    nameEn: json['name_en'] ?? '',
    villeEn: json['ville_en'] ?? '',
    addressEn: json['address_en'] ?? '',
    nameAr: json['name_ar'] ?? '',
    villeAr: json['ville_ar'] ?? '',
    addressAr: json['address_ar'] ?? '',
    descriptionAr: json['description_ar'] ?? '',
    descriptionEn: json['description_en'] ?? '',
    avisGoogle: json['avis_google'] ?? '',
    noteGoogle: json['note_google'] ?? '0.0',
    id: json['id'] ?? '',
    destination: Destination.fromJson(json['destination'] ?? {}),
  );

// Helper method to parse boolean values that might come as strings
  static bool _parseBool(dynamic value) {
    if (value == null) return false;
    if (value is bool) return value;
    if (value is String) {
      final lowercaseValue = value.toLowerCase();
      // Handle various string representations of boolean values
      return lowercaseValue == 'true' ||
          lowercaseValue == 'yes' ||
          lowercaseValue == 'active' ||
          lowercaseValue == '1';
    }
    if (value is int) return value == 1;
    return false;
  }

  Map<String, dynamic> toJson() => {
    'type': type,
    'arabic_crt_description': arabicCrtDescription,
    'name': name,
    'address': address,
    'ville': ville,
    'arabic_ville': arabicVille,
    'phone': phone,
    'fax': fax,
    'email': email,
    'website': website,
    'lat': lat,
    'lng': lng,
    'cover': cover,
    'description': description,
    'is_special': isSpecial,
    'links': links.toJson(),
    'options': options,
    'reservable': reservable,
    'settings': settings.toJson(),
    'slug': slug,
    'status': status,
    'is_show_price': isShowPrice,
    'vignette': vignette,
    'video_link': videoLink,
    'images': images,
    'starting_price': startingPrice,
    'destination_id': destinationId,
    'agency_id': agencyId,
    'arabic_category_code_description': arabicCategoryCodeDescription,
    'category_code_description': categoryCodeDescription,
    'category_code': categoryCode,
    'updated_at': updatedAt.toIso8601String(),
    'name_en': nameEn,
    'ville_en': villeEn,
    'address_en': addressEn,
    'name_ar': nameAr,
    'ville_ar': villeAr,
    'address_ar': addressAr,
    'description_ar': descriptionAr,
    'description_en': descriptionEn,
    'avis_google': avisGoogle,
    'note_google': noteGoogle,
    'id': id,
    'destination': destination,
  };
}

class Links {
  final String website;
  final String facebook;
  final String instagram;
  final String youtube;
  final String twitter;

  Links({
    required this.website,
    required this.facebook,
    required this.instagram,
    required this.youtube,
    required this.twitter,
  });

  factory Links.fromJson(Map<String, dynamic> json) => Links(
    website: json['website'] ?? '',
    facebook: json['facebook'] ?? '',
    instagram: json['instagram'] ?? '',
    youtube: json['youtube'] ?? '',
    twitter: json['twitter'] ?? '',
  );

  Map<String, dynamic> toJson() => {
    'website': website,
    'facebook': facebook,
    'instagram': instagram,
    'youtube': youtube,
    'twitter': twitter,
  };
}

class Settings {
  final bool isAirConditionerIncluded;

  Settings({required this.isAirConditionerIncluded});

  factory Settings.fromJson(Map<String, dynamic> json) => Settings(
    isAirConditionerIncluded: MaisonDHote._parseBool(json['is_air_conditioner_included']),
  );

  Map<String, dynamic> toJson() => {
    'is_air_conditioner_included': isAirConditionerIncluded,
  };
}
