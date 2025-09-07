import 'dart:async';
import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'package:flutter/services.dart';
import 'package:flutter_html/flutter_html.dart' as html;
import 'package:flutter_html/flutter_html.dart' hide Marker;
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

  List<Destination> destination =[];
  final List<Map<String, dynamic>> categories = [
    {'name': 'Hôtels', 'icon': Icons.hotel, 'isChecked': false,'color':AppColorstatic.primary},
    {'name': 'maison', 'icon': Icons.add_home_work_sharp, 'isChecked': false,'color':AppColorstatic.primary},
    {'name': 'Restaurants', 'icon': Icons.restaurant, 'isChecked': false,'color':AppColorstatic.primary2},
    {'name': 'event', 'icon': Icons.event, 'isChecked': false,'color':AppColorstatic.secondary},
    {'name': 'Activity', 'icon': Icons.wc_outlined, 'isChecked': false,'color':AppColorstatic.primary},
    {'name': 'musees', 'icon': Icons.account_balance, 'isChecked': false,'color':AppColorstatic.primary},

  ];
  Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    addmar();


    WidgetsBinding.instance.addPostFrameCallback((_) {
      final hotelProvider = Provider.of<HotelProvider>(context, listen: false);
      if (hotelProvider.hotels.isEmpty) {
        hotelProvider.fetchAllHotels();
      }

      final restaurantProvider = Provider.of<RestaurantProvider>(context, listen: false);
      if (restaurantProvider.restaurants.isEmpty) {
        restaurantProvider.fetchAllRestaurants();
      }

      final activiteProvider = Provider.of<ActivityProvider>(context, listen: false);
      if (activiteProvider.activities.isEmpty) {
        activiteProvider.fetchActivities();
      }

      final eventProvider = Provider.of<EventProvider>(context, listen: false);
      if (eventProvider.events.isEmpty) {
        eventProvider.fetchEvents();
      }

      final museeProvider = Provider.of<MuseeProvider>(context, listen: false);
      if (museeProvider.musees.isEmpty) {
        museeProvider.fetchMusees();
      }

      final monumentProvider = Provider.of<MonumentProvider>(context, listen: false);
      if (monumentProvider.monuments.isEmpty) {
        monumentProvider.fetchMonuments();
      }

      final festivalProvider = Provider.of<FestivalProvider>(context, listen: false);
      if (festivalProvider.festivals.isEmpty) {
        festivalProvider.fetchFestivals();
      }

      final destinationProvider = Provider.of<DestinationProvider>(context, listen: false);
      if (destinationProvider.destinations.isEmpty) {
        destinationProvider.fetchDestinations();
      }
    });

  }
  BitmapDescriptor markerIcon = BitmapDescriptor.defaultMarker;
  BitmapDescriptor markerIconrest = BitmapDescriptor.defaultMarker;
  BitmapDescriptor markerIconevent = BitmapDescriptor.defaultMarker;
  BitmapDescriptor markerIconmusees = BitmapDescriptor.defaultMarker;
  BitmapDescriptor markerIconmaison = BitmapDescriptor.defaultMarker;
  Future<BitmapDescriptor> getCustomMarker(String assetPath, {int width = 100, int height = 100}) async {
    try {
      // Load image as ByteData
      ByteData data = await rootBundle.load(assetPath);
      Uint8List bytes = data.buffer.asUint8List();

      // Decode image and resize
      img.Image? originalImage = img.decodeImage(bytes);
      if (originalImage == null) throw Exception("Failed to decode image.");

      img.Image resizedImage = img.copyResize(originalImage, width: width, height: height);

      // Encode back to Uint8List
      Uint8List resizedBytes = Uint8List.fromList(img.encodePng(resizedImage));

      // Convert to BitmapDescriptor
      return BitmapDescriptor.fromBytes(resizedBytes);
    } catch (e) {
      print("Error loading or resizing marker icon: $e");
      return BitmapDescriptor.defaultMarker; // Fallback in case of failure
    }
  }
  addmar() async {
    // Load custom marker icons
    markerIcon = await getCustomMarker('assets/images/marker/hotel-icon.png');
    markerIconrest = await getCustomMarker('assets/images/marker/restaurant-icon.png');
    markerIconevent = await getCustomMarker('assets/images/marker/event-icon.png');
    markerIconmusees = await getCustomMarker('assets/images/marker/musee.png');
    markerIconmaison = await getCustomMarker('assets/images/marker/hotel-icon.png');

    // Get data from individual providers
    final hotelProvider = Provider.of<HotelProvider>(context, listen: false);
    final restaurantProvider = Provider.of<RestaurantProvider>(context, listen: false);
    final activityProvider = Provider.of<ActivityProvider>(context, listen: false);
    final eventProvider = Provider.of<EventProvider>(context, listen: false);
    final museeProvider = Provider.of<MuseeProvider>(context, listen: false);
    final maisonProvider = Provider.of<MaisonProvider>(context, listen: false);
    final destinationProvider = Provider.of<DestinationProvider>(context, listen: false);

    // Set initial markers (for example, hotels by default)
    _markers = _createMarkers(hotelProvider.hotels);

    // Set destinations for the dropdown
    setState(() {
      destination = destinationProvider.destinations;
    });
  }

  Future<Uint8List> getBytesFromAsset(String path, int width) async {
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(), targetWidth: width);
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png))!.buffer.asUint8List();
  }

  String? selectedDestination1;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async {
          context.read<GlobalProvider>().setPage(AppPage.home);
          return false; // Prevent default back behavior
        },
        child:Scaffold(
          appBar: AppBar(
            title: const Text(
              'Carte détaillée de la zone',
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: AppColorstatic.primary,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () {
                context.read<GlobalProvider>().setPage(AppPage.home);
              },
            ),
          ),

          body: Consumer<DestinationProvider>(
            builder: (context, destinationProvider, _) {
              final destinations = destinationProvider.destinations;

              return Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: Column(
                      children: [
                        destination.isNotEmpty? SizedBox(height: 60,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal:4, vertical: 4),
                            child:  Container(
                              decoration: BoxDecoration(
                                //color: AppColorstatic.primary,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  DropdownButton<String>(
                                    value: selectedDestination1,
                                    hint: const Text("Choisissez votre destination"),
                                    items: destination.map<DropdownMenuItem<String>>((Destination destination) {
                                      return DropdownMenuItem<String>(
                                        value: destination.id,
                                        child: Text(destination.name?? ""),
                                      );
                                    }).toList(),
                                    onChanged: (String? dist) {

                                      if (dist != null) {
                                        // Find the selected destination from dataProvider
                                        Destination? selectedDestination = destination.firstWhere(
                                              (destination) => destination.id == dist,
                                          // Default location
                                        );
                                        // Move camera to new destination
                                        mapController?.animateCamera(
                                          CameraUpdate.newLatLng(LatLng(selectedDestination.lat.toDouble(), selectedDestination.lng)),
                                        );

                                        setState(() {
                                          selectedDestination1 = dist;
                                        });}
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),):Container(),
                        Expanded( // Ensures GoogleMap takes available space
                          child: GoogleMap(
                            initialCameraPosition: CameraPosition(
                              target: LatLng(36.8065, 10.1815),
                              zoom: 10,
                            ),
                            markers: _markers, // Ensure _markers is properly initialized
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
                                  width: 40.0,  // Set the width
                                  height: 40.0, // Set the height
                                  child: Checkbox(
                                    value: categories[index]['isChecked'],
                                    activeColor:AppColorstatic.primary, // Change to your preferred color
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
                                Icon(categories[index]['icon'], size: 24.0, color:categories[index]['color'] ),

                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ));
  }

  Set<Marker> _createMarkers(List<Hotel> hotels)  {

    return hotels.map((hotel) {
      double lat = double.tryParse(hotel.lat ?? '') ?? 0.0;
      double lng = double.tryParse(hotel.lng ?? '') ?? 0.0;
      print(hotel.lat);

      return Marker(
        markerId: MarkerId(hotel.id.toString()),
        position: LatLng(lat, lng),
        onTap: () {
          _showCustomInfoWindow(context, hotel);
        },
        icon: markerIcon,
      );
    }).toSet();
  }


  Set<Marker> _createMarkersrestaurant(List<Restaurant> restaurants)  {

    return restaurants.map((restaurant) {
      double lat = double.tryParse(restaurant.lat ?? '') ?? 0.0;
      double lng = double.tryParse(restaurant.lng ?? '') ?? 0.0;


      return Marker(
        markerId: MarkerId(restaurant.id.toString()),
        position: LatLng(lat, lng),
        onTap: () {
          _showCustomInfoWindow(context, restaurant);
        },
        icon: markerIconrest,
      );
    }).toSet();
  }



  Set<Marker> _createMarkersActivety(List<Activity> activets)  {

    return activets.map((activety) {
      double lat = double.tryParse(activety.lat ?? '') ?? 0.0;
      double lng = double.tryParse(activety.lng ?? '') ?? 0.0;
      print(activety.lat);

      return Marker(
        markerId: MarkerId(activety.id.toString()),
        position: LatLng(lat, lng),
        onTap: () {
          _showCustomInfoWindow(context, activety);
        },
        icon: markerIconevent,
      );
    }).toSet();
  }

  Set<Marker> _createMarkersEvent(List<Event> activetes)  {

    return activetes.map((activety) {
      double lat = double.tryParse(activety.lat ?? '') ?? 0.0;
      double lng = double.tryParse(activety.lng ?? '') ?? 0.0;


      return Marker(
        markerId: MarkerId(activety.id.toString()),
        position: LatLng(lat, lng),
        onTap: () {
          _showCustomInfoWindow(context, activety);
        },
        icon: markerIconevent,
      );
    }).toSet();
  }


  Set<Marker> _createMarkersmaison(List<MaisonDHote> maisons)  {

    return maisons.map((maison) {
      double lat = double.tryParse(maison.lat ?? '') ?? 0.0;
      double lng = double.tryParse(maison.lng ?? '') ?? 0.0;

      return Marker(
        markerId: MarkerId(maison.id.toString()),
        position: LatLng(lat, lng),
        onTap: () {
          _showCustomInfoWindow(context, maison);
        },
        icon: markerIcon,
      );
    }).toSet();
  }

  Set<Marker> _createMarkersmusees(List<Musees> musees)  {

    return musees.map((musee) {
      double lat = double.tryParse(musee.lat ?? '') ?? 0.0;
      double lng = double.tryParse(musee.lng ?? '') ?? 0.0;

      return Marker(
        markerId: MarkerId(musee.id.toString()),
        position: LatLng(lat, lng),
        onTap: () {
          _showCustomInfoWindow(context, musee);
        },
        icon: markerIconmusees,
      );
    }).toSet();
  }


  void _showCustomInfoWindow(BuildContext context,  item) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(15.0)),
          ),
          child:
          item is Event
              ? EventDetailsScreen(event: item)
              : item is Restaurant
              ? RestaurantDetailsScreen(restaurant: item)
              :item is Activity
              ? ActivityDetailsScreen(activity: item)
              : item is Hotel
              ? HotelDetailsScreen(hotelSlug:item.slug)
              : item is MaisonDHote
              ? MaisonDetailsScreen(maison: item)
              : item is Musees
              ? MuseeDetailsScreen(museeSlug: item.slug)
              : SizedBox(),
        );
      },
    );
  }


  void _handleCategorySelection(String category) {
    if (category == 'Hôtels') {
      final hotelProvider = Provider.of<HotelProvider>(context, listen: false);
      setState(() {
        _markers = _createMarkers(hotelProvider.hotels);
      });
    }

    if (category == 'Restaurants') {
      final restaurantProvider = Provider.of<RestaurantProvider>(context, listen: false);
      setState(() {
        _markers = _createMarkersrestaurant(restaurantProvider.restaurants);
      });
    }

    if (category == 'event') {
      final eventProvider = Provider.of<EventProvider>(context, listen: false);
      setState(() {
        _markers = _createMarkersEvent(eventProvider.events);
      });
    }

    if (category == 'Activity') {
      final activityProvider = Provider.of<ActivityProvider>(context, listen: false);
      setState(() {
        _markers = _createMarkersActivety(activityProvider.activities);
      });
    }

    if (category == 'maison') {
      final maisonProvider = Provider.of<MaisonProvider>(context, listen: false); // or MaisonDHoteProvider
      setState(() {
        _markers = _createMarkersmaison(maisonProvider.allMaisons);
      });
    }

    if (category == 'musees') {
      final museeProvider = Provider.of<MuseeProvider>(context, listen: false);
      setState(() {
        _markers = _createMarkersmusees(museeProvider.musees);
      });
    }
  }

}
