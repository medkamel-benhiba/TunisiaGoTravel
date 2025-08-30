import 'package:flutter/material.dart';
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
    return GestureDetector(
      onTap: () => _navigateToDetails(context),
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            if (event.cover != null && event.cover!.isNotEmpty)
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                child: Image.network(
                  event.cover!,
                  height: 140,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),

            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    event.title,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),

                  // Date
                  if (event.startDate != null)
                    Text(
                      'Date: ${event.startDate}' +
                          (event.endDate != null && event.endDate != event.startDate
                              ? ' - ${event.endDate}'
                              : ''),
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                    ),

                  const SizedBox(height: 6),

                  // Address
                  if (event.address != null)
                    Text(
                      event.address!,
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),

                  const SizedBox(height: 6),

                  // Price
                  if (event.price != null && event.price != "0")
                    Text(
                      'Prix: ${event.price} TND',
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
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
