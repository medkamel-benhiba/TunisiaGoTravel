class Agil {
  final String id;
  final String gouverneurat;
  final String ville;
  final String adresse;
  final double latitude;
  final double longitude;

  Agil({
    required this.id,
    required this.gouverneurat,
    required this.ville,
    required this.adresse,
    required this.latitude,
    required this.longitude,
  });

  factory Agil.fromJson(Map<String, dynamic> json) {
    return Agil(
      id: json['id'] ?? '',
      gouverneurat: json['gouverneurat'] ?? '',
      ville: json['ville'] ?? '',
      adresse: json['Adresse'] ?? '',
      latitude: (json['latitude'] ?? 0).toDouble(),
      longitude: (json['longitude'] ?? 0).toDouble(),
    );
  }
}
