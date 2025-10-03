import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:tunisiagotravel/models/navigation_step.dart';



Future<List<LatLng>> getRoute(LatLng start, LatLng end) async {
  const apiKey = 'eyJvcmciOiI1YjNjZTM1OTc4NTExMTAwMDFjZjYyNDgiLCJpZCI6ImE1M2RhOGQ5Y2FmYzQ4MTA4YmE4NjBjNTUxOWY4NGQ4IiwiaCI6Im11cm11cjY0In0=';

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

Future<Map<String, dynamic>> getRouteWithInstructions(LatLng start, LatLng end) async {
  const apiKey = 'eyJvcmciOiI1YjNjZTM1OTc4NTExMTAwMDFjZjYyNDgiLCJpZCI6ImE1M2RhOGQ5Y2FmYzQ4MTA4YmE4NjBjNTUxOWY4NGQ4IiwiaCI6Im11cm11cjY0In0=';

  // Build URL with instructions and geometry parameters
  final url = Uri.parse(
      'https://api.openrouteservice.org/v2/directions/driving-car?api_key=$apiKey&start=${start.longitude},${start.latitude}&end=${end.longitude},${end.latitude}&instructions=true&geometry=true');

  try {
    print('Fetching route with instructions from ${start.latitude},${start.longitude} to ${end.latitude},${end.longitude}');
    print('URL: $url');

    final response = await http.get(url);

    print('Response status: ${response.statusCode}');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print('Full response: ${jsonEncode(data)}');

      if (data['features'] != null && data['features'].isNotEmpty) {
        final feature = data['features'][0];

        // Extract route coordinates
        final coords = feature['geometry']['coordinates'] as List;
        final routePoints = coords.map((c) => LatLng(c[1], c[0])).toList();
        print('Extracted ${routePoints.length} route points');

        // Extract turn-by-turn instructions
        List<NavigationStep> steps = [];

        if (feature['properties'] != null && feature['properties']['segments'] != null) {
          final segments = feature['properties']['segments'] as List;
          print('Found ${segments.length} segments');

          for (var segment in segments) {
            if (segment['steps'] != null) {
              final stepsList = segment['steps'] as List;
              print('Found ${stepsList.length} steps in segment');

              for (var step in stepsList) {
                final instruction = step['instruction'] ?? 'Continue';
                final distance = (step['distance'] ?? 0.0) / 1000.0; // Convert to km
                final wayPoints = step['way_points'] as List? ?? [];
                final type = step['type'] ?? 0;

                print('Step: $instruction, distance: $distance km, waypoints: $wayPoints, type: $type');

                // Get the coordinate for this step
                LatLng stepPoint;
                if (wayPoints.isNotEmpty && wayPoints[0] < routePoints.length) {
                  stepPoint = routePoints[wayPoints[0]];
                } else if (routePoints.isNotEmpty) {
                  stepPoint = routePoints.first;
                } else {
                  continue;
                }

                // Determine turn type from instruction and type code
                String turnType = 'straight';
                final instructionLower = instruction.toLowerCase();

                // OpenRouteService turn type codes:
                // 0: left, 1: right, 2: sharp left, 3: sharp right, 4: slight left, 5: slight right
                // 6: straight, 7: enter roundabout, 8: exit roundabout, 9: u-turn, 10: goal, 11: depart, 12: keep left, 13: keep right
                if (type == 0 || type == 2 || type == 4 || type == 12 || instructionLower.contains('left')) {
                  turnType = 'left';
                } else if (type == 1 || type == 3 || type == 5 || type == 13 || instructionLower.contains('right')) {
                  turnType = 'right';
                } else if (type == 10 || instructionLower.contains('arrive') || instructionLower.contains('destination') || instructionLower.contains('goal')) {
                  turnType = 'arrive';
                } else if (type == 6 || type == 11 || instructionLower.contains('straight') || instructionLower.contains('continue')) {
                  turnType = 'straight';
                }

                steps.add(NavigationStep(
                  point: stepPoint,
                  instruction: instruction,
                  distance: distance,
                  type: turnType,
                ));
              }
            }
          }
        }

        // If no steps were found, create basic steps
        if (steps.isEmpty && routePoints.isNotEmpty) {
          print('No steps found, creating basic steps');
          steps.add(NavigationStep(
            point: routePoints.first,
            instruction: 'Head towards destination',
            distance: 0,
            type: 'straight',
          ));

          // Add intermediate point if route is long
          if (routePoints.length > 10) {
            final midPoint = routePoints[routePoints.length ~/ 2];
            steps.add(NavigationStep(
              point: midPoint,
              instruction: 'Continue on route',
              distance: 0,
              type: 'straight',
            ));
          }

          steps.add(NavigationStep(
            point: routePoints.last,
            instruction: 'Arrive at destination',
            distance: 0,
            type: 'arrive',
          ));
        }

        print('Final: Route with ${routePoints.length} points and ${steps.length} steps');

        return {
          'route': routePoints,
          'steps': steps,
        };
      } else {
        print('No features found in response');
        return {'route': <LatLng>[], 'steps': <NavigationStep>[]};
      }
    } else {
      print('Error response (${response.statusCode}): ${response.body}');
      return {'route': <LatLng>[], 'steps': <NavigationStep>[]};
    }
  } catch (e) {
    print('Exception fetching route: $e');
    print('Stack trace: ${StackTrace.current}');
    return {'route': <LatLng>[], 'steps': <NavigationStep>[]};
  }
}