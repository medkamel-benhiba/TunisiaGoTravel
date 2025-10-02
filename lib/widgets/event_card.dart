import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:tunisiagotravel/theme/color.dart';
import '../models/event.dart';
import '../screens/event_details_screen.dart';

class EventCard extends StatelessWidget {
  final Event event;

  const EventCard({super.key, required this.event});

  void _navigateToDetails(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EventDetailsScreen(event: event),
      ),
    );
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
      cardHeight = 200; // Small tablet
    } else if (screenWidth < 1200) {
      cardHeight = 220; // Large tablet
    } else {
      cardHeight = 230; // Desktop
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
              color: Colors.black.withOpacity(0.3),
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
                imageUrl: event.cover ??  '',
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
                      Icons.event,
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
                    AppColorstatic.mainColor.withOpacity(0.9),
                  ],
                ),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(screenWidth < 600 ? 12 : 16),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    AppColorstatic.primary.withOpacity(0.6),
                  ],
                ),
              ),
            ),
            // Event name
            Positioned(
              left: screenWidth < 600 ? 12 : 16,
              bottom: screenWidth < 600 ? 55 : 65,
              right: screenWidth < 600 ? 12 : 16,
              child: Text(
                event.getName(locale),
                style: TextStyle(
                  fontSize: screenWidth < 600 ? 14 : 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                maxLines: screenWidth < 600 ? 2 : 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            // Date, price, and address
            Positioned(
              left: screenWidth < 600 ? 12 : 16,
              bottom: screenWidth < 600 ? 15 : 25,
              right: screenWidth < 600 ? 12 : 16,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Date
                  if (event.startDate != null)
                    Text(
                      'date'.tr() +
                          ': ${event.startDate}' +
                          (event.endDate != null && event.endDate != event.startDate
                              ? ' - ${event.endDate}'
                              : ''),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: screenWidth < 600 ? 10 : 12,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  const SizedBox(height: 4),
                  // Address
                  if (event.address != null && event.address!.isNotEmpty)
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
                            event.getAddress(locale).isNotEmpty
                                ? event.getAddress(locale)
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