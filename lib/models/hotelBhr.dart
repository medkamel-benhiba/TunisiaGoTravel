class HotelBhr {
  final String id;
  final String name;
  final String slug;
  final String disponibilityType;
  final DisponibilityBhr disponibility;

  HotelBhr({
    required this.id,
    required this.name,
    required this.slug,
    required this.disponibilityType,
    required this.disponibility,
  });

  factory HotelBhr.fromJson(Map<String, dynamic> json) {
    return HotelBhr(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      slug: json['slug'] ?? '',
      disponibilityType: json['disponibility']?['disponibilitytype'] ?? '',
      disponibility: DisponibilityBhr.fromJson(
        Map<String, dynamic>.from(json['disponibility']?['pensions'] ?? {}),
      ),
    );
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
