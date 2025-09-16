import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:latlong2/latlong.dart';
import 'package:tunisiagotravel/theme/color.dart';
import '../models/event.dart';
import '../widgets/base_card.dart';
import '../widgets/section_header.dart';
import 'ItineraryScreen.dart';

class EventDetailsScreen extends StatelessWidget {
  final Event event;

  const EventDetailsScreen({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          event.getName(locale),
          style: const TextStyle(
            color: AppColorstatic.lightTextColor,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppColorstatic.primary,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (event.cover != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    event.cover!,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      height: 180,
                      color: Colors.grey[200],
                      child: const Icon(Icons.broken_image, size: 60),
                    ),
                  ),
                ),
              ),

            // ✅ Carte infos
            EventInfoCard(event: event),

            // ✅ Carte description
            EventDescriptionCard(event: event),
          ],
        ),
      ),
    );
  }
}

class EventInfoCard extends StatelessWidget {
  final Event event;

  const EventInfoCard({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context);
    return BaseCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(
            icon: Icons.event,
            title: "event".tr(),
            iconColor: Colors.deepPurple,
          ),
          const SizedBox(height: 12),
          Text(
            event.getName(locale),
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),

          if (event.address != null && event.address!.isNotEmpty)
            Row(
              children: [
                const Icon(Icons.location_on, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    event.getAddress(locale),
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ),
              ],
            ),

          const SizedBox(height: 8),

          if (event.price != null)
            Text(event.price == "0"
                ? tr("free")
                : tr("price_with_currency", args: [event.price ?? ""]),
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.blueGrey,
              ),
            ),

          const SizedBox(height: 8),

          if (event.startDate != null && event.endDate != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.calendar_today, size: 16, color: AppColorstatic.primary2),
                  const SizedBox(width: 6),
                  Text(tr("from") + " ", style: const TextStyle(fontSize: 14, color: Colors.black)),
                  Text(
                    event.startDate!,
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.bold, color: AppColorstatic.primary),
                  ),
                  Text(" "+tr("to")+" ", style: const TextStyle(fontSize: 14, color: Colors.black)),
                  Text(
                    event.endDate!,
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.bold, color: AppColorstatic.primary),
                  ),
                ],
              ),

            ),

          const SizedBox(height: 16),

          SizedBox(
            width: double.infinity,
            child: TextButton.icon(
              onPressed: () {
                if (event.lat != null && event.lng != null) {
                  try {
                    final lat = double.parse(event.lat!);
                    final lng = double.parse(event.lng!);
                    final destination = LatLng(lat, lng);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ItineraryScreen(destination: destination),
                      ),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Invalid coordinates format")),
                    );
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Coordinates not available")),
                  );
                }
              },
              icon: const Icon(Icons.directions, size: 18),
              label: Text('itinerary'.tr()),
              style: TextButton.styleFrom(
                foregroundColor: AppColorstatic.primary,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}


class EventDescriptionCard extends StatelessWidget {
  final Event event;

  const EventDescriptionCard({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context);

    if (event.description == null || event.description!.isEmpty) {
      return const SizedBox.shrink();
    }

    return BaseCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
           SectionHeader(
            icon: Icons.description,
            title: "about".tr(),
            iconColor: Colors.green,
          ),
          const SizedBox(height: 12),
          Html(
            data: event.getDescription(locale),
            style: {
              "body": Style(
                fontSize: FontSize(16),
                lineHeight: LineHeight(1.5),
                color: Colors.black87,
              ),
            },
          ),
        ],
      ),
    );
  }
}

