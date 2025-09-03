class Hotel {
  final String id;
  final String id_hotel_bbx;
  final String name;
  final String address;
  final String cover;
  final bool reservable;
  final String slug;
  final String destinationId;
  final int? categoryCode;
  final String? destinationName;
  final String? shortDescription;

  final String? idCityMouradi;
  final String? idHotelMouradi;
  final String? idHotelBhr;


  Hotel({
    required this.id,
    required this.id_hotel_bbx,
    required this.name,
    required this.address,
    required this.cover,
    required this.reservable,
    required this.slug,
    required this.destinationId,
    this.categoryCode,
    this.destinationName,
    this.shortDescription,
    this.idCityMouradi,
    this.idHotelMouradi,
    this.idHotelBhr
  });

  factory Hotel.fromJson(Map<String, dynamic> json) {
    String? desc = json['description'] ?? '';

    return Hotel(
      id: json['id'] ?? '',
      id_hotel_bbx: json['id_hotel_bbx'] ?? '',
      name: json['name'] ?? '',
      address: json['address'] ?? '',
      cover: json['cover'] ?? '',
      reservable: json['reservable'] ?? false,
      slug: json['slug'] ?? '',
      destinationId: json['destination_id'] ?? '',
      categoryCode: json['category_code'] != null
          ? int.tryParse(json['category_code'].toString())
          : null,
      destinationName: json['destination']?['name'] ?? json['ville'] ?? '',
      shortDescription: desc,
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
      'short_description': shortDescription,
    };
  }
}
