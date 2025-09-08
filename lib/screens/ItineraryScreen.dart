import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'dart:math' as math;

import '../services/getCurrentPosition.dart';
import '../services/get_itinerary.dart';
import '../theme/color.dart';

class ItineraryScreen extends StatefulWidget {
  final LatLng destination;

  const ItineraryScreen({super.key, required this.destination});

  @override
  State<ItineraryScreen> createState() => _ItineraryScreenState();
}

class _ItineraryScreenState extends State<ItineraryScreen> {
  LatLng? currentLocation;
  List<LatLng> routePoints = [];
  final MapController _mapController = MapController();

  @override
  void initState() {
    super.initState();
    _initRoute();
  }

  Future<void> _initRoute() async {
    final loc = await getCurrentLocation();
    if (loc == null) {
      print('Failed to get current location');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Impossible d\'obtenir votre position actuelle'),
            backgroundColor: Colors.orange,
          ),
        );
      }
      return;
    }

    print('Current location: ${loc.latitude}, ${loc.longitude}');
    print('Destination: ${widget.destination.latitude}, ${widget.destination.longitude}');

    // Calculer la distance approximative
    final distance = _calculateDistance(loc, widget.destination);
    print('Approximate distance: ${distance.toStringAsFixed(2)} km');

    if (distance > 5000) { // Plus de 5000km
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Distance trop grande pour calculer l\'itinéraire: ${distance.toStringAsFixed(0)} km'),
            backgroundColor: Colors.orange,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }

    final route = await getRoute(loc, widget.destination);

    if (mounted) {
      setState(() {
        currentLocation = loc;
        routePoints = route;
      });

      // Ajuster la vue pour inclure tous les points après le premier rendu
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _fitMapBounds();
      });
    }
  }

  // Calcule la distance approximative entre deux points en km
  double _calculateDistance(LatLng point1, LatLng point2) {
    const double earthRadius = 6371; // Rayon de la Terre en km

    final double lat1Rad = point1.latitude * (math.pi / 180);
    final double lat2Rad = point2.latitude * (math.pi / 180);
    final double deltaLatRad = (point2.latitude - point1.latitude) * (math.pi / 180);
    final double deltaLngRad = (point2.longitude - point1.longitude) * (math.pi / 180);

    final double a = math.pow(math.sin(deltaLatRad / 2), 2) +
        math.cos(lat1Rad) * math.cos(lat2Rad) *
            math.pow(math.sin(deltaLngRad / 2), 2);
    final double c = 2 * math.asin(math.sqrt(a));

    return earthRadius * c;
  }

  void _fitMapBounds() {
    if (currentLocation == null) return;

    final points = [currentLocation!, widget.destination];
    if (routePoints.isNotEmpty) {
      points.addAll(routePoints);
    }

    if (points.length < 2) return;

    // Utiliser fitCamera avec CameraFit.bounds pour ajuster automatiquement la vue
    try {
      _mapController.fitCamera(
        CameraFit.bounds(
          bounds: LatLngBounds.fromPoints(points),
          padding: const EdgeInsets.all(50),
        ),
      );
    } catch (e) {
      // Fallback au cas où fitCamera ne fonctionne pas
      print('Error fitting camera: $e');
      // Calculer manuellement le centre et le zoom
      _fallbackFitBounds(points);
    }
  }

  void _fallbackFitBounds(List<LatLng> points) {
    // Calculer les limites
    double minLat = points.first.latitude;
    double maxLat = points.first.latitude;
    double minLng = points.first.longitude;
    double maxLng = points.first.longitude;

    for (final point in points) {
      minLat = minLat < point.latitude ? minLat : point.latitude;
      maxLat = maxLat > point.latitude ? maxLat : point.latitude;
      minLng = minLng < point.longitude ? minLng : point.longitude;
      maxLng = maxLng > point.longitude ? maxLng : point.longitude;
    }

    // Calculer le centre et le zoom approprié
    final centerLat = (minLat + maxLat) / 2;
    final centerLng = (minLng + maxLng) / 2;
    final center = LatLng(centerLat, centerLng);

    // Calculer un zoom approprié basé sur la distance
    final latDiff = maxLat - minLat;
    final lngDiff = maxLng - minLng;
    final maxDiff = latDiff > lngDiff ? latDiff : lngDiff;

    // Ajuster le zoom en fonction de la différence maximale
    double zoom = 10; // zoom par défaut
    if (maxDiff < 0.01) {
      zoom = 15;
    } else if (maxDiff < 0.05) {
      zoom = 13;
    } else if (maxDiff < 0.1) {
      zoom = 11;
    } else if (maxDiff < 0.5) {
      zoom = 9;
    } else {
      zoom = 7;
    }

    _mapController.move(center, zoom);
  }

  @override
  Widget build(BuildContext context) {
    if (currentLocation == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // Calcul du centre pour inclure currentLocation et destination
    final LatLng center = LatLng(
      (currentLocation!.latitude + widget.destination.latitude) / 2,
      (currentLocation!.longitude + widget.destination.longitude) / 2,
    );

    return Scaffold(
      appBar: AppBar(title: Text("Itinéraire",
        style: TextStyle(
        color: AppColorstatic.lightTextColor,
        fontSize: 22,
        fontWeight: FontWeight.bold,
        ),
      ),
        backgroundColor: AppColorstatic.primary,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: FlutterMap(
        mapController: _mapController,
        options: MapOptions(
          initialCenter: center,
          initialZoom: 8,
          minZoom: 3,
          interactionOptions: InteractionOptions(
            flags: InteractiveFlag.pinchZoom | InteractiveFlag.drag,  // Enable only pinch zoom and drag, disable rotation
          )
        ),
        children: [
          TileLayer(
            urlTemplate:
            "https://api.maptiler.com/maps/streets/{z}/{x}/{y}.png?key=CubRhkNFVL94muXGM5yt",
            userAgentPackageName: 'com.example.tunisiagotravel',
          ),
          MarkerLayer(
            markers: [
              Marker(
                point: currentLocation!,
                width: 30,
                height: 30,
                child: const Icon(Icons.my_location, color: Colors.blue, size: 30),
              ),
              Marker(
                point: widget.destination,
                width: 30,
                height: 30,
                child: const Icon(Icons.location_on, color: Colors.red, size: 30),
              ),
            ],
          ),
          if (routePoints.isNotEmpty)
            PolylineLayer(
              polylines: [
                Polyline(
                  points: routePoints,
                  color: Colors.blue,
                  strokeWidth: 3,
                ),
              ],
            ),
        ],
      ),
    );
  }
}