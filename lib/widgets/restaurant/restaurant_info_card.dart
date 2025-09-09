import 'package:flutter/material.dart';
import 'package:tunisiagotravel/theme/color.dart';
import 'package:tunisiagotravel/theme/styletext.dart';
import '../../models/restaurant.dart';
import '../../screens/ItineraryScreen.dart';
import '../../screens/restaurant_reservation.dart';
import '../../screens/search_disponibility.dart';
import '../base_card.dart';
import '../section_header.dart';
import 'package:latlong2/latlong.dart';

class RestaurantInfoCard extends StatelessWidget {
  final Restaurant restaurant;

  const RestaurantInfoCard({super.key, required this.restaurant});

  @override
  Widget build(BuildContext context) {
    return BaseCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(
            icon: Icons.restaurant,
            title: 'Restaurant',
            iconColor: Colors.deepPurple[600]!,
          ),
          const SizedBox(height: 16),
          Text(
            restaurant.name,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.location_on, size: 14, color: Colors.grey),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  restaurant.address ?? '',
                  style: Appstylestatic.textStyle21,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          if (restaurant.ville != null && restaurant.ville!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(
                restaurant.ville!,
                style: TextStyle(fontSize: 16, color: Colors.grey[700]),
              ),
            ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.star, color: Colors.amber[700], size: 18),
                  const SizedBox(width: 4),
                  Text(
                    restaurant.rate != null ? restaurant.rate.toString() : '0.0',
                    style: TextStyle(
                        fontSize: 14, color: Colors.grey[800], fontWeight: FontWeight.w500),
                  ),
                ],
              ),
              Text(
                restaurant.startingPrice != null
                    ? 'À partir de ${restaurant.startingPrice.toString()} TND'
                    : 'Prix non disponible',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.blueGrey[900],
                ),
              ),
            ],
          ),
          /*if (restaurant.isSpecial)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Chip(
                label: const Text('Spécial'),
                backgroundColor: Colors.orange[100],
                labelStyle: const TextStyle(color: Colors.orange),
              ),
            ),*/
          const SizedBox(height: 10),


          // Expanded Itinerary Button
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    print('restaurant lat: ${restaurant.lat}, lng: ${restaurant.lng}');
                    if (restaurant.lat != null && restaurant.lng != null) {
                      final destination = LatLng(
                        double.tryParse(restaurant.lat.toString()) ?? 0.0,
                        double.tryParse(restaurant.lng.toString()) ?? 0.0,
                      );
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ItineraryScreen(destination: destination),
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Coordinates not available")),
                      );
                    }
                  },
                  icon: const Icon(Icons.directions, size: 18),
                  label: const Text('Itinéraire'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColorstatic.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => RestaurantReservationScreen(restaurant:restaurant),
                      ),
                    );
                  },
                  icon: const Icon(Icons.book_online, size: 18),
                  label: const Text('Réserver'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColorstatic.primary2,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}