import 'dart:convert';
import 'destination.dart';

class Monument {
  final String id;
  final String name;
  final String description;
  final String categories;
  final double lat;
  final double lng;
  final List<String> images;
  final String cover;
  final String vignette;
  final String slug;
  final Destination destination;

  Monument({
    required this.id,
    required this.name,
    required this.description,
    required this.categories,
    required this.lat,
    required this.lng,
    required this.images,
    required this.cover,
    required this.vignette,
    required this.slug,
    required this.destination,
  });

  factory Monument.fromJson(Map<String, dynamic> json) {
    return Monument(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      categories: json['categories'] ?? '',
      lat: double.tryParse(json['lat']?.toString() ?? '0') ?? 0.0,
      lng: double.tryParse(json['lng']?.toString() ?? '0') ?? 0.0,
      images: List<String>.from(json['images'] ?? []),
      cover: json['cover'] ?? '',
      vignette: json['vignette'] ?? '',
      slug: json['slug'] ?? '',
      destination: Destination.fromJson(json['destination'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'categories': categories,
      'lat': lat,
      'lng': lng,
      'images': images,
      'cover': cover,
      'vignette': vignette,
      'slug': slug,
      'destination': destination,
    };
  }
}

List<Monument> parseMonuments(String responseBody) {
  try {
    final Map<String, dynamic> parsed = json.decode(responseBody);
    final List<dynamic> data = parsed['monument']?['data'] ?? [];
    return data.map((json) => Monument.fromJson(json)).toList();
  } catch (e) {
    print('Error parsing monuments: $e');
    return [];
  }
}
