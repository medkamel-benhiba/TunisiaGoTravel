import 'package:flutter/material.dart';

class Agil {
  final String id;
  final String gouverneurat;
  final String? gouverneuratAr;
  final String? gouverneuratEn;
  final String? gouverneuratJa;
  final String? gouverneuratRu;
  final String? gouverneuratZh;
  final String? gouverneuratKo;


  final String ville;
  final String? villeAr;
  final String? villeEn;
  final String? villeJa;
  final String? villeRu;
  final String? villeZh;
  final String? villeKo;

  final String adresse;
  final String? adresseAr;
  final String? adresseEn;
  final String? adresseJa;
  final String? adresseRu;
  final String? adresseZh;
  final String? adresseKo;

  final double latitude;
  final double longitude;

  Agil({
    required this.id,
    required this.gouverneurat,
    required this.ville,
    required this.adresse,
    required this.latitude,
    required this.longitude,
    this.gouverneuratAr,
    this.villeAr,
    this.adresseAr,
    this.gouverneuratEn,
    this.villeEn,
    this.adresseEn,
    this.gouverneuratJa,
    this.villeJa,
    this.adresseJa,
    this.gouverneuratRu,
    this.villeRu,
    this.adresseRu,
    this.gouverneuratZh,
    this.villeZh,
    this.adresseZh,
    this.gouverneuratKo,
    this.villeKo,
    this.adresseKo,

  });

  factory Agil.fromJson(Map<String, dynamic> json) {
    return Agil(
      id: json['id'] ?? '',
      gouverneurat: json['gouverneurat'] ?? '',
      ville: json['ville'] ?? '',
      adresse: json['Adresse'] ?? '',
      latitude: (json['latitude'] ?? 0).toDouble(),
      longitude: (json['longitude'] ?? 0).toDouble(),
      gouverneuratAr: json['gouverneuratAr'] ?? '',
      villeAr: json['villeAr'] ?? '',
      adresseAr: json['adresseAr'] ?? '',
      gouverneuratEn: json['gouverneuratEn'] ?? '',
      villeEn: json['villeEn'] ?? '',
      adresseEn: json['adresseEn'] ?? '',
      gouverneuratJa: json['gouverneuratJa'] ?? '',
      villeJa: json['villeJa'] ?? '',
      adresseJa: json['adresseJa'] ?? '',
      gouverneuratRu: json['gouverneuratRu'] ?? '',
      villeRu: json['villeRu'] ?? '',
      adresseRu: json['adresseRu'] ?? '',
      gouverneuratZh: json['gouverneuratZh'] ?? '',
      villeZh: json['villeZh'] ?? '',
      adresseZh: json['adresseZh'] ?? '',
      gouverneuratKo: json['gouverneuratKo'] ?? '',
      villeKo: json['villeKo'] ?? '',
      adresseKo: json['adresseKo'] ?? '',

    );
  }
  String getGouverneurat(Locale Locale) {
    switch (Locale.languageCode) {
      case 'ar':
        return this.gouverneuratAr ?? this.gouverneurat;
      case 'en':
        return this.gouverneuratEn ?? this.gouverneurat;
      case 'ja':
        return this.gouverneuratJa ?? this.gouverneurat;
      case 'ru':
        return this.gouverneuratRu ?? this.gouverneurat;
      case 'zh':
        return this.gouverneuratZh ?? this.gouverneurat;
      case 'ko':
        return this.gouverneuratKo ?? this.gouverneurat;
      default:
        return this.gouverneurat;
    }
  }

  String getVille(Locale Locale) {
    switch (Locale.languageCode) {
      case 'ar':
        return this.villeAr ?? this.ville;
      case 'en':
        return this.villeEn ?? this.ville;
      case 'ja':
        return this.villeJa ?? this.ville;
      case 'ru':
        return this.villeRu ?? this.ville;
      case 'zh':
        return this.villeZh ?? this.ville;
      case 'ko':
        return this.villeKo ?? this.ville;
      default:
        return this.ville;
    }
  }
  String getAdresse(Locale Locale) {
    switch (Locale.languageCode) {
      case 'ar':
        return this.adresseAr ?? this.adresse;
      case 'en':
        return this.adresseEn ?? this.adresse;
      case 'ja':
        return this.adresseJa ?? this.adresse;
      case 'ru':
        return this.adresseRu ?? this.adresse;
      case 'zh':
        return this.adresseZh ?? this.adresse;
      case 'ko':
        return this.adresseKo ?? this.adresse;
      default:
        return this.adresse;
    }
  }
}
