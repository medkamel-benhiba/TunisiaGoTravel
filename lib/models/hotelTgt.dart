class HotelTgt {
  final String id;
  final String name;
  final String slug;
  final String? idCityBbx;
  final String? idHotelBbx;
  final Disponibility disponibility;

  HotelTgt({
    required this.id,
    required this.name,
    required this.slug,
    this.idCityBbx,
    this.idHotelBbx,
    required this.disponibility,
  });

  factory HotelTgt.fromJson(Map<String, dynamic> json) {
    return HotelTgt(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      slug: json['slug'] ?? '',
      idCityBbx: json['id_city_bbx']?.toString(),
      idHotelBbx: json['id_hotel_bbx']?.toString(),
      disponibility: Disponibility.fromJson(json['disponibility'] ?? {}),
    );
  }
}

class Disponibility {
  final String disponibilitytype;
  final List<PensionTgt> pensions;

  Disponibility({
    required this.disponibilitytype,
    required this.pensions,
  });

  factory Disponibility.fromJson(Map<String, dynamic> json) {
    return Disponibility(
      disponibilitytype: json['disponibilitytype'] ?? '',
      pensions: (json['pensions'] as List<dynamic>?)
          ?.map((pension) => PensionTgt.fromJson(pension))
          .toList() ?? [],
    );
  }
}

class PensionTgt {
  final String id;
  final String name;
  final String? nameAr;
  final String? nameEn;
  final String devise;
  final String description;
  final String? descriptionAr;
  final String? descriptionEn;
  final List<RoomTgt> rooms;

  PensionTgt({
    required this.id,
    required this.name,
    this.nameAr,
    this.nameEn,
    required this.devise,
    required this.description,
    this.descriptionAr,
    this.descriptionEn,
    required this.rooms,
  });

  factory PensionTgt.fromJson(Map<String, dynamic> json) {
    return PensionTgt(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      nameAr: json['name_ar'],
      nameEn: json['name_en'],
      devise: json['devise'] ?? '',
      description: json['description'] ?? '',
      descriptionAr: json['description_ar'],
      descriptionEn: json['description_en'],
      rooms: (json['rooms'] as List<dynamic>?)
          ?.map((room) => RoomTgt.fromJson(room))
          .toList() ?? [],
    );
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
    return RoomTgt(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      capacity: (json['capacity'] as List<dynamic>?)
          ?.map((cap) => Capacity.fromJson(cap))
          .toList() ?? [],
      attributes: (json['attributes'] as List<dynamic>?)
          ?.map((attr) => attr.toString())
          .toList() ?? [],
      stillAvailable: json['still_available'] ?? 0,
      purchasePrice: (json['purchase_price'] as List<dynamic>?)
          ?.map((price) => PurchasePrice.fromJson(price))
          .toList() ?? [],
      conversionRates: json['conversion_rates'] != null
          ? Map<String, double>.from(json['conversion_rates'])
          : null,
    );
  }
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
      adults: json['adults'] ?? 0,
      children: json['children'] ?? 0,
      babies: json['babies'] ?? 0,
      maxBabiesAge: json['max_babies_age'],
    );
  }
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
    return PurchasePrice(
      id: json['id'] ?? '',
      roomId: json['room_id'] ?? '',
      accomodationId: json['accomodation_id'] ?? '',
      purchasePrice: (json['purchase_price'] ?? 0).toDouble(),
      commission: (json['commission'] ?? 0).toDouble(),
      dateStart: json['date_start'] ?? '',
      dateEnd: json['date_end'] ?? '',
      status: json['status'] ?? false,
      partners: (json['partners'] as List<dynamic>?)
          ?.map((partner) => Partner.fromJson(partner))
          .toList() ?? [],
      marchiId: json['marchi_id'] ?? '',
      currency: json['currency'] ?? '',
      conversionRates: json['conversion_rates'] != null
          ? Map<String, double>.from(json['conversion_rates'])
          : null,
      updatedAt: json['updated_at'] ?? '',
      createdAt: json['created_at'] ?? '',
      accommodation: json['accommodation'] != null
          ? AccommodationDetails.fromJson(json['accommodation'])
          : null,
    );
  }
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
      partnerId: json['partner_id'] ?? '',
      commission: (json['commission'] ?? 0).toDouble(),
      discount: (json['discount'] ?? 0).toDouble(),
    );
  }
}

class AccommodationDetails {
  final String id;
  final String hotelId;
  final String accommodationId;
  final String marchiId;
  final String updatedAt;
  final String createdAt;
  final AccommodationInfo? accommodation;

  AccommodationDetails({
    required this.id,
    required this.hotelId,
    required this.accommodationId,
    required this.marchiId,
    required this.updatedAt,
    required this.createdAt,
    this.accommodation,
  });

  factory AccommodationDetails.fromJson(Map<String, dynamic> json) {
    return AccommodationDetails(
      id: json['id'] ?? '',
      hotelId: json['hotel_id'] ?? '',
      accommodationId: json['accommodation_id'] ?? '',
      marchiId: json['marchi_id'] ?? '',
      updatedAt: json['updated_at'] ?? '',
      createdAt: json['created_at'] ?? '',
      accommodation: json['accommodation'] != null
          ? AccommodationInfo.fromJson(json['accommodation'])
          : null,
    );
  }
}

class AccommodationInfo {
  final String id;
  final String name;
  final String? nameZh;
  final String? nameKo;
  final String? nameJa;
  final String? nameAr;
  final String? nameEn;
  final String description;
  final String? descriptionZh;
  final String? descriptionKo;
  final String? descriptionJa;
  final String? descriptionAr;
  final String? descriptionEn;
  final String status;

  AccommodationInfo({
    required this.id,
    required this.name,
    this.nameZh,
    this.nameKo,
    this.nameJa,
    this.nameAr,
    this.nameEn,
    required this.description,
    this.descriptionZh,
    this.descriptionKo,
    this.descriptionJa,
    this.descriptionAr,
    this.descriptionEn,
    required this.status,
  });

  factory AccommodationInfo.fromJson(Map<String, dynamic> json) {
    return AccommodationInfo(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      nameZh: json['name_zh'],
      nameKo: json['name_ko'],
      nameJa: json['name_ja'],
      nameAr: json['name_ar'],
      nameEn: json['name_en'],
      description: json['description'] ?? '',
      descriptionZh: json['description_zh'],
      descriptionKo: json['description_ko'],
      descriptionJa: json['description_ja'],
      descriptionAr: json['description_ar'],
      descriptionEn: json['description_en'],
      status: json['status'] ?? '',
    );
  }
}