import 'package:latlong2/latlong.dart';

class NavigationStep {
  final LatLng point;
  final String instruction;
  final double distance;
  final String type;

  NavigationStep({
    required this.point,
    required this.instruction,
    required this.distance,
    required this.type,
  });

  Map<String, dynamic> toJson() => {
    'point': {'lat': point.latitude, 'lng': point.longitude},
    'instruction': instruction,
    'distance': distance,
    'type': type,
  };

  factory NavigationStep.fromJson(Map<String, dynamic> json) {
    return NavigationStep(
      point: LatLng(json['point']['lat'], json['point']['lng']),
      instruction: json['instruction'],
      distance: json['distance'].toDouble(),
      type: json['type'],
    );
  }
}