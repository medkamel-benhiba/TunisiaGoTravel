import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

Future<List<LatLng>> getRoute(LatLng start, LatLng end) async {
  // Replace with your actual OpenRouteService API key
  const apiKey = 'eyJvcmciOiI1YjNjZTM1OTc4NTExMTAwMDFjZjYyNDgiLCJpZCI6ImE1M2RhOGQ5Y2FmYzQ4MTA4YmE4NjBjNTUxOWY4NGQ4IiwiaCI6Im11cm11cjY0In0='; // ⚠️ REPLACE THIS

  final url = Uri.parse(
      'https://api.openrouteservice.org/v2/directions/driving-car?api_key=$apiKey&start=${start.longitude},${start.latitude}&end=${end.longitude},${end.latitude}');

  try {
    print('Fetching route from ${start.latitude},${start.longitude} to ${end.latitude},${end.longitude}');

    final response = await http.get(url);

    print('Response status: ${response.statusCode}');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      if (data['features'] != null && data['features'].isNotEmpty) {
        final coords = data['features'][0]['geometry']['coordinates'] as List;
        final routePoints = coords.map((c) => LatLng(c[1], c[0])).toList();

        print('Route found with ${routePoints.length} points');
        return routePoints;
      } else {
        print('No route found in response');
        return [];
      }
    } else {
      print('Error response: ${response.body}');
      return [];
    }
  } catch (e) {
    print('Error fetching route: $e');
    return [];
  }
}