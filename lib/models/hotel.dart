import 'dart:ui';

class Hotel {
  final String id;
  final String id_hotel_bbx;

  final String name;
  final String name_en;
  final String name_ar;
  final String name_ru;
  final String name_ja;
  final String name_ko;
  final String name_zh;

  final String address;
  final String? address_en;
  final String? address_ar;
  final String? address_ru;
  final String? address_ja;
  final String? address_ko;
  final String? address_zh;

  final String cover;
  final List<String>? images;
  final bool reservable;
  final String slug;
  final String lat;
  final String lng;
  final String destinationId;
  final int? categoryCode;
  final String? destinationName;
  final String? description;
  final String? description_en;
  final String? description_ar;
  final String? description_ja;
  final String? description_ru;
  final String? description_ko;
  final String? description_zh;

  final String? idCityMouradi;
  final String? idHotelMouradi;
  final String? idHotelBhr;


  Hotel({
    required this.id,
    required this.id_hotel_bbx,
    required this.name,
    required this.name_en,
    required this.name_ar,
    required this.name_ru,
    required this.name_ja,
    required this.name_ko,
    required this.name_zh,
    required this.address,
    required this.cover,
    required this.images,
    required this.lat,
    required this.lng,
    required this.reservable,
    required this.slug,
    required this.destinationId,
    this.categoryCode,
    this.destinationName,
    this.description,
    this.description_ar,
    this.description_en,
    this.description_ja,
    this.description_ru,
    this.description_ko,
    this.description_zh,
    this.address_en,
    this.address_ar,
    this.address_ru,
    this.address_ja,
    this.address_ko,
    this.address_zh,


    this.idCityMouradi,
    this.idHotelMouradi,
    this.idHotelBhr
  });

  factory Hotel.fromJson(Map<String, dynamic> json) {

    return Hotel(
      id: json['id'] ?? '',
      id_hotel_bbx: json['id_hotel_bbx'] ?? '',
      name: json['name'] ?? '',
      name_en: json['name_en'] ?? '',
      name_ar: json['name_ar'] ?? '',
      name_ru: json['name_ru'] ?? '',
      name_ko: json['name_ko'] ?? '',
      name_ja: json['name_ja'] ?? '',
      name_zh: json['name_zh'] ?? '',
      address: json['address'] ?? '',
      address_en: json['address_en'] ?? '',
      address_ar: json['address_ar'] ?? '',
      address_ru: json['address_ru'] ?? '',
      address_ko: json['address_ko'] ?? '',
      address_ja: json['address_ja'] ?? '',
      address_zh: json['address_zh'] ?? '',


      cover: json['cover'] ?? '',
      images: json['images'] != null
          ? List<String>.from(json['images'])
          : [],
      lat: json['lat'] ?? '',
      lng: json['lng'] ?? '',

      reservable: json['reservable'] ?? false,
      slug: json['slug'] ?? '',
      destinationId: json['destination_id'] ?? '',
      categoryCode: json['category_code'] != null
          ? int.tryParse(json['category_code'].toString())
          : null,
      destinationName: json['destination']?['name'] ?? json['ville'] ?? '',
      description: json['description'] ?? '',
      description_en: json['description_en'] ?? '',
      description_ar: json['description_ar'] ?? '',
      description_ja: json['description_ja'] ?? '',
      description_ru: json['description_ru'] ?? '',
      description_ko: json['description_ko'] ?? '',
      description_zh: json['description_zh'] ?? '',
      idCityMouradi: json['id_city_mouradi'] ?? '',
      idHotelMouradi: json['id_hotel_mouradi'] ?? '',

    );
  }


  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'id_hotel_bbx': id_hotel_bbx,
      'name': name,
      'address': address,
      'cover': cover,
      'reservable': reservable,
      'slug': slug,
      'destination_id': destinationId,
      'category_code': categoryCode,
      'destination_name': destinationName,
      'short_description': description,
      'short_description_en': description_en,
      'short_description_ar': description_ar,
      'short_description_ja': description_ja,
      'short_description_ru': description_ru,
      'short_description_ko': description_ko,
      'short_description_zh': description_zh,

    };
  }
  String getName(Locale locale) {
    switch (locale.languageCode) {
      case 'ar':
        return name_ar.isNotEmpty ? name_ar : name;
      case 'en':
        return name_en.isNotEmpty ? name_en : name;
      case 'ru':
        return name_ru.isNotEmpty ? name_ru : name;
      case 'ko':
        return name_ko.isNotEmpty ? name_ko : name;
      case 'zh':
        return name_zh.isNotEmpty ? name_zh : name;
      case 'ja':
        return name_ja.isNotEmpty ? name_ja : name;

      default:
        return name;
    }
  }

  String? getDescription(Locale locale) {
    switch (locale.languageCode) {
      case 'ar':
        return description_ar!.isNotEmpty ? description_ar : description;
      case 'en':
        return description_en!.isNotEmpty ? description_en : description;
      case 'ru':
        return description_ru!.isNotEmpty ? description_ru : description;
      case 'ko':
        return description_ko!.isNotEmpty ? description_ko : description;
      case 'ja':
        return description_ja!.isNotEmpty ? description_ja : description;
      case 'zh':
        return description_zh!.isNotEmpty ? description_zh : description;
      default:
        return description;
    }
  }
  String? getAddress(Locale locale) {
    switch (locale.languageCode) {
      case 'ar':
        return address_ar!.isNotEmpty ? address_ar : address;
      case 'en':
        return address_en!.isNotEmpty ? address_en : address;
      case 'ru':
        return address_ru!.isNotEmpty ? address_ru : address;
      case 'ko':
        return address_ko!.isNotEmpty ? address_ko : address;
      case 'ja':
        return address_ja!.isNotEmpty ? address_ja : address;
      case 'zh':
        return address_zh!.isNotEmpty ? address_zh : address;
      default:
        return address;
    }
  }
}
