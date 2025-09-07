
class Restaurant {
  final String id;
  final String name;
  final String? slug;
  final String? crtDescription;
  final String? address;
  final String? destinationId;
  final String? destinationName;
  final String? cityId;
  final String? ville;
  final String? cover;
  final String? vignette;
  final List<String> images;
  final String? lat;
  final String? lng;
  final dynamic rate;
  final dynamic startingPrice;
  final Map<String, String?> openingHours;
  final String? phone;
  final String? email;
  final String? website;
  final String? videoLink;
  final bool isSpecial;
  final bool reservable;
  final String? status;

  // English fields
  final String? nameEn;
  final String? crtDescriptionEn;
  final String? addressEn;

  // Arabic fields
  final String? nameAr;
  final String? crtDescriptionAr;
  final String? addressAr;

  // SEO related fields could be a separate class if very complex
  // For simplicity, including a few meta titles as examples
  final String? metaTitle;
  final String? metaTitleEn;
  final String? metaTitleAr;


  Restaurant({
    required this.id,
    required this.name,
    this.slug,
    this.crtDescription,
    this.address,
    this.destinationId,
    this.destinationName,
    this.cityId,
    this.ville,
    this.cover,
    this.vignette,
    required this.images,
    this.lat,
    this.lng,
    this.rate,
    this.startingPrice,
    required this.openingHours,
    this.phone,
    this.email,
    this.website,
    this.videoLink,
    required this.isSpecial,
    required this.reservable,
    this.status,
    this.nameEn,
    this.crtDescriptionEn,
    this.addressEn,
    this.nameAr,
    this.crtDescriptionAr,
    this.addressAr,
    this.metaTitle,
    this.metaTitleEn,
    this.metaTitleAr,
  });

  factory Restaurant.fromJson(Map<String, dynamic> json) {
    // Helper to safely parse double
    double? _parseDouble(dynamic value) {
      if (value is String) {
        return double.tryParse(value);
      } else if (value is num) {
        return value.toDouble();
      }
      return null;
    }

    Map<String, String?> oh = {};
    if (json['opening_hours'] is Map) {
      (json['opening_hours'] as Map).forEach((key, value) {
        oh[key.toString()] = value?.toString();
      });
    }

    List<String> imageList = [];
    if (json['images'] is List) {
      imageList = List<String>.from(json['images'].map((img) => img.toString()));
    }

    String? destName;
    if (json['destination'] is Map && json['destination']['name'] != null) {
      destName = json['destination']['name'] as String?;
    }

    return Restaurant(
      id: json['id'] as String? ?? '', // ID should ideally always be present
      name: json['name'] as String? ?? 'Unnamed Restaurant',
      slug: json['slug'] as String?,
      crtDescription: json['crt_description'] as String?,
      address: json['address'] as String?,
      destinationId: json['destination_id'] as String?,
      destinationName: destName,
      cityId: json['city_id'] as String?,
      ville: json['ville'] as String?,
      cover: json['cover'] as String?,
      vignette: json['vignette'] as String?,
      images: imageList,
      lat: json['lat'] as String?,
      lng: json['lng'] as String?,
      rate: json['rate'], // Keep as dynamic or parse to double/int as needed
      startingPrice: json['starting_price'], // Keep as dynamic or parse
      openingHours: oh,
      phone: json['phone'] as String?,
      email: json['email'] as String?,
      website: json['website'] as String?,
      videoLink: json['video_link'] as String?,
      isSpecial: (json['is_special'] == 'yes' || json['is_special'] == true),
      reservable: (json['reservable'] == 'yes' || json['reservable'] == true), // Assuming 'yes' or boolean
      status: json['status'] as String?,
      nameEn: json['name_en'] as String?,
      crtDescriptionEn: json['crt_description_en'] as String?,
      addressEn: json['address_en'] as String?,
      nameAr: json['name_ar'] as String?,
      crtDescriptionAr: json['crt_description_ar'] as String?,
      addressAr: json['address_ar'] as String?,
      metaTitle: (json['seo'] is Map && json['seo']['meta_title'] != null) ? json['seo']['meta_title'] as String? : null,
      metaTitleEn: (json['seo'] is Map && json['seo']['meta_title_en'] != null) ? json['seo']['meta_title_en'] as String? : null,
      metaTitleAr: (json['seo'] is Map && json['seo']['meta_title_ar'] != null) ? json['seo']['meta_title_ar'] as String? : null,
    );
  }

  // For debugging purposes
  @override
  String toString() {
    return 'Restaurant(id: $id, name: $name, destinationId: $destinationId)';
  }
}
