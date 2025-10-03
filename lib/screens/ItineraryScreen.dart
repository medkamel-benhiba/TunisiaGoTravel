import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart';
import 'package:tunisiagotravel/models/navigation_step.dart';
import 'dart:async';
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
  List<NavigationStep> navigationSteps = [];
  final MapController _mapController = MapController();
  StreamSubscription<LocationData>? _locationSubscription;

  double? distanceKm;
  double? estimatedTimeHours;
  NavigationStep? currentStep;
  NavigationStep? nextStep;
  double distanceToNextTurn = 0;

  bool _isUpdatingRoute = false;
  DateTime? _lastRouteUpdate;
  static const _routeUpdateInterval = Duration(seconds: 3);
  static const _minDistanceForUpdate = 0.05;

  @override
  void initState() {
    super.initState();
    _initRoute();
    _startLocationTracking();
  }

  @override
  void dispose() {
    _locationSubscription?.cancel();
    super.dispose();
  }

  Future<void> _initRoute() async {
    final loc = await getCurrentLocation();
    if (loc == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(tr('itineraryScreen.unable_to_get_location')),
            backgroundColor: Colors.orange,
          ),
        );
      }
      return;
    }

    await _updateRoute(loc);
  }

  Future<void> _updateRoute(LatLng newLocation) async {
    if (_isUpdatingRoute) return;

    setState(() {
      _isUpdatingRoute = true;
    });

    try {
      final distance = _calculateDistance(newLocation, widget.destination);
      const avgSpeed = 60;
      final time = distance / avgSpeed;

      final routeData = await getRouteWithInstructions(newLocation, widget.destination);

      print('Route data received - Points: ${(routeData['route'] as List?)?.length ?? 0}, Steps: ${(routeData['steps'] as List?)?.length ?? 0}');

      if (mounted) {
        setState(() {
          currentLocation = newLocation;
          routePoints = (routeData['route'] as List<dynamic>?)?.cast<LatLng>() ?? [];
          navigationSteps = (routeData['steps'] as List<dynamic>?)?.cast<NavigationStep>() ?? [];
          distanceKm = distance;
          estimatedTimeHours = time;
          _lastRouteUpdate = DateTime.now();
          _updateCurrentStep();
        });

        // Center map on user location
        _centerMapOnUser();
      }
    } finally {
      setState(() {
        _isUpdatingRoute = false;
      });
    }
  }

  bool _shouldUpdateRoute(LatLng newLocation) {
    // Don't update if already updating
    if (_isUpdatingRoute) return false;

    // Always update if this is the first location
    if (currentLocation == null) return true;

    // Check if enough time has passed
    if (_lastRouteUpdate != null) {
      final timeSinceLastUpdate = DateTime.now().difference(_lastRouteUpdate!);
      if (timeSinceLastUpdate < _routeUpdateInterval) {
        return false;
      }
    }

    // Check if user has moved enough
    final distanceMoved = _calculateDistance(currentLocation!, newLocation);
    return distanceMoved >= _minDistanceForUpdate;
  }

  void _startLocationTracking() async {
    Location location = Location();

    bool serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        print('Location service disabled');
        return;
      }
    }

    PermissionStatus permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        print('Location permission not granted');
        return;
      }
    }

    _locationSubscription = location.onLocationChanged.listen((LocationData locData) {
      if (locData.latitude != null && locData.longitude != null && mounted) {
        final newLocation = LatLng(locData.latitude!, locData.longitude!);

        print('Location updated: ${locData.latitude}, ${locData.longitude}');

        // Update route if conditions are met
        if (_shouldUpdateRoute(newLocation)) {
          print('Updating route due to location change');
          _updateRoute(newLocation);
        } else {
          // Just update current location and recalculate distance without fetching new route
          setState(() {
            currentLocation = newLocation;
            distanceKm = _calculateDistance(newLocation, widget.destination);
            const avgSpeed = 60;
            estimatedTimeHours = distanceKm! / avgSpeed;
            _updateCurrentStep();
          });

          // Keep map centered on user
          _centerMapOnUser();
        }
      }
    });
  }

  void _centerMapOnUser() {
    if (currentLocation == null) return;

    try {
      _mapController.move(currentLocation!, _mapController.camera.zoom);
    } catch (e) {
      print('Error centering map: $e');
    }
  }

  void _updateCurrentStep() {
    if (currentLocation == null || navigationSteps.isEmpty) return;

    NavigationStep? closest;
    double minDistance = double.infinity;
    int closestIndex = -1;

    for (int i = 0; i < navigationSteps.length; i++) {
      final step = navigationSteps[i];
      final dist = _calculateDistance(currentLocation!, step.point);

      if (dist < minDistance && dist < 5.0) {
        minDistance = dist;
        closest = step;
        closestIndex = i;
      }
    }

    if (closest != null) {
      currentStep = closest;
      distanceToNextTurn = minDistance;

      // Get next step if available
      if (closestIndex + 1 < navigationSteps.length) {
        nextStep = navigationSteps[closestIndex + 1];
      } else {
        nextStep = null;
      }
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

  IconData _getInstructionIcon(String type) {
    switch (type) {
      case 'left':
        return Icons.turn_left;
      case 'right':
        return Icons.turn_right;
      case 'straight':
        return Icons.straight;
      case 'arrive':
        return Icons.flag;
      default:
        return Icons.navigation;
    }
  }

  String _formatDistance(double distanceKm) {
    if (distanceKm < 1) {
      return '${(distanceKm * 1000).round()} m';
    } else {
      return '${distanceKm.toStringAsFixed(1)} km';
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
      appBar: AppBar(
        title: Text(
          tr('itineraryScreen.title'),
          style: TextStyle(
            color: AppColorstatic.lightTextColor,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppColorstatic.primary,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.my_location),
            onPressed: _fitMapBounds,
            tooltip: 'Fit route',
          ),
        ],
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: currentLocation!,
              initialZoom: 15,
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
                    const Icon(Icons.directions_car, color: AppColorstatic.darker, size: 25),
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


          // Navigation instruction card at top
          if (currentStep != null)
            Positioned(
              top: 20,
              left: 16,
              right: 16,
              child: Card(
                color: AppColorstatic.primary.withOpacity(0.75),
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            _getInstructionIcon(currentStep!.type),
                            color: Colors.white,
                            size: 40,
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _formatDistance(distanceToNextTurn),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  currentStep!.instruction,
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      if (nextStep != null) ...[
                        const Divider(color: Colors.white30, height: 24),
                        Row(
                          children: [
                            Icon(
                              _getInstructionIcon(nextStep!.type),
                              color: Colors.white70,
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Then ${nextStep!.instruction}',
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),
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
                          Text(tr('itineraryScreen.distance')),
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
                          Text(tr('itineraryScreen.estimated_time')),
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