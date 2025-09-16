import 'package:flutter/material.dart';
import 'package:tunisiagotravel/theme/color.dart';
import 'package:tunisiagotravel/theme/styletext.dart';
import 'package:easy_localization/easy_localization.dart';
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
    final locale = context.locale;

    return BaseCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(
            icon: Icons.restaurant,
            title: 'restaurant'.tr(),
            iconColor: Colors.deepPurple[600]!,
          ),
          const SizedBox(height: 16),
          Text(
            restaurant.getName(locale),
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.location_on, size: 14, color: Colors.grey),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  restaurant.getAddress(locale),
                  style: Appstylestatic.textStyle21,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          if (restaurant.getVille(locale).isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(
                restaurant.getVille(locale),
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
                    ? '${'restaurantsScreen.startingFrom'.tr()} ${restaurant.startingPrice.toString()} ${'TND'}'
                    : 'price_not_available'.tr(),
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.blueGrey[900],
                ),
              ),
            ],
          ),
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
                        SnackBar(content: Text("coordinates_not_available".tr())),
                      );
                    }
                  },
                  icon: const Icon(Icons.directions, size: 18),
                  label: Text('itinerary'.tr()),
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
                        builder: (_) => RestaurantReservationScreen(restaurant: restaurant),
                      ),
                    );
                  },
                  icon: const Icon(Icons.book_online, size: 18),
                  label: Text('reserve'.tr()),
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