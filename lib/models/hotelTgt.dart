
import 'package:flutter/material.dart';

class HotelTgt {
  final String id;
  final String name;
  final String? name_en;
  final String? name_ar;
  final String? name_ru;
  final String? name_ja;
  final String? name_ko;
  final String? name_zh;

  final String slug;
  final String? idCityBbx;
  final String? idHotelBbx;
  final DisponibilityTgt disponibility;

  HotelTgt({
    required this.id,
    required this.name,
    required this.slug,
    this.idCityBbx,
    this.idHotelBbx,
    required this.disponibility,
    this.name_en,
    this.name_ar,
    this.name_ru,
    this.name_ja,
    this.name_ko,
    this.name_zh,

  });

  factory HotelTgt.fromJson(Map<String, dynamic> json) {
    DisponibilityTgt disponibility = json["disponibility"] != null
        ? DisponibilityTgt.fromJson(Map<String, dynamic>.from(json["disponibility"]))
        : DisponibilityTgt.empty();

    return HotelTgt(
      id: json["id"]?.toString() ?? '',
      name: json["name"] ?? '',
      name_ar: json["name_ar"] ?? '',
      name_en: json["name_en"] ?? '',
      name_ru: json["name_ru"] ?? '',
      name_ja: json["name_ja"] ?? '',
      name_ko: json["name_ko"] ?? '',
      name_zh: json["name_zh"] ?? '',
      slug: json["slug"] ?? '',
      idCityBbx: json["id_city_bbx"]?.toString(),
      idHotelBbx: json["id_hotel_bbx"]?.toString(),
      disponibility: disponibility,
    );
  }

  // NEW: Factory method for availability API response
  factory HotelTgt.fromAvailabilityJson(Map<String, dynamic> json, dynamic hotelDetail) {
    // Extract hotel info from hotelDetail parameter
    String hotelId = '';
    String hotelName = '';
    String hotelNameAr = '';
    String hotelNameEn = '';
    String hotelNameRu = '';
    String hotelNameJa = '';
    String hotelNameKo = '';
    String hotelNameZh = '';
    String hotelSlug = '';

    if (hotelDetail != null) {
      if (hotelDetail is Map<String, dynamic>) {
        hotelId = hotelDetail['id']?.toString() ?? '';
        hotelName = hotelDetail['name']?.toString() ?? '';
        hotelNameAr = hotelDetail['name_ar']?.toString() ?? '';
        hotelNameEn = hotelDetail['name_en']?.toString() ?? '';
        hotelNameRu = hotelDetail['name_ru']?.toString() ?? '';
        hotelNameJa = hotelDetail['name_ja']?.toString() ?? '';
        hotelNameKo = hotelDetail['name_ko']?.toString() ?? '';
        hotelNameZh = hotelDetail['name_zh']?.toString() ?? '';

        hotelSlug = hotelDetail['slug']?.toString() ?? '';
      } else if (hotelDetail.runtimeType.toString().contains('HotelDetail')) {
        // If it's a HotelDetail object, access properties directly
        try {
          hotelId = hotelDetail.id?.toString() ?? '';
          hotelName = hotelDetail.name?.toString() ?? '';
          hotelNameAr = hotelDetail.nameAr?.toString() ?? '';
          hotelNameEn = hotelDetail.nameEn?.toString() ?? '';
          hotelNameRu = hotelDetail.nameRu?.toString() ?? '';
          hotelNameJa = hotelDetail.nameJa?.toString() ?? '';
          hotelNameKo = hotelDetail.nameKo?.toString() ?? '';
          hotelNameZh = hotelDetail.nameZh?.toString() ?? '';
          hotelSlug = hotelDetail.slug?.toString() ?? '';
        } catch (e) {
          // Fallback if properties don't exist
          hotelId = '';
          hotelName = '';
          hotelNameAr = '';
          hotelNameEn = '';
          hotelNameRu = '';
          hotelNameJa = '';
          hotelNameKo = '';
          hotelNameZh = '';
          hotelSlug = '';
        }
      }
    }

    // Create DisponibilityTgt from the API response
    final disponibility = DisponibilityTgt(
      disponibilitytype: json['disponibilitytype']?.toString() ?? 'tgt',
      pensions: (json['pensions'] as List<dynamic>? ?? [])
          .map((p) => PensionTgt.fromJson(Map<String, dynamic>.from(p)))
          .toList(),
    );

    return HotelTgt(
      id: hotelId,
      name: hotelName,
      name_ar: hotelNameAr,
      name_en: hotelNameEn,
      name_ru: hotelNameRu,
      name_ja: hotelNameJa,
      name_ko: hotelNameKo,
      name_zh: hotelNameZh,
      slug: hotelSlug,
      disponibility: disponibility,
    );
  }

  factory HotelTgt.empty() => HotelTgt(
    id: '',
    name: '',
    name_ar: '',
    name_en: '',
    name_ru: '',
    name_ja: '',
    name_ko: '',
    name_zh: '',
    slug: '',
    disponibility: DisponibilityTgt.empty(),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "name_ar": name_ar,
    "name_en": name_en,
    "name_ru": name_ru,
    "name_ja": name_ja,
    "name_ko": name_ko,
    "name_zh": name_zh,
    "slug": slug,
    "id_city_bbx": idCityBbx,
    "id_hotel_bbx": idHotelBbx,
    "disponibility": disponibility.toJson(),
  };
  String getName(Locale locale) {
    switch (locale.languageCode) {
      case 'ar': return name_ar?.isNotEmpty == true ? name_ar! : name;
      case 'en': return name_en?.isNotEmpty == true ? name_en! : name;
      case 'ru': return name_ru?.isNotEmpty == true ? name_ru! : name;
      case 'ja': return name_ja?.isNotEmpty == true ? name_ja! : name;
      case 'ko': return name_ko?.isNotEmpty == true ? name_ko! : name;
      case 'zh': return name_zh?.isNotEmpty == true ? name_zh! : name;
      default: return name;
    }
  }
}

class DisponibilityTgt {
  final String disponibilitytype;
  final List<PensionTgt> pensions;

  DisponibilityTgt({
    required this.disponibilitytype,
    required this.pensions,
  });

  factory DisponibilityTgt.fromJson(Map<String, dynamic> json) {
    List<PensionTgt> pensionsList = [];
    final pensionsData = json["pensions"];

    if (pensionsData is List) {
      pensionsList = pensionsData
          .where((p) => p is Map)
          .map((p) => PensionTgt.fromJson(Map<String, dynamic>.from(p)))
          .toList();
    } else if (pensionsData is Map) {
      pensionsList = [PensionTgt.fromJson(Map<String, dynamic>.from(pensionsData))];
    }

    return DisponibilityTgt(
      disponibilitytype: json["disponibilitytype"] ?? '',
      pensions: pensionsList,
    );
  }

  factory DisponibilityTgt.empty() =>
      DisponibilityTgt(disponibilitytype: '', pensions: []);

  Map<String, dynamic> toJson() => {
    "disponibilitytype": disponibilitytype,
    "pensions": pensions.map((p) => p.toJson()).toList(),
  };
}

class PensionTgt {
  final String id;
  final String name;
  final String? nameAr;
  final String? nameEn;
  final String? nameRu;
  final String? nameJa;
  final String? nameKo;
  final String? nameZh;

  final String devise;
  final String description;
  final String? descriptionAr;
  final String? descriptionEn;
  final String? descriptionRu;
  final String? descriptionJa;
  final String? descriptionKo;
  final String? descriptionZh;

  final List<RoomTgt> rooms;

  PensionTgt({
    required this.id,
    required this.name,
    this.nameAr,
    this.nameEn,
    this.nameRu,
    this.nameJa,
    this.nameKo,
    this.nameZh,
    required this.devise,
    required this.description,
    this.descriptionAr,
    this.descriptionEn,
    this.descriptionRu,
    this.descriptionJa,
    this.descriptionKo,
    this.descriptionZh,
    required this.rooms,
  });

  factory PensionTgt.fromJson(Map<String, dynamic> json) {
    List<RoomTgt> roomsList = [];
    final roomsData = json["rooms"];
    if (roomsData is List) {
      roomsList = roomsData
          .where((r) => r is Map)
          .map((r) => RoomTgt.fromJson(Map<String, dynamic>.from(r)))
          .toList();
    }

    return PensionTgt(
      id: json["id"]?.toString() ?? '',
      name: json["name"] ?? '',
      nameAr: json["name_ar"],
      nameEn: json["name_en"],
      nameRu: json["name_ru"],
      nameJa: json["name_ja"],
      nameKo: json["name_ko"],
      nameZh: json["name_zh"],
      devise: json["devise"] ?? 'TND',
      description: json["description"] ?? '',
      descriptionAr: json["description_ar"],
      descriptionEn: json["description_en"],
      descriptionRu: json["description_ru"],
      descriptionJa: json["description_ja"],
      descriptionKo: json["description_ko"],
      descriptionZh: json["description_zh"],
      rooms: roomsList,
    );
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "name_ar": nameAr,
    "name_en": nameEn,
    "name_ru": nameRu,
    "name_ja": nameJa,
    "name_ko": nameKo,
    "name_zh": nameZh,
    "devise": devise,
    "description": description,
    "description_ar": descriptionAr,
    "description_en": descriptionEn,
    "description_ru": descriptionRu,
    "description_ja": descriptionJa,
    "description_ko": descriptionKo,
    "description_zh": descriptionZh,
    "rooms": rooms.map((r) => r.toJson()).toList(),
  };

  /// helper
  String getName(Locale locale) {
    switch (locale.languageCode) {
      case 'ar': return nameAr?.isNotEmpty == true ? nameAr! : name;
      case 'en': return nameEn?.isNotEmpty == true ? nameEn! : name;
      case 'ru': return nameRu?.isNotEmpty == true ? nameRu! : name;
      case 'ja': return nameJa?.isNotEmpty == true ? nameJa! : name;
      case 'ko': return nameKo?.isNotEmpty == true ? nameKo! : name;
      case 'zh': return nameZh?.isNotEmpty == true ? nameZh! : name;
      default: return name;
    }
  }

  String getDescription(Locale locale) {
    switch (locale.languageCode) {
      case 'ar': return descriptionAr?.isNotEmpty == true ? descriptionAr! : description;
      case 'en': return descriptionEn?.isNotEmpty == true ? descriptionEn! : description;
      case 'ru': return descriptionRu?.isNotEmpty == true ? descriptionRu! : description;
      case 'ja': return descriptionJa?.isNotEmpty == true ? descriptionJa! : description;
      case 'ko': return descriptionKo?.isNotEmpty == true ? descriptionKo! : description;
      case 'zh': return descriptionZh?.isNotEmpty == true ? descriptionZh! : description;
      default: return description;
    }
  }
}


class RoomTgt {
  final String id;
  final String title;
  final List<Capacity> capacity;
  final List<String> attributes;
  final int stillAvailable;
  final List<PurchasePrice> purchasePrice;
  final Map<String, double>? conversionRates;

  RoomTgt({
    required this.id,
    required this.title,
    required this.capacity,
    required this.attributes,
    required this.stillAvailable,
    required this.purchasePrice,
    this.conversionRates,
  });

  factory RoomTgt.fromJson(Map<String, dynamic> json) {
    List<Capacity> capacityList = [];
    final capacityData = json["capacity"];
    if (capacityData is List) {
      capacityList = capacityData
          .where((c) => c is Map)
          .map((c) => Capacity.fromJson(Map<String, dynamic>.from(c)))
          .toList();
    }

    List<PurchasePrice> purchasePriceList = [];
    final priceData = json["purchase_price"];
    if (priceData is List) {
      purchasePriceList = priceData
          .where((p) => p is Map)
          .map((p) => PurchasePrice.fromJson(Map<String, dynamic>.from(p)))
          .toList();
    }

    List<String> attributesList = [];
    final attributesData = json["attributes"];
    if (attributesData is List) {
      attributesList = attributesData.map((a) => a.toString()).toList();
    }

    Map<String, double>? conversionRatesMap;
    if (json["conversion_rates"] is Map) {
      conversionRatesMap = (json["conversion_rates"] as Map)
          .map((k, v) => MapEntry(k.toString(), (v as num).toDouble()));
    }

    return RoomTgt(
      id: json["id"]?.toString() ?? '',
      title: json["title"] ?? '',
      capacity: capacityList,
      attributes: attributesList,
      stillAvailable: json["still_available"] ?? 0,
      purchasePrice: purchasePriceList,
      conversionRates: conversionRatesMap,
    );
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "title": title,
    "capacity": capacity.map((c) => c.toJson()).toList(),
    "attributes": attributes,
    "still_available": stillAvailable,
    "purchase_price": purchasePrice.map((p) => p.toJson()).toList(),
    "conversion_rates": conversionRates,
  };
}

class Capacity {
  final int adults;
  final int children;
  final int babies;
  final int? maxBabiesAge;

  Capacity({
    required this.adults,
    required this.children,
    required this.babies,
    this.maxBabiesAge,
  });

  factory Capacity.fromJson(Map<String, dynamic> json) {
    return Capacity(
      adults: json["adults"] ?? 0,
      children: json["children"] ?? 0,
      babies: json["babies"] ?? 0,
      maxBabiesAge: json["max_babies_age"],
    );
  }

  Map<String, dynamic> toJson() => {
    "adults": adults,
    "children": children,
    "babies": babies,
    "max_babies_age": maxBabiesAge,
  };
}

class PurchasePrice {
  final String id;
  final String roomId;
  final String accomodationId;
  final double purchasePrice;
  final double commission;
  final String dateStart;
  final String dateEnd;
  final bool status;
  final List<Partner> partners;
  final String marchiId;
  final String currency;
  final Map<String, double>? conversionRates;
  final String updatedAt;
  final String createdAt;
  final AccommodationDetails? accommodation;

  PurchasePrice({
    required this.id,
    required this.roomId,
    required this.accomodationId,
    required this.purchasePrice,
    required this.commission,
    required this.dateStart,
    required this.dateEnd,
    required this.status,
    required this.partners,
    required this.marchiId,
    required this.currency,
    this.conversionRates,
    required this.updatedAt,
    required this.createdAt,
    this.accommodation,
  });

  factory PurchasePrice.fromJson(Map<String, dynamic> json) {
    List<Partner> partnersList = [];
    final partnersData = json["partners"];
    if (partnersData is List) {
      partnersList = partnersData
          .where((p) => p is Map)
          .map((p) => Partner.fromJson(Map<String, dynamic>.from(p)))
          .toList();
    }

    Map<String, double>? conversionRatesMap;
    if (json["conversion_rates"] is Map) {
      conversionRatesMap = (json["conversion_rates"] as Map)
          .map((k, v) => MapEntry(k.toString(), (v as num).toDouble()));
    }

    return PurchasePrice(
      id: json["id"]?.toString() ?? '',
      roomId: json["room_id"]?.toString() ?? '',
      accomodationId: json["accomodation_id"]?.toString() ?? '',
      purchasePrice: (json["purchase_price"] ?? 0).toDouble(),
      commission: (json["commission"] ?? 0).toDouble(),
      dateStart: json["date_start"] ?? '',
      dateEnd: json["date_end"] ?? '',
      status: json["status"] ?? false,
      partners: partnersList,
      marchiId: json["marchi_id"]?.toString() ?? '',
      currency: json["currency"] ?? 'TND',
      conversionRates: conversionRatesMap,
      updatedAt: json["updated_at"] ?? '',
      createdAt: json["created_at"] ?? '',
      accommodation: json["accommodation"] != null
          ? AccommodationDetails.fromJson(
          Map<String, dynamic>.from(json["accommodation"]))
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "room_id": roomId,
    "accomodation_id": accomodationId,
    "purchase_price": purchasePrice,
    "commission": commission,
    "date_start": dateStart,
    "date_end": dateEnd,
    "status": status,
    "partners": partners.map((p) => p.toJson()).toList(),
    "marchi_id": marchiId,
    "currency": currency,
    "conversion_rates": conversionRates,
    "updated_at": updatedAt,
    "created_at": createdAt,
    "accommodation": accommodation?.toJson(),
  };
}

class Partner {
  final String partnerId;
  final double commission;
  final double discount;

  Partner({
    required this.partnerId,
    required this.commission,
    required this.discount,
  });

  factory Partner.fromJson(Map<String, dynamic> json) {
    return Partner(
      partnerId: json["partner_id"]?.toString() ?? '',
      commission: (json["commission"] ?? 0).toDouble(),
      discount: (json["discount"] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
    "partner_id": partnerId,
    "commission": commission,
    "discount": discount,
  };
}

class AccommodationDetails {
  final String hotelId;
  final String accommodationId;
  final String marchiId;
  final String updatedAt;
  final String createdAt;
  final String id;
  final AccommodationInfo accommodation;

  AccommodationDetails({
    required this.hotelId,
    required this.accommodationId,
    required this.marchiId,
    required this.updatedAt,
    required this.createdAt,
    required this.id,
    required this.accommodation,
  });

  factory AccommodationDetails.fromJson(Map<String, dynamic> json) {
    return AccommodationDetails(
      hotelId: json["hotel_id"]?.toString() ?? '',
      accommodationId: json["accommodation_id"]?.toString() ?? '',
      marchiId: json["marchi_id"]?.toString() ?? '',
      updatedAt: json["updated_at"] ?? '',
      createdAt: json["created_at"] ?? '',
      id: json["id"]?.toString() ?? '',
      accommodation: AccommodationInfo.fromJson(
          Map<String, dynamic>.from(json["accommodation"] ?? {})),
    );
  }

  Map<String, dynamic> toJson() => {
    "hotel_id": hotelId,
    "accommodation_id": accommodationId,
    "marchi_id": marchiId,
    "updated_at": updatedAt,
    "created_at": createdAt,
    "id": id,
    "accommodation": accommodation.toJson(),
  };
}

class AccommodationInfo {
  final String name;
  final String? nameZh;
  final String? nameKo;
  final String? nameJa;
  final String description;
  final String? descriptionZh;
  final String? descriptionKo;
  final String? descriptionJa;
  final String status;
  final String? nameAr;
  final String? nameEn;
  final String? descriptionAr;
  final String? descriptionEn;
  final String id;

  AccommodationInfo({
    required this.name,
    this.nameZh,
    this.nameKo,
    this.nameJa,
    required this.description,
    this.descriptionZh,
    this.descriptionKo,
    this.descriptionJa,
    required this.status,
    this.nameAr,
    this.nameEn,
    this.descriptionAr,
    this.descriptionEn,
    required this.id,
  });

  factory AccommodationInfo.fromJson(Map<String, dynamic> json) {
    return AccommodationInfo(
      name: json["name"] ?? '',
      nameZh: json["name_zh"],
      nameKo: json["name_ko"],
      nameJa: json["name_ja"],
      description: json["description"] ?? '',
      descriptionZh: json["description_zh"],
      descriptionKo: json["description_ko"],
      descriptionJa: json["description_ja"],
      status: json["status"] ?? '',
      nameAr: json["name_ar"],
      nameEn: json["name_en"],
      descriptionAr: json["description_ar"],
      descriptionEn: json["description_en"],
      id: json["id"]?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    "name": name,
    "name_zh": nameZh,
    "name_ko": nameKo,
    "name_ja": nameJa,
    "description": description,
    "description_zh": descriptionZh,
    "description_ko": descriptionKo,
    "description_ja": descriptionJa,
    "status": status,
    "name_ar": nameAr,
    "name_en": nameEn,
    "description_ar": descriptionAr,
    "description_en": descriptionEn,
    "id": id,
  };

}
