import 'dart:async';
import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image/image.dart' as img;
import 'package:provider/provider.dart';
import 'package:tunisiagotravel/screens/restaurant_details_screen.dart';
import '../models/activity.dart';
import '../models/destination.dart';
import '../models/event.dart';
import '../models/hotel.dart';
import '../models/maisondHote.dart';
import '../models/musee.dart';
import '../models/restaurant.dart';
import '../providers/activity_provider.dart';
import '../providers/destination_provider.dart';
import '../providers/event_provider.dart';
import '../providers/festival_provider.dart';
import '../providers/global_provider.dart';
import '../providers/hotel_provider.dart';
import '../providers/maisondhote_provider.dart';
import '../providers/monument_provider.dart';
import '../providers/musee_provider.dart';
import '../providers/restaurant_provider.dart';
import '../theme/color.dart';
import 'activity_details_screen.dart';
import 'event_details_screen.dart';
import 'hotel_details_screen.dart';
import 'maisonDhote_details_screen.dart';
import 'musee_details_screen.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  GoogleMapController? mapController;

  List<Destination> destination = [];
  final List<Map<String, dynamic>> categories = [
    {'name': 'Hôtels', 'icon': Icons.hotel, 'isChecked': false, 'color': AppColorstatic.primary},
    {'name': 'maison', 'icon': Icons.add_home_work_sharp, 'isChecked': false, 'color': AppColorstatic.secondary},
    {'name': 'Restaurants', 'icon': Icons.restaurant, 'isChecked': false, 'color': AppColorstatic.primary2},
    {'name': 'event', 'icon': Icons.event, 'isChecked': false, 'color': AppColorstatic.primary},
    {'name': 'Activity', 'icon': Icons.wc_outlined, 'isChecked': false, 'color': AppColorstatic.secondary},
    {'name': 'musees', 'icon': Icons.account_balance, 'isChecked': false, 'color': AppColorstatic.primary2},
  ];

  Set<Marker> _markers = {};

  BitmapDescriptor markerIcon = BitmapDescriptor.defaultMarker;
  BitmapDescriptor markerIconrest = BitmapDescriptor.defaultMarker;
  BitmapDescriptor markerIconevent = BitmapDescriptor.defaultMarker;
  BitmapDescriptor markerIconmusees = BitmapDescriptor.defaultMarker;
  BitmapDescriptor markerIconmaison = BitmapDescriptor.defaultMarker;

  String? selectedDestination1;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // Charger les icônes personnalisées
      markerIcon = await getCustomMarker('assets/images/marker/hotel-icon.png');
      markerIconrest = await getCustomMarker('assets/images/marker/restaurant-icon.png');
      markerIconevent = await getCustomMarker('assets/images/marker/event-icon.png');
      markerIconmusees = await getCustomMarker('assets/images/marker/musee.png');
      markerIconmaison = await getCustomMarker('assets/images/marker/hotel-icon.png');

      // Providers
      final hotelProvider = Provider.of<HotelProvider>(context, listen: false);
      final restaurantProvider = Provider.of<RestaurantProvider>(context, listen: false);
      final activityProvider = Provider.of<ActivityProvider>(context, listen: false);
      final eventProvider = Provider.of<EventProvider>(context, listen: false);
      final museeProvider = Provider.of<MuseeProvider>(context, listen: false);
      final maisonProvider = Provider.of<MaisonProvider>(context, listen: false);
      final destinationProvider = Provider.of<DestinationProvider>(context, listen: false);

      // Charger les données si vides
      if (hotelProvider.allHotels.isEmpty) await hotelProvider.fetchAllHotels();
      if (restaurantProvider.allRestaurants.isEmpty) await restaurantProvider.fetchAllRestaurants();
      if (activityProvider.activities.isEmpty) await activityProvider.fetchActivities();
      if (eventProvider.events.isEmpty) await eventProvider.fetchEvents();
      if (museeProvider.musees.isEmpty) await museeProvider.fetchMusees();
      if (maisonProvider.allMaisons.isEmpty) await maisonProvider.fetchMaisons();
      if (destinationProvider.destinations.isEmpty) await destinationProvider.fetchDestinations();

      // Initialiser avec les hôtels par défaut
      setState(() {
        _markers = _createMarkers(hotelProvider.allHotels);
        destination = destinationProvider.destinations;
      });
    });
  }

  Future<BitmapDescriptor> getCustomMarker(String assetPath, {int width = 100, int height = 100}) async {
    try {
      ByteData data = await rootBundle.load(assetPath);
      Uint8List bytes = data.buffer.asUint8List();

      img.Image? originalImage = img.decodeImage(bytes);
      if (originalImage == null) throw Exception("Failed to decode image.");

      img.Image resizedImage = img.copyResize(originalImage, width: width, height: height);
      Uint8List resizedBytes = Uint8List.fromList(img.encodePng(resizedImage));

      return BitmapDescriptor.fromBytes(resizedBytes);
    } catch (e) {
      debugPrint("Error loading marker: $e");
      return BitmapDescriptor.defaultMarker;
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        context.read<GlobalProvider>().setPage(AppPage.home);
        Navigator.pop(context);
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Carte détaillée de la zone',
            style: const TextStyle(
              color: AppColorstatic.lightTextColor,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          iconTheme: const IconThemeData(color: Colors.white),
          backgroundColor: AppColorstatic.primary,
        ),
        body: Row(
          children: [
            Expanded(
              flex: 3,
              child: Column(
                children: [
                  destination.isNotEmpty
                      ? SizedBox(
                    height: 60,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                      child: DropdownButton<String>(
                        value: selectedDestination1,
                        hint: const Text("Choisissez votre destination"),
                        items: destination.map((d) {
                          return DropdownMenuItem<String>(
                            value: d.id,
                            child: Text(d.name ?? ""),
                          );
                        }).toList(),
                        onChanged: (String? dist) {
                          if (dist != null) {
                            Destination? selectedDestination = destination.firstWhere(
                                  (d) => d.id == dist,
                            );
                            mapController?.animateCamera(
                              CameraUpdate.newLatLng(LatLng(
                                  selectedDestination.lat.toDouble(), selectedDestination.lng)),
                            );
                            setState(() {
                              selectedDestination1 = dist;
                            });
                          }
                        },
                      ),
                    ),
                  )
                      : Container(),
                  Expanded(
                    child: GoogleMap(
                      initialCameraPosition: const CameraPosition(
                        target: LatLng(36.8065, 10.1815),
                        zoom: 10,
                      ),
                      markers: _markers,
                      onMapCreated: (controller) {
                        setState(() {
                          mapController = controller;
                        });
                      },
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 1,
              child: Container(
                color: Colors.white,
                child: ListView.builder(
                  itemCount: categories.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 40,
                            height: 40,
                            child: Checkbox(
                              value: categories[index]['isChecked'],
                              activeColor: AppColorstatic.primary,
                              checkColor: Colors.white,
                              onChanged: (bool? value) {
                                setState(() {
                                  for (var category in categories) {
                                    category['isChecked'] = false;
                                  }
                                  categories[index]['isChecked'] = value!;
                                  if (categories[index]['isChecked']) {
                                    _handleCategorySelection(categories[index]['name']);
                                  }
                                });
                              },
                            ),
                          ),
                          Icon(categories[index]['icon'], size: 24.0, color: categories[index]['color']),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // === Markers ===
  Set<Marker> _createMarkers(List<Hotel> hotels) {
    return hotels.map((hotel) {
      double lat = double.tryParse(hotel.lat ?? '') ?? 0.0;
      double lng = double.tryParse(hotel.lng ?? '') ?? 0.0;
      return Marker(
        markerId: MarkerId(hotel.id.toString()),
        position: LatLng(lat, lng),
        onTap: () => _showCustomInfoWindow(context, hotel),
        icon: markerIcon,
      );
    }).toSet();
  }

  Set<Marker> _createMarkersrestaurant(List<Restaurant> restaurants) {
    return restaurants.map((r) {
      double lat = double.tryParse(r.lat ?? '') ?? 0.0;
      double lng = double.tryParse(r.lng ?? '') ?? 0.0;
      return Marker(
        markerId: MarkerId(r.id.toString()),
        position: LatLng(lat, lng),
        onTap: () => _showCustomInfoWindow(context, r),
        icon: markerIconrest,
      );
    }).toSet();
  }

  Set<Marker> _createMarkersActivety(List<Activity> activities) {
    return activities.map((a) {
      double lat = double.tryParse(a.lat ?? '') ?? 0.0;
      double lng = double.tryParse(a.lng ?? '') ?? 0.0;
      return Marker(
        markerId: MarkerId(a.id.toString()),
        position: LatLng(lat, lng),
        onTap: () => _showCustomInfoWindow(context, a),
        icon: markerIconevent,
      );
    }).toSet();
  }

  Set<Marker> _createMarkersEvent(List<Event> events) {
    return events.map((e) {
      double lat = double.tryParse(e.lat ?? '') ?? 0.0;
      double lng = double.tryParse(e.lng ?? '') ?? 0.0;
      return Marker(
        markerId: MarkerId(e.id.toString()),
        position: LatLng(lat, lng),
        onTap: () => _showCustomInfoWindow(context, e),
        icon: markerIconevent,
      );
    }).toSet();
  }

  Set<Marker> _createMarkersmaison(List<MaisonDHote> maisons) {
    return maisons.map((m) {
      double lat = double.tryParse(m.lat ?? '') ?? 0.0;
      double lng = double.tryParse(m.lng ?? '') ?? 0.0;
      return Marker(
        markerId: MarkerId(m.id.toString()),
        position: LatLng(lat, lng),
        onTap: () => _showCustomInfoWindow(context, m),
        icon: markerIconmaison,
      );
    }).toSet();
  }

  Set<Marker> _createMarkersmusees(List<Musees> musees) {
    return musees.map((m) {
      double lat = double.tryParse(m.lat ?? '') ?? 0.0;
      double lng = double.tryParse(m.lng ?? '') ?? 0.0;
      return Marker(
        markerId: MarkerId(m.id.toString()),
        position: LatLng(lat, lng),
        onTap: () => _showCustomInfoWindow(context, m),
        icon: markerIconmusees,
      );
    }).toSet();
  }

  // === Info window ===
  void _showCustomInfoWindow(BuildContext context, item) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(8.0),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(15.0)),
          ),
          child: item is Event
              ? EventDetailsScreen(event: item)
              : item is Restaurant
              ? RestaurantDetailsScreen(restaurant: item)
              : item is Activity
              ? ActivityDetailsScreen(activity: item)
              : item is Hotel
              ? HotelDetailsScreen(hotelSlug: item.slug)
              : item is MaisonDHote
              ? MaisonDetailsScreen(maison: item)
              : item is Musees
              ? MuseeDetailsScreen(museeSlug: item.slug)
              : const SizedBox(),
        );
      },
    );
  }

  // === Handle category selection ===
  void _handleCategorySelection(String category) {
    if (category == 'Hôtels') {
      final hotelProvider = Provider.of<HotelProvider>(context, listen: false);
      setState(() => _markers = _createMarkers(hotelProvider.allHotels));
    }

    if (category == 'Restaurants') {
      final restaurantProvider = Provider.of<RestaurantProvider>(context, listen: false);
      setState(() => _markers = _createMarkersrestaurant(restaurantProvider.allRestaurants));
    }

    if (category == 'event') {
      final eventProvider = Provider.of<EventProvider>(context, listen: false);
      setState(() => _markers = _createMarkersEvent(eventProvider.events));
    }

    if (category == 'Activity') {
      final activityProvider = Provider.of<ActivityProvider>(context, listen: false);
      setState(() => _markers = _createMarkersActivety(activityProvider.activities));
    }

    if (category == 'maison') {
      final maisonProvider = Provider.of<MaisonProvider>(context, listen: false);
      setState(() => _markers = _createMarkersmaison(maisonProvider.allMaisons));
    }

    if (category == 'musees') {
      final museeProvider = Provider.of<MuseeProvider>(context, listen: false);
      setState(() => _markers = _createMarkersmusees(museeProvider.musees));
    }
  }
}
