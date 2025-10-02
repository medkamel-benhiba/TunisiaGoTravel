import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:tunisiagotravel/theme/color.dart';
import 'package:latlong2/latlong.dart';
import '../../models/maisondHote.dart';
import '../../screens/ItineraryScreen.dart';
import '../../screens/maisonDhote_details_screen.dart';

class MaisonCard extends StatelessWidget {
  final MaisonDHote maison;

  const MaisonCard({super.key, required this.maison});

  void _navigateToDetails(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MaisonDetailsScreen(maison: maison),
      ),
    );
  }

  void _handleItinerary(BuildContext context) {
    print('Maison lat: ${maison.lat}, lng: ${maison.lng}');
    if (maison.lat != null && maison.lng != null) {
      try {
        final lat = double.parse(maison.lat!);
        final lng = double.parse(maison.lng!);
        final destination = LatLng(lat, lng);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ItineraryScreen(destination: destination),
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('restaurantsScreen.invalidCoordinates'.tr())),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('restaurantsScreen.addressUnavailable'.tr())),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final locale = context.locale;
    final screenWidth = MediaQuery.of(context).size.width;

    // Responsive card height
    double cardHeight;
    if (screenWidth < 600) {
      cardHeight = 190; // Mobile
    } else if (screenWidth < 900) {
      cardHeight = 210; // Small tablet
    } else if (screenWidth < 1200) {
      cardHeight = 230; // Large tablet
    } else {
      cardHeight = 250; // Desktop
    }

    return GestureDetector(
      onTap: () => _navigateToDetails(context),
      child: Container(
        height: cardHeight,
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(screenWidth < 600 ? 12 : 16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: screenWidth < 600 ? 6 : 10,
              offset: Offset(0, screenWidth < 600 ? 2 : 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Background image
            ClipRRect(
              borderRadius: BorderRadius.circular(screenWidth < 600 ? 12 : 16),
              child: CachedNetworkImage(
                imageUrl: maison.images.first ?? '',
                width: double.infinity,
                height: double.infinity,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: Colors.grey[200],
                  child: const Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  color: Colors.grey[200],
                  child: Center(
                    child: Icon(
                      Icons.home,
                      size: screenWidth < 600 ? 30 : 40,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ),
            ),
            // Gradient overlay
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(screenWidth < 600 ? 12 : 16),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    AppColorstatic.primary.withOpacity(0.70),
                  ],
                ),
              ),
            ),
            // Maison name
            Positioned(
              left: screenWidth < 600 ? 12 : 16,
              bottom: screenWidth < 600 ? 45 : 55,
              right: screenWidth < 600 ? 12 : 16,
              child: Text(
                maison.getName(locale),
                style: TextStyle(
                  fontSize: screenWidth < 600 ? 14 : 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                maxLines: screenWidth < 600 ? 2 : 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            // Rating and price
            Positioned(
              left: screenWidth < 600 ? 12 : 16,
              bottom: screenWidth < 600 ? 25 : 35,
              child: Row(
                children: [
                  Icon(
                    Icons.star,
                    color: Colors.amber,
                    size: screenWidth < 600 ? 14 : 16,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    maison.noteGoogle.isNotEmpty ? maison.noteGoogle : '0.0',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: screenWidth < 600 ? 10 : 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (maison.startingPrice > 0)
                    Text(
                      '${'restaurantsScreen.startingFrom'.tr()} ${maison.startingPrice.toStringAsFixed(0)} TND',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: screenWidth < 600 ? 10 : 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                ],
              ),
            ),
            // Special tag
            if (maison.isSpecial)
              Positioned(
                top: 8,
                left: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColorstatic.primary2.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'restaurantsScreen.special'.tr(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}