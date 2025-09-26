import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:tunisiagotravel/models/event.dart';
import 'package:tunisiagotravel/screens/event_details_screen.dart';
import 'package:intl/intl.dart';

class EventCardDest extends StatelessWidget {
  final Event event;
  final double cardHeight;
  final double screenWidth;

  const EventCardDest({
    super.key,
    required this.event,
    required this.cardHeight,
    required this.screenWidth,
  });

  String formatDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return '';
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat.yMMMd().format(date); // Example: Sep 25, 2025
    } catch (_) {
      return dateStr;
    }
  }

  @override
  Widget build(BuildContext context) {
    final start = formatDate(event.startDate);
    final end = formatDate(event.endDate);

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => EventDetailsScreen(event: event),
          ),
        );
      },
      child: Container(
        height: cardHeight,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(screenWidth < 600 ? 12 : 16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: screenWidth < 600 ? 6 : 10,
              offset: Offset(0, screenWidth < 600 ? 2 : 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Event Image
            ClipRRect(
              borderRadius: BorderRadius.circular(screenWidth < 600 ? 12 : 16),
              child: CachedNetworkImage(
                imageUrl: event.cover ?? '',
                width: double.infinity,
                height: double.infinity,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: Colors.grey.shade200,
                  child: const Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  color: Colors.grey.shade200,
                  child: Icon(
                    Icons.event,
                    color: Colors.grey.shade400,
                    size: screenWidth < 600 ? 30 : 40,
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
                    Colors.black.withOpacity(0.6),
                  ],
                ),
              ),
            ),
            // Event Info
            Positioned(
              left: screenWidth < 600 ? 12 : 16,
              bottom: screenWidth < 600 ? 12 : 16,
              right: screenWidth < 600 ? 12 : 16,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Event Title
                  Text(
                    event.getName(Localizations.localeOf(context)),
                    style: TextStyle(
                      fontSize: screenWidth < 600 ? 14 : 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  // Event Dates
                  if ((event.startDate != null && event.startDate!.isNotEmpty) ||
                      (event.endDate != null && event.endDate!.isNotEmpty))
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today,
                          size: screenWidth < 600 ? 12 : 14,
                          color: Colors.white.withOpacity(0.8),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          start.isNotEmpty && end.isNotEmpty
                              ? '$start - $end'
                              : start.isNotEmpty
                              ? start
                              : end,
                          style: TextStyle(
                            fontSize: screenWidth < 600 ? 10 : 12,
                            color: Colors.white.withOpacity(0.8),
                          ),
                        ),
                      ],
                    ),
                  const SizedBox(height: 4),
                  // Event Location
                  if (event.address != null && event.address!.isNotEmpty)
                    Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          size: screenWidth < 600 ? 12 : 14,
                          color: Colors.white.withOpacity(0.8),
                        ),
                        const SizedBox(width: 2),
                        Expanded(
                          child: Text(
                            event.getAddress(Localizations.localeOf(context)),
                            style: TextStyle(
                              fontSize: screenWidth < 600 ? 10 : 12,
                              color: Colors.white.withOpacity(0.8),
                            ),
                            maxLines: 1,
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
