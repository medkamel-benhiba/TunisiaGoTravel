import 'package:flutter/material.dart';

class HotelBhr {
  final String id;
  final String? id_hotel_bbx;
  final String name;
  final String? name_en;
  final String? name_ar;
  final String? name_ru;
  final String? name_ja;
  final String? name_ko;
  final String? name_zh;

  final String slug;
  final String disponibilityType;
  final DisponibilityBhr disponibility;

  HotelBhr({
    required this.id,
    this.id_hotel_bbx,
    required this.name,
    required this.slug,
    required this.disponibilityType,
    required this.disponibility,
    this.name_en,
    this.name_ar,
    this.name_ru,
    this.name_ja,
    this.name_ko,
    this.name_zh,

  });

  factory HotelBhr.fromJson(Map<String, dynamic> json) {
    return HotelBhr(
      id: json['id'] ?? '',
      id_hotel_bbx: json['id_hotel_bbx'] ?? '',
      name: json['name'] ?? '',
      slug: json['slug'] ?? '',
      disponibilityType: json['disponibility']?['disponibilitytype'] ?? '',
      disponibility: DisponibilityBhr.fromJson(
        Map<String, dynamic>.from(json['disponibility']?['pensions'] ?? {}),
      ),
      name_en: json['name_en'] ?? '',
      name_ar: json['name_ar'] ?? '',
      name_ru: json['name_ru'] ?? '',
      name_ko: json['name_ko'] ?? '',
      name_ja: json['name_ja'] ?? '',
      name_zh: json['name_zh'] ?? '',
    );
  }

  // NEW: Factory method for availability API response
  factory HotelBhr.fromAvailabilityJson(
      Map<String, dynamic> json,
      dynamic hotelDetail, {
        String? idHotelBbx,
      }) {
    // --- Extract hotel info from hotelDetail ---
    String hotelId = '';
    String hotelName = '';
    String hotelSlug = '';

    if (hotelDetail != null) {
      if (hotelDetail is Map<String, dynamic>) {
        hotelId = hotelDetail['id']?.toString() ?? '';
        hotelName = hotelDetail['name']?.toString() ?? '';
        hotelSlug = hotelDetail['slug']?.toString() ?? '';
      } else {
        try {
          // If hotelDetail is an object with properties
          hotelId = hotelDetail.id?.toString() ?? '';
          hotelName = hotelDetail.name?.toString() ?? '';
          hotelSlug = hotelDetail.slug?.toString() ?? '';
        } catch (_) {
          hotelId = '';
          hotelName = '';
          hotelSlug = '';
        }
      }
    }

    // --- Parse disponibility ---
    DisponibilityBhr disponibility;

    if (json.containsKey('rooms') && json['rooms'] != null) {
      // Case: direct rooms array
      disponibility = DisponibilityBhr(
        id: hotelId,
        title: hotelName,
        category: json['category']?.toString() ?? '',
        summary: json['summary']?.toString() ?? '',
        address: json['address']?.toString() ?? '',
        promotionDateTime: json['promotionDateTime']?.toString() ?? '',
        rooms: (json['rooms'] as List<dynamic>)
            .map((r) => RoomBhr.fromJson(Map<String, dynamic>.from(r)))
            .toList(),
      );
    } else if (json.containsKey('pensions') && json['pensions'] != null) {
      // Case: pensions structure
      final pensionsData = json['pensions'];
      if (pensionsData is Map) {
        disponibility = DisponibilityBhr.fromJson(Map<String, dynamic>.from(pensionsData));
      } else {
        disponibility = DisponibilityBhr(
          id: hotelId,
          title: hotelName,
          category: '',
          summary: '',
          address: '',
          promotionDateTime: '',
          rooms: [],
        );
      }
    } else {
      // Default empty disponibility
      disponibility = DisponibilityBhr(
        id: hotelId,
        title: hotelName,
        category: '',
        summary: '',
        address: '',
        promotionDateTime: '',
        rooms: [],
      );
    }

    // --- Return HotelBhr instance ---
    return HotelBhr(
      id: hotelId,
      id_hotel_bbx: idHotelBbx ?? json['id_hotel_bbx']?.toString(),
      name: hotelName,
      slug: hotelSlug,
      disponibilityType: json['disponibilitytype']?.toString() ?? 'bhr',
      disponibility: disponibility,
    );
  }
  String getName(Locale locale) {
    switch (locale.languageCode) {
      case 'ar':
        return (name_ar != null && name_ar!.isNotEmpty) ? name_ar! : name;
      case 'en':
        return (name_en != null && name_en!.isNotEmpty) ? name_en! : name;
      case 'ru':
        return (name_ru != null && name_ru!.isNotEmpty) ? name_ru! : name;
      case 'ko':
        return (name_ko != null && name_ko!.isNotEmpty) ? name_ko! : name;
      case 'zh':
        return (name_zh != null && name_zh!.isNotEmpty) ? name_zh! : name;
      case 'ja':
        return (name_ja != null && name_ja!.isNotEmpty) ? name_ja! : name;
      default:
        return name;
    }
  }


}


class DisponibilityBhr {
  final String id;
  final String title;
  final String category;
  final String summary;
  final String address;
  final String promotionDateTime;
  final List<RoomBhr> rooms;

  DisponibilityBhr({
    required this.id,
    required this.title,
    required this.category,
    required this.summary,
    required this.address,
    required this.promotionDateTime,
    required this.rooms,
  });

  factory DisponibilityBhr.fromJson(Map<String, dynamic> json) {
    final roomsJson = json['rooms']?['room'];
    List<RoomBhr> parsedRooms = [];

    if (roomsJson != null) {
      if (roomsJson is List) {
        parsedRooms = roomsJson
            .map((r) => RoomBhr.fromJson(Map<String, dynamic>.from(r)))
            .toList();
      } else if (roomsJson is Map) {
        parsedRooms = [RoomBhr.fromJson(Map<String, dynamic>.from(roomsJson))];
      }
    }

    return DisponibilityBhr(
      id: json['@attributes']?['id'] ?? '',
      title: json['Title'] ?? '',
      category: json['Category'] ?? '',
      summary: json['Summary'] ?? '',
      address: json['Address'] ?? '',
      promotionDateTime: json['PromotionDateTime'] ?? '',
      rooms: parsedRooms,
    );
  }

}

class RoomBhr {
  final String id;
  final String title;
  final int adults;
  final int children;
  final int infants;
  final int availableQuantity;
  final List<BoardingBhr> boardings;

  RoomBhr({
    required this.id,
    required this.title,
    required this.adults,
    required this.children,
    required this.infants,
    required this.availableQuantity,
    required this.boardings,
  });

  factory RoomBhr.fromJson(Map<String, dynamic> json) {
    final boardingJson = json['Boardings']?['Boarding'];
    List<BoardingBhr> parsedBoardings = [];

    if (boardingJson != null) {
      if (boardingJson is List) {
        parsedBoardings = boardingJson
            .map((b) => BoardingBhr.fromJson(Map<String, dynamic>.from(b)))
            .toList();
      } else if (boardingJson is Map) {
        parsedBoardings = [BoardingBhr.fromJson(Map<String, dynamic>.from(boardingJson))];
      }
    }


    return RoomBhr(
      id: json['@attributes']?['id'] ?? '',
      title: json['Title'] ?? '',
      adults: int.tryParse(json['Adult']?.trim() ?? '0') ?? 0,
      children: int.tryParse(json['Child']?.trim() ?? '0') ?? 0,
      infants: int.tryParse(json['Infant']?.trim() ?? '0') ?? 0,
      availableQuantity: int.tryParse(json['AvailableQuantity'] ?? '0') ?? 0,
      boardings: parsedBoardings,
    );
  }
}

class BoardingBhr {
  final String id;
  final String title;
  final String available;
  final double rate;
  final double rateWithoutPromotion;
  final bool nonRefundable;
  final CancellationPolicy cancellationPolicy;

  BoardingBhr({
    required this.id,
    required this.title,
    required this.available,
    required this.rate,
    required this.rateWithoutPromotion,
    required this.nonRefundable,
    required this.cancellationPolicy,
  });

  factory BoardingBhr.fromJson(Map<String, dynamic> json) {
    return BoardingBhr(
      id: json['@attributes']?['id'] ?? '',
      title: json['Title'] ?? '',
      available: json['Available'] ?? '',
      rate: double.tryParse(json['Rate'] ?? '0') ?? 0,
      rateWithoutPromotion: double.tryParse(json['RateWithoutPromotion'] ?? '0') ?? 0,
      nonRefundable: json['NonRefundable']?.toString().toLowerCase() == 'true',
      cancellationPolicy: CancellationPolicy.fromJson(json['CancellationPolicy']),
    );
  }
}

class CancellationPolicy {
  final String fromDate;
  final double fee;

  CancellationPolicy({
    required this.fromDate,
    required this.fee,
  });

  factory CancellationPolicy.fromJson(Map<String, dynamic> json) {
    return CancellationPolicy(
      fromDate: json['FromDate'] ?? '',
      fee: double.tryParse(json['Fee'] ?? '0') ?? 0,
    );
  }
}
