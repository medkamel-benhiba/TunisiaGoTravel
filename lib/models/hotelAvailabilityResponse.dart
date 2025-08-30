import 'dart:convert';

HotelAvailabilityResponse hotelAvailabilityResponseFromJson(String str) =>
    HotelAvailabilityResponse.fromJson(json.decode(str));

String hotelAvailabilityResponseToJson(HotelAvailabilityResponse data) =>
    json.encode(data.toJson());

class HotelAvailabilityResponse {
  final int currentPage;
  final List<HotelData> data;
  final int lastPage;
  final String? nextPageUrl;

  HotelAvailabilityResponse({
    required this.currentPage,
    required this.data,
    required this.lastPage,
    required this.nextPageUrl,
  });

  factory HotelAvailabilityResponse.fromJson(Map<String, dynamic> json) =>
      HotelAvailabilityResponse(
        currentPage: json["current_page"] ?? 1,
        data: json["data"] == null
            ? []
            : List<HotelData>.from(
            json["data"].map((x) => HotelData.fromJson(x))),
        lastPage: json["last_page"] ?? 1,
        nextPageUrl: json["next_page_url"],
      );

  Map<String, dynamic> toJson() => {
    "current_page": currentPage,
    "data": List<dynamic>.from(data.map((x) => x.toJson())),
    "last_page": lastPage,
    "next_page_url": nextPageUrl,
  };
}

class HotelData {
  final String id;
  final String name;
  final String slug;
  final String? idCityBbx;
  final String? idHotelBbx;
  final Disponibility disponibility;

  HotelData({
    required this.id,
    required this.name,
    required this.slug,
    this.idCityBbx,
    this.idHotelBbx,
    required this.disponibility,
  });

  factory HotelData.fromJson(Map<String, dynamic> json) {
    // Debug for empty/invalid disponibility
    if (json["disponibility"] is! Map<String, dynamic>) {
      print("Hotel ${json['name']} has empty or invalid disponibility");
    }

    return HotelData(
      id: json["id"],
      name: json["name"],
      slug: json["slug"],
      idCityBbx: json["id_city_bbx"],
      idHotelBbx: json["id_hotel_bbx"],
      disponibility: (json["disponibility"] is Map<String, dynamic>)
          ? Disponibility.fromJson(json["disponibility"])
          : Disponibility.empty(), // fallback if [] or null
    );
  }
  factory HotelData.empty() => HotelData(
    id: '',
    name: '',
    slug: '',
    disponibility: Disponibility.empty(),
  );



  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "slug": slug,
    "id_city_bbx": idCityBbx,
    "id_hotel_bbx": idHotelBbx,
    "disponibility": disponibility.toJson(),
  };
}

class Disponibility {
  final String disponibilityType;
  final List<dynamic> pensions;

  Disponibility({
    required this.disponibilityType,
    required this.pensions,
  });

  factory Disponibility.fromJson(Map<String, dynamic> json) {
    dynamic pensionsData = json["pensions"] ?? [];

    List<dynamic> pensionsList;
    if (pensionsData is List) {
      pensionsList = pensionsData;
    } else if (pensionsData is Map) {
      pensionsList = [pensionsData];
    } else {
      pensionsList = [];
    }

    return Disponibility(
      disponibilityType: json["disponibilitytype"] ?? "",
      pensions: pensionsList,
    );
  }


  factory Disponibility.empty() =>
      Disponibility(disponibilityType: "", pensions: []);

  Map<String, dynamic> toJson() => {
    "disponibilitytype": disponibilityType,
    "pensions": pensions,
  };
}
