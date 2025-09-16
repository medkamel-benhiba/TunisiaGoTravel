import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:tunisiagotravel/theme/color.dart';
import 'package:tunisiagotravel/theme/styletext.dart';
import '../../models/hotel_details.dart';
import '../../screens/ItineraryScreen.dart';
import 'package:tunisiagotravel/screens/search_disponibility.dart';
import '../base_card.dart';
import 'package:latlong2/latlong.dart';

class HotelInfoCard extends StatelessWidget {
  final HotelDetail hotel;

  const HotelInfoCard({super.key, required this.hotel});

  @override
  Widget build(BuildContext context) {
    final locale = context.locale;
    final hotelName = hotel.getName(locale);
    final hotelAddress = hotel.getAddress(locale);
    final hotelVille = hotel.getVille(locale); // Use getVille for localization

    return BaseCard(
      margin: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Hotel Name Row
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.hotel_class,
                  size: 18,
                  color: Colors.blue[600],
                ),
              ),
              const SizedBox(width: 15),
              Flexible(
                fit: FlexFit.loose,
                child: Text(
                  hotelName,
                  style: Appstylestatic.titreStyle1,
                  softWrap: true,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Address Row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.location_on,
                  size: 18,
                  color: Colors.blue[600],
                ),
              ),
              const SizedBox(width: 12),
              Flexible(
                fit: FlexFit.loose,
                child: Text(
                  '$hotelAddress, $hotelVille', // Use localized city
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.grey[700],
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Buttons Row
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    final destination = LatLng(hotel.lat, hotel.lng);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ItineraryScreen(destination: destination),
                      ),
                    );
                  },
                  icon: const Icon(Icons.directions, size: 18),
                  label: Text('itinerary'.tr()), // multilingual
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
                        builder: (_) => SearchDisponibilityScreen(hotel: hotel),
                      ),
                    );
                  },
                  icon: const Icon(Icons.book_online, size: 18),
                  label: Text('book'.tr()), // multilingual
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
