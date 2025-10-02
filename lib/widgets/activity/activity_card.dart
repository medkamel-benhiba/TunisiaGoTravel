import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:tunisiagotravel/theme/color.dart';
import 'package:latlong2/latlong.dart';
import '../../models/activity.dart';
import '../../screens/activity_details_screen.dart';
import '../../screens/ItineraryScreen.dart';

class ActivityCard extends StatelessWidget {
  final Activity activity;

  const ActivityCard({super.key, required this.activity});

  void _navigateToDetails(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ActivityDetailsScreen(activity: activity),
      ),
    );
  }

  void _handleItinerary(BuildContext context) {
    if (activity.lat != null && activity.lng != null) {
      try {
        final lat = double.parse(activity.lat!);
        final lng = double.parse(activity.lng!);
        final destination = LatLng(lat, lng);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ItineraryScreen(destination: destination),
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('invalid_coordinates'.tr())),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('coordinates_unavailable'.tr())),
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
      cardHeight = 180; // Mobile
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
                imageUrl: activity.images!.first ?? activity.cover ?? '',
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
                      Icons.local_activity,
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
            // Activity name
            Positioned(
              left: screenWidth < 600 ? 12 : 16,
              bottom: screenWidth < 600 ? 65 : 75,
              right: screenWidth < 600 ? 12 : 16,
              child: Text(
                activity.getName(locale),
                style: TextStyle(
                  fontSize: screenWidth < 600 ? 14 : 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                maxLines: screenWidth < 600 ? 2 : 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            // Rating and address
            Positioned(
              left: screenWidth < 600 ? 12 : 16,
              bottom: screenWidth < 600 ? 25 : 35,
              right: screenWidth < 600 ? 12 : 16,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Rating and price row
                  Row(
                    children: [
                      Icon(
                        Icons.star,
                        color: Colors.amber,
                        size: screenWidth < 600 ? 14 : 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        activity.rate != null
                            ? activity.rate!.toStringAsFixed(1)
                            : 'N/A',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: screenWidth < 600 ? 10 : 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 8),
                      if (activity.price != null && activity.price != "0")
                        Text(
                          'starting_price_tnd'.tr(args: [activity.price.toString()]),
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: screenWidth < 600 ? 10 : 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  // Address
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        size: screenWidth < 600 ? 14 : 16,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          activity.getAddress(locale).isNotEmpty
                              ? activity.getAddress(locale)
                              : 'address_unavailable'.tr(),
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: screenWidth < 600 ? 10 : 12,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}