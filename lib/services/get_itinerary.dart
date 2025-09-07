import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

Future<List<LatLng>> getRoute(LatLng start, LatLng end) async {
  final apiKey = 'VOTRE_API_KEY_ORS';
  final url = Uri.parse(
      'https://api.openrouteservice.org/v2/directions/driving-car?api_key=$apiKey&start=${start.longitude},${start.latitude}&end=${end.longitude},${end.latitude}');

  final response = await http.get(url);
  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    final coords = data['features'][0]['geometry']['coordinates'] as List;
    return coords.map((c) => LatLng(c[1], c[0])).toList();
  }
  return [];
}
