class MouradiHotel {
  final int id;
  final String name;
  final String category;
  final int star;
  final String cityName;
  final int cityId;
  final String description;
  final String address;
  final String image;
  final List<BoardingOption> boardings;
  final String currency;
  final double basePrice;

  MouradiHotel({
    required this.id,
    required this.cityId,
    required this.name,
    required this.category,
    required this.star,
    required this.cityName,
    required this.description,
    required this.address,
    required this.image,
    required this.boardings,
    required this.currency,
    required this.basePrice,
  });

  factory MouradiHotel.fromJson(Map<String, dynamic> json) {
    final hotel = json['Hotel'];
    final price = json['Price'] ?? {};
    final currency = json['Currency']?.toString() ?? 'TND';
    final basePrice =
        double.tryParse((price['BasePrice'] ?? '0').toString()) ?? 0;

    List<BoardingOption> boardings = [];
    if (price['Boarding'] != null) {
      boardings = (price['Boarding'] as List)
          .map((b) => BoardingOption.fromJson(b))
          .toList();
    }

    return MouradiHotel(
      id: _parseInt(hotel['Id']),
      name: hotel['Name']?.toString() ?? '',
      category: hotel['Category']?['Title']?.toString() ?? '',
      star: _parseInt(hotel['Category']?['Star']),
      cityName: hotel['City']?['Name']?.toString() ?? '',
      cityId: _parseInt(hotel['City']?['Id']),
      description: hotel['HotelDescription']?.toString() ?? '',
      address: hotel['Adress']?.toString() ?? '',
      image: hotel['Image']?.toString() ?? '',
      boardings: boardings,
      currency: currency,
      basePrice: basePrice,
    );
  }
}

class BoardingOption {
  final int id;
  final String code;
  final String name;
  final List<Pax> pax;

  BoardingOption({
    required this.id,
    required this.code,
    required this.name,
    required this.pax,
  });

  factory BoardingOption.fromJson(Map<String, dynamic> json) {
    final paxList = (json['Pax'] as List?)
        ?.map((p) => Pax.fromJson(p))
        .toList() ??
        [];
    return BoardingOption(
      id: _parseInt(json['Id']),
      code: json['Code']?.toString() ?? '',
      name: json['Name']?.toString() ?? '',
      pax: paxList,
    );
  }
}

class Pax {
  final int adults;
  final List<Room> rooms;

  Pax({required this.adults, required this.rooms});

  factory Pax.fromJson(Map<String, dynamic> json) {
    final rooms = (json['Rooms'] as List?)
        ?.map((r) => Room.fromJson(r))
        .toList() ??
        [];
    return Pax(
      adults: _parseInt(json['Adult']),
      rooms: rooms,
    );
  }
}

class Room {
  final int id;
  final String name;
  final int quantity;
  final double price;
  final double basePrice;
  final List<CancellationPolicy> cancellationPolicy;

  Room({
    required this.id,
    required this.name,
    required this.quantity,
    required this.price,
    required this.basePrice,
    required this.cancellationPolicy,
  });

  factory Room.fromJson(Map<String, dynamic> json) {
    final policies = (json['CancellationPolicy'] as List?)
        ?.map((p) => CancellationPolicy.fromJson(p))
        .toList() ??
        [];
    return Room(
      id: _parseInt(json['Id']),
      name: json['Name']?.toString() ?? '',
      quantity: _parseInt(json['Quantity']),
      price: _parseDouble(json['Price']),
      basePrice: _parseDouble(json['BasePrice']),
      cancellationPolicy: policies,
    );
  }
}

class CancellationPolicy {
  final double fees;
  final String type;
  final String nature;
  final String? fromDate;

  CancellationPolicy({
    required this.fees,
    required this.type,
    required this.nature,
    this.fromDate,
  });

  factory CancellationPolicy.fromJson(Map<String, dynamic> json) {
    return CancellationPolicy(
      fees: _parseDouble(json['Fees']),
      type: json['Type']?.toString() ?? '',
      nature: json['Nature']?.toString() ?? '',
      fromDate: json['FromDate']?.toString(),
    );
  }
}

// ======= Helper parsing functions =======
int _parseInt(dynamic value) {
  if (value == null) return 0;
  if (value is int) return value;
  return int.tryParse(value.toString()) ?? 0;
}

double _parseDouble(dynamic value) {
  if (value == null) return 0.0;
  if (value is double) return value;
  if (value is int) return value.toDouble();
  return double.tryParse(value.toString()) ?? 0.0;
}
