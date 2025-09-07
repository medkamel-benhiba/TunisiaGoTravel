import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../services/getCurrentPosition.dart';
import '../services/get_itinerary.dart';

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
    currentLocation = await getCurrentLocation();
    if (currentLocation != null) {
      routePoints = await getRoute(currentLocation!, widget.destination);
      setState(() {
        // Move the map to the current location
        _mapController.move(currentLocation!, 13);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (currentLocation == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Itinéraire")),
      body: FlutterMap(
        mapController: _mapController,
        options: MapOptions(
          initialCenter: currentLocation!,
          initialZoom: 13,
        ),
        children: [
          TileLayer(
            urlTemplate:
            "https://api.maptiler.com/maps/streets/{z}/{x}/{y}.png?key=VOTRE_KEY_MAPTILER",
            userAgentPackageName: 'com.example.app',
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
                  strokeWidth: 4,
                ),
              ],
            ),
        ],
      ),
    );
  }
}
