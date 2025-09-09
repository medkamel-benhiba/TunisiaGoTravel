import 'dart:convert';

class HotelDetail {
  final String type;
  final bool auto;
  final String childMinage;
  final String childMaxage;
  final String idCityBbx;
  final String idHotelBbx;
  final String arabicCrtDescription;
  final String name;
  final String address;
  final String ville;
  final String phone;
  final String fax;
  final String email;
  final String website;
  final double lat;
  final double lng;
  final String cover;
  final String description;
  final bool isSpecial;
  final Links links;
  final List<dynamic> options; // Assuming dynamic for now, as it's empty in sample
  final bool reservable;
  final List<Bio> bios;
  final List<dynamic> cancellations; // Empty in sample
  final List<ReleaseHotel> releaseHotels;
  final List<FlashSale> flashSales;
  final List<MinimumStay> minimumstay;
  final List<Spo> spo;
  final List<Discount> discounts;
  final String? slug;
  final String? vignette;
  final String? destinationId;
  final String? categoryCode;
  final String? nameEn;
  final String? addressEn;
  final String? nameAr;
  final String? addressAr;
  final String? nameRu;
  final String? addressRu;
  final String? nameZh;
  final String? addressZh;
  final String? nameKo;
  final String? addressKo;
  final String? nameJa;
  final String? addressJa;
  final String? id;
  final Destination? destination;
  final List<String>? gallery;
  final List<String>? images;
  final String? idCityMouradi;
  final String? idHotelMouradi;
  final String? idHotelBhr;

  HotelDetail({
    required this.type,
    required this.auto,
    required this.childMinage,
    required this.childMaxage,
    required this.idCityBbx,
    required this.idHotelBbx,
    required this.arabicCrtDescription,
    required this.name,
    required this.address,
    required this.ville,
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
    required this.bios,
    required this.cancellations,
    required this.releaseHotels,
    required this.flashSales,
    required this.minimumstay,
    required this.spo,
    required this.discounts,
    this.slug,
    this.vignette,
    this.destinationId,
    this.categoryCode,
    this.nameEn,
    this.addressEn,
    this.nameAr,
    this.addressAr,
    this.nameRu,
    this.addressRu,
    this.nameZh,
    this.addressZh,
    this.nameKo,
    this.addressKo,
    this.nameJa,
    this.addressJa,
    this.id,
    this.destination,
    this.gallery,
    this.images,
    this.idCityMouradi,
    this.idHotelMouradi,
    this.idHotelBhr

  });

  factory HotelDetail.fromJson(Map<String, dynamic> json) {
    bool parseBool(dynamic value) {
      if (value is bool) return value;
      if (value is String) return value.toLowerCase() == 'true';
      return false;
    }

    return HotelDetail(
      type: json['type'] ?? '',
      auto: parseBool(json['auto']),
      childMinage: json['Child_minage'] ?? '0',
      childMaxage: json['Child_maxage'] ?? '12',
      idCityBbx: json['id_city_bbx'] ?? '',
      idHotelBbx: json['id_hotel_bbx'] ?? '',
      arabicCrtDescription: json['arabic_crt_description'] ?? '',
      name: json['name'] ?? '',
      address: json['address'] ?? '',
      ville: json['ville'] ?? '',
      phone: json['phone'] ?? '',
      fax: json['fax'] ?? '',
      email: json['email'] ?? '',
      website: json['website'] ?? '',
      lat: double.tryParse(json['lat'] ?? '0.0') ?? 0.0,
      lng: double.tryParse(json['lng'] ?? '0.0') ?? 0.0,
      cover: json['cover'] ?? '',
      description: json['description'] ?? '',
      isSpecial: parseBool(json['is_special']),
      links: Links.fromJson(json['links'] ?? {}),
      options: json['options'] ?? [],
      reservable: parseBool(json['reservable']),
      bios: (json['bios'] as List<dynamic>? ?? [])
          .map((e) => Bio.fromJson(e))
          .toList(),
      cancellations: json['cancellations'] ?? [],
      releaseHotels: (json['release_hotels'] as List<dynamic>? ?? [])
          .map((e) => ReleaseHotel.fromJson(e))
          .toList(),
      flashSales: (json['flash_sales'] as List<dynamic>? ?? [])
          .map((e) => FlashSale.fromJson(e))
          .toList(),
      minimumstay: (json['minimumstay'] as List<dynamic>? ?? [])
          .map((e) => MinimumStay.fromJson(e))
          .toList(),
      spo: (json['spo'] as List<dynamic>? ?? [])
          .map((e) => Spo.fromJson(e))
          .toList(),
      discounts: (json['discounts'] as List<dynamic>? ?? [])
          .map((e) => Discount.fromJson(e))
          .toList(),
      slug: json['slug'],
      vignette: json['vignette'],
      destinationId: json['destination_id'],
      categoryCode: json['category_code'],
      nameEn: json['name_en'],
      addressEn: json['address_en'],
      nameAr: json['name_ar'],
      addressAr: json['address_ar'],
      nameRu: json['name_ru'],
      addressRu: json['address_ru'],
      nameZh: json['name_zh'],
      addressZh: json['address_zh'],
      nameKo: json['name_ko'],
      addressKo: json['address_ko'],
      nameJa: json['name_ja'],
      addressJa: json['address_ja'],
      id: json['id'],
      destination: json['destination'] != null
          ? Destination.fromJson(json['destination'])
          : null,
      gallery: json['gallery'] != null
          ? List<String>.from(json['gallery'])
          : (json['destination']?['gallery'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList(),
      images: json['images'] != null
          ? List<String>.from(json['images'])
          : [],
      idCityMouradi: json['id_city_mouradi'] ?? '',
      idHotelMouradi: json['id_hotel_mouradi'] ?? '',

    );
  }


  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'auto': auto,
      'Child_minage': childMinage,
      'Child_maxage': childMaxage,
      'id_city_bbx': idCityBbx,
      'id_hotel_bbx': idHotelBbx,
      'arabic_crt_description': arabicCrtDescription,
      'name': name,
      'address': address,
      'ville': ville,
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
      'bios': bios.map((e) => e.toJson()).toList(),
      'cancellations': cancellations,
      'release_hotels': releaseHotels.map((e) => e.toJson()).toList(),
      'flash_sales': flashSales.map((e) => e.toJson()).toList(),
      'minimumstay': minimumstay.map((e) => e.toJson()).toList(),
      'spo': spo.map((e) => e.toJson()).toList(),
      'discounts': discounts.map((e) => e.toJson()).toList(),
      'slug': slug,
      'vignette': vignette,
      'destination_id': destinationId,
      'category_code': categoryCode,
      'name_en': nameEn,
      'address_en': addressEn,
      'name_ar': nameAr,
      'address_ar': addressAr,
      'name_ru': nameRu,
      'address_ru': addressRu,
      'name_zh': nameZh,
      'address_zh': addressZh,
      'name_ko': nameKo,
      'address_ko': addressKo,
      'name_ja': nameJa,
      'address_ja': addressJa,
      'id': id,
      'destination': destination?.toJson(),
      'gallery': gallery,
      'images': images,
      'images': images,


    };
  }
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

  factory Links.fromJson(Map<String, dynamic> json) {
    return Links(
      website: json['website'] ?? '',
      facebook: json['facebook'] ?? '',
      instagram: json['instagram'] ?? '',
      youtube: json['youtube'] ?? '',
      twitter: json['twitter'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'website': website,
      'facebook': facebook,
      'instagram': instagram,
      'youtube': youtube,
      'twitter': twitter,
    };
  }
}



class Bio {
  final String name;
  final String nameRu;
  final String nameEn;
  final String nameAr;
  final String nameZh;
  final String nameKo;
  final String nameJa;
  final String description;
  final String descriptionRu;
  final String descriptionEn;
  final String descriptionAr;
  final String descriptionZh;
  final String descriptionKo;
  final String descriptionJa;
  final String icon;
  final String hotelIds; // Stored as JSON string in sample, but parsed as string for simplicity
  final String id;

  Bio({
    required this.name,
    required this.nameRu,
    required this.nameEn,
    required this.nameAr,
    required this.nameZh,
    required this.nameKo,
    required this.nameJa,
    required this.description,
    required this.descriptionRu,
    required this.descriptionEn,
    required this.descriptionAr,
    required this.descriptionZh,
    required this.descriptionKo,
    required this.descriptionJa,
    required this.icon,
    required this.hotelIds,
    required this.id,
  });

  factory Bio.fromJson(Map<String, dynamic> json) {
    return Bio(
      name: json['name'] ?? '',
      nameRu: json['name_ru'] ?? '',
      nameEn: json['name_en'] ?? '',
      nameAr: json['name_ar'] ?? '',
      nameZh: json['name_zh'] ?? '',
      nameKo: json['name_ko'] ?? '',
      nameJa: json['name_ja'] ?? '',
      description: json['description'] ?? '',
      descriptionRu: json['description_ru'] ?? '',
      descriptionEn: json['description_en'] ?? '',
      descriptionAr: json['description_ar'] ?? '',
      descriptionZh: json['description_zh'] ?? '',
      descriptionKo: json['description_ko'] ?? '',
      descriptionJa: json['description_ja'] ?? '',
      icon: json['icon'] ?? '',
      hotelIds: json['hotel_ids'] ?? '',
      id: json['id'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'name_ru': nameRu,
      'name_en': nameEn,
      'name_ar': nameAr,
      'name_zh': nameZh,
      'name_ko': nameKo,
      'name_ja': nameJa,
      'description': description,
      'description_ru': descriptionRu,
      'description_en': descriptionEn,
      'description_ar': descriptionAr,
      'description_zh': descriptionZh,
      'description_ko': descriptionKo,
      'description_ja': descriptionJa,
      'icon': icon,
      'hotel_ids': hotelIds,
      'id': id,
    };
  }
}

class ReleaseHotel {
  final String hotelId;
  final String dateStart;
  final String dateEnd;
  final int dayNumber;
  final String marchiId;
  final String updatedAt;
  final String createdAt;
  final String id;

  ReleaseHotel({
    required this.hotelId,
    required this.dateStart,
    required this.dateEnd,
    required this.dayNumber,
    required this.marchiId,
    required this.updatedAt,
    required this.createdAt,
    required this.id,
  });

  factory ReleaseHotel.fromJson(Map<String, dynamic> json) {
    return ReleaseHotel(
      hotelId: json['hotel_id'] ?? '',
      dateStart: json['date_start'] ?? '',
      dateEnd: json['date_end'] ?? '',
      dayNumber: json['day_number'] ?? 0,
      marchiId: json['marchi_id'] ?? '',
      updatedAt: json['updated_at'] ?? '',
      createdAt: json['created_at'] ?? '',
      id: json['id'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'hotel_id': hotelId,
      'date_start': dateStart,
      'date_end': dateEnd,
      'day_number': dayNumber,
      'marchi_id': marchiId,
      'updated_at': updatedAt,
      'created_at': createdAt,
      'id': id,
    };
  }
}

class FlashSale {
  final String hotelId;
  final String dateStart;
  final String dateEnd;
  final int percentage;
  final String updatedAt;
  final String createdAt;
  final String id;

  FlashSale({
    required this.hotelId,
    required this.dateStart,
    required this.dateEnd,
    required this.percentage,
    required this.updatedAt,
    required this.createdAt,
    required this.id,
  });

  factory FlashSale.fromJson(Map<String, dynamic> json) {
    return FlashSale(
      hotelId: json['hotel_id'] ?? '',
      dateStart: json['date_start'] ?? '',
      dateEnd: json['date_end'] ?? '',
      percentage: json['percentage'] ?? 0,
      updatedAt: json['updated_at'] ?? '',
      createdAt: json['created_at'] ?? '',
      id: json['id'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'hotel_id': hotelId,
      'date_start': dateStart,
      'date_end': dateEnd,
      'percentage': percentage,
      'updated_at': updatedAt,
      'created_at': createdAt,
      'id': id,
    };
  }
}

class MinimumStay {
  final String hotelId;
  final String dateStart;
  final String dateEnd;
  final int number;
  final String? marchiId;
  final String updatedAt;
  final String createdAt;
  final String id;

  MinimumStay({
    required this.hotelId,
    required this.dateStart,
    required this.dateEnd,
    required this.number,
    this.marchiId,
    required this.updatedAt,
    required this.createdAt,
    required this.id,
  });

  factory MinimumStay.fromJson(Map<String, dynamic> json) {
    return MinimumStay(
      hotelId: json['hotel_id'] ?? '',
      dateStart: json['date_start'] ?? '',
      dateEnd: json['date_end'] ?? '',
      number: json['number'] ?? 0,
      marchiId: json['marchi_id'],
      updatedAt: json['updated_at'] ?? '',
      createdAt: json['created_at'] ?? '',
      id: json['id'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'hotel_id': hotelId,
      'date_start': dateStart,
      'date_end': dateEnd,
      'number': number,
      'marchi_id': marchiId,
      'updated_at': updatedAt,
      'created_at': createdAt,
      'id': id,
    };
  }
}

class Spo {
  final String hotelId;
  final String dateBefore;
  final String dateStartStay;
  final String dateEndStay;
  final List<Percentage> percentage;
  final String updatedAt;
  final String createdAt;
  final String id;

  Spo({
    required this.hotelId,
    required this.dateBefore,
    required this.dateStartStay,
    required this.dateEndStay,
    required this.percentage,
    required this.updatedAt,
    required this.createdAt,
    required this.id,
  });

  factory Spo.fromJson(Map<String, dynamic> json) {
    return Spo(
      hotelId: json['hotel_id'] ?? '',
      dateBefore: json['date_before'] ?? '',
      dateStartStay: json['date_start_stay'] ?? '',
      dateEndStay: json['date_end_stay'] ?? '',
      percentage: (json['percentage'] as List<dynamic>? ?? [])
          .map((e) => Percentage.fromJson(e))
          .toList(),
      updatedAt: json['updated_at'] ?? '',
      createdAt: json['created_at'] ?? '',
      id: json['id'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'hotel_id': hotelId,
      'date_before': dateBefore,
      'date_start_stay': dateStartStay,
      'date_end_stay': dateEndStay,
      'percentage': percentage.map((e) => e.toJson()).toList(),
      'updated_at': updatedAt,
      'created_at': createdAt,
      'id': id,
    };
  }
}

class Percentage {
  final String accommodationId;
  final String discountType;
  final int value;

  Percentage({
    required this.accommodationId,
    required this.discountType,
    required this.value,
  });

  factory Percentage.fromJson(Map<String, dynamic> json) {
    return Percentage(
      accommodationId: json['accommodation_id'] ?? '',
      discountType: json['discount_type'] ?? '',
      value: json['value'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'accommodation_id': accommodationId,
      'discount_type': discountType,
      'value': value,
    };
  }
}

class Discount {
  final String hotelId;
  final String dateStart;
  final String dateEnd;
  final List<DiscountDetail> discounts;
  final String updatedAt;
  final String createdAt;
  final String id;

  Discount({
    required this.hotelId,
    required this.dateStart,
    required this.dateEnd,
    required this.discounts,
    required this.updatedAt,
    required this.createdAt,
    required this.id,
  });

  factory Discount.fromJson(Map<String, dynamic> json) {
    return Discount(
      hotelId: json['hotel_id'] ?? '',
      dateStart: json['date_start'] ?? '',
      dateEnd: json['date_end'] ?? '',
      discounts: (json['discounts'] as List<dynamic>? ?? [])
          .map((e) => DiscountDetail.fromJson(e))
          .toList(),
      updatedAt: json['updated_at'] ?? '',
      createdAt: json['created_at'] ?? '',
      id: json['id'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'hotel_id': hotelId,
      'date_start': dateStart,
      'date_end': dateEnd,
      'discounts': discounts.map((e) => e.toJson()).toList(),
      'updated_at': updatedAt,
      'created_at': createdAt,
      'id': id,
    };
  }
}

class DiscountDetail {
  final String type;
  final int ageMin;
  final int ageMax;
  final int percentage;
  final List<int> percentages;
  final int numberAdultes;
  final int numberChild;
  final String? lit;
  final int daysNumber;

  DiscountDetail({
    required this.type,
    required this.ageMin,
    required this.ageMax,
    required this.percentage,
    required this.percentages,
    required this.numberAdultes,
    required this.numberChild,
    this.lit,
    required this.daysNumber,
  });

  factory DiscountDetail.fromJson(Map<String, dynamic> json) {
    return DiscountDetail(
      type: json['type'] ?? '',
      ageMin: json['age_min'] ?? 0,
      ageMax: json['age_max'] ?? 0,
      percentage: json['percentage'] ?? 0,
      percentages: List<int>.from(json['percentages'] ?? []),
      numberAdultes: json['number_adultes'] ?? 0,
      numberChild: json['number_child'] ?? 0,
      lit: json['lit'],
      daysNumber: json['days_number'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'age_min': ageMin,
      'age_max': ageMax,
      'percentage': percentage,
      'percentages': percentages,
      'number_adultes': numberAdultes,
      'number_child': numberChild,
      'lit': lit,
      'days_number': daysNumber,
    };
  }
}

class Destination {
  final String name;
  final List<String> idCityBbx;
  final double lat;
  final double lng;
  final String country;
  final String iso2;
  final String state;
  final String status;
  final String descriptionEn;
  final String population;
  final String updatedAt;
  final String createdAt;
  final String description;
  final String metaTagDescription;
  final String metaTagKeywords;
  final String homeDescription;
  final String metaTagTitle;
  final String shortDescription;
  final String slug;
  final String subtitle;
  final String title;
  final String videoLink;
  final String cover;
  final List<String> gallery;
  final String isSpecial;
  final String vignette;
  final List<String> destinationservices;
  final String descriptionMobile;
  final String nameAr;
  final String stateAr;
  final String countryAr;
  final Map<String, dynamic> seo; // Nested SEO fields

  Destination({
    required this.name,
    required this.idCityBbx,
    required this.lat,
    required this.lng,
    required this.country,
    required this.iso2,
    required this.state,
    required this.status,
    required this.descriptionEn,
    required this.population,
    required this.updatedAt,
    required this.createdAt,
    required this.description,
    required this.metaTagDescription,
    required this.metaTagKeywords,
    required this.homeDescription,
    required this.metaTagTitle,
    required this.shortDescription,
    required this.slug,
    required this.subtitle,
    required this.title,
    required this.videoLink,
    required this.cover,
    required this.gallery,
    required this.isSpecial,
    required this.vignette,
    required this.destinationservices,
    required this.descriptionMobile,
    required this.nameAr,
    required this.stateAr,
    required this.countryAr,
    required this.seo,
  });

  factory Destination.fromJson(Map<String, dynamic> json) {
    return Destination(
      name: json['name'] ?? '',
      idCityBbx: List<String>.from(json['id_city_bbx'] ?? []),
      lat: double.tryParse(json['lat']?.toString() ?? '0.0') ?? 0.0,
      lng: double.tryParse(json['lng']?.toString() ?? '0.0') ?? 0.0,
      country: json['country'] ?? '',
      iso2: json['iso2'] ?? '',
      state: json['state'] ?? '',
      status: json['status'] ?? '',
      descriptionEn: json['description_en'] ?? '',
      population: json['population'] ?? '',
      updatedAt: json['updated_at'] ?? '',
      createdAt: json['created_at'] ?? '',
      description: json['description'] ?? '',
      metaTagDescription: json['meta_tag_description'] ?? '',
      metaTagKeywords: json['meta_tag_keywords'] ?? '',
      homeDescription: json['home_description'] ?? '',
      metaTagTitle: json['meta_tag_title'] ?? '',
      shortDescription: json['short_description'] ?? '',
      slug: json['slug'] ?? '',
      subtitle: json['subtitle'] ?? '',
      title: json['title'] ?? '',
      videoLink: json['video_link'] ?? '',
      cover: json['cover'] ?? '',
      gallery: List<String>.from(json['gallery'] ?? []),
      isSpecial: json['is_special'] ?? '',
      vignette: json['vignette'] ?? '',
      destinationservices: List<String>.from(json['destinationservices'] ?? []),
      descriptionMobile: json['description_mobile'] ?? '',
      nameAr: json['name_ar'] ?? '',
      stateAr: json['state_ar'] ?? '',
      countryAr: json['country_ar'] ?? '',
      seo: json['seo'] ?? {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'id_city_bbx': idCityBbx,
      'lat': lat,
      'lng': lng,
      'country': country,
      'iso2': iso2,
      'state': state,
      'status': status,
      'description_en': descriptionEn,
      'population': population,
      'updated_at': updatedAt,
      'created_at': createdAt,
      'description': description,
      'meta_tag_description': metaTagDescription,
      'meta_tag_keywords': metaTagKeywords,
      'home_description': homeDescription,
      'meta_tag_title': metaTagTitle,
      'short_description': shortDescription,
      'slug': slug,
      'subtitle': subtitle,
      'title': title,
      'video_link': videoLink,
      'cover': cover,
      'gallery': gallery,
      'is_special': isSpecial,
      'vignette': vignette,
      'destinationservices': destinationservices,
      'description_mobile': descriptionMobile,
      'name_ar': nameAr,
      'state_ar': stateAr,
      'country_ar': countryAr,
      'seo': seo,
    };
  }
}

// Usage example: Parse from JSON string
// HotelDetail hotel = HotelDetail.fromJson(json.decode(jsonString)['hotels'][0]);