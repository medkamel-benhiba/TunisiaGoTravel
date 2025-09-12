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

  double? distanceKm; // total distance
  double? estimatedTimeHours; // estimated travel time

  @override
  void initState() {
    super.initState();
    _initRoute();
  }

  Future<void> _initRoute() async {
    final loc = await getCurrentLocation();
    if (loc == null) {
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

    final distance = _calculateDistance(loc, widget.destination);
    const avgSpeed = 60; // km/h (driving speed approx.)
    final time = distance / avgSpeed;

    final route = await getRoute(loc, widget.destination);

    if (mounted) {
      setState(() {
        currentLocation = loc;
        routePoints = route;
        distanceKm = distance;
        estimatedTimeHours = time;
      });

      WidgetsBinding.instance.addPostFrameCallback((_) {
        _fitMapBounds();
      });
    }
  }

  double _calculateDistance(LatLng point1, LatLng point2) {
    const double earthRadius = 6371; // km
    final double lat1Rad = point1.latitude * (math.pi / 180);
    final double lat2Rad = point2.latitude * (math.pi / 180);
    final double deltaLatRad =
        (point2.latitude - point1.latitude) * (math.pi / 180);
    final double deltaLngRad =
        (point2.longitude - point1.longitude) * (math.pi / 180);

    final double a = math.pow(math.sin(deltaLatRad / 2), 2) +
        math.cos(lat1Rad) *
            math.cos(lat2Rad) *
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

    try {
      _mapController.fitCamera(
        CameraFit.bounds(
          bounds: LatLngBounds.fromPoints(points),
          padding: const EdgeInsets.all(50),
        ),
      );
    } catch (e) {
      print('Error fitting camera: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (currentLocation == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final LatLng center = LatLng(
      (currentLocation!.latitude + widget.destination.latitude) / 2,
      (currentLocation!.longitude + widget.destination.longitude) / 2,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Itinéraire",
          style: TextStyle(
            color: AppColorstatic.lightTextColor,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppColorstatic.primary,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: center,
              initialZoom: 8,
              minZoom: 3,
              interactionOptions: InteractionOptions(
                flags: InteractiveFlag.pinchZoom | InteractiveFlag.drag,
              ),
            ),
            children: [
              TileLayer(
                urlTemplate:
                "https://api.maptiler.com/maps/streets/{z}/{x}/{y}.png?key=CubRhkNFVL94muXGM5yt",
                userAgentPackageName: 'com.nadas.group.tunisiagotravel',
              ),
              MarkerLayer(
                markers: [
                  Marker(
                    point: currentLocation!,
                    width: 30,
                    height: 30,
                    child:
                    const Icon(Icons.my_location, color: Colors.blue, size: 30),
                  ),
                  Marker(
                    point: widget.destination,
                    width: 30,
                    height: 30,
                    child:
                    const Icon(Icons.location_on, color: Colors.red, size: 30),
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

          // Info card at bottom
          if (distanceKm != null && estimatedTimeHours != null)
            Positioned(
              bottom: 20,
              left: 16,
              right: 16,
              child: Card(
                color: Colors.white,
                elevation: 5,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.route, color: Colors.blue),
                          const SizedBox(height: 6),
                          Text(
                            "${distanceKm!.toStringAsFixed(1)} km",
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Text("Distance"),
                        ],
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.timer, color: AppColorstatic.primary2),
                          const SizedBox(height: 6),
                          Text(
                            _formatTime(estimatedTimeHours!),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Text("Durée estimée"),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  String _formatTime(double hours) {
    final int h = hours.floor();
    final int m = ((hours - h) * 60).round();
    if (h == 0) {
      return "$m min";
    } else {
      return "$h h $m min";
    }
  }
}
