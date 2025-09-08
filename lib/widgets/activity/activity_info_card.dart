import 'package:flutter/material.dart';
import 'package:tunisiagotravel/theme/color.dart';
import 'package:tunisiagotravel/theme/styletext.dart';
import '../../models/activity.dart';
import '../../screens/ItineraryScreen.dart';
import '../base_card.dart';
import '../section_header.dart';
import 'package:latlong2/latlong.dart';

class ActivityInfoCard extends StatelessWidget {
  final Activity activity;

  const ActivityInfoCard({super.key, required this.activity});

  @override
  Widget build(BuildContext context) {
    return BaseCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(
            icon: Icons.local_activity,
            title: 'Activité',
            iconColor: Colors.deepPurple[600]!,
          ),
          const SizedBox(height: 16),
          Text(
            activity.title ?? '',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.location_on, size: 14, color: Colors.grey),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  activity.address ?? '',
                  style: Appstylestatic.textStyle21,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          if (activity.subtype != null && activity.subtype!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(
                activity.subtype!,
                style: TextStyle(fontSize: 16, color: Colors.grey[700]),
              ),
            ),
          const SizedBox(height: 12),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (activity.rate != null)
                Row(
                  children: [
                    Icon(Icons.star, color: Colors.amber[700], size: 18),
                    const SizedBox(width: 4),
                    Text(
                      activity.rate!.toStringAsFixed(1),
                      style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[800],
                          fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              Text(
                activity.price != null
                    ? (activity.price == "0"
                    ? 'Gratuit'
                    : 'À partir de ${activity.price} TND')
                    : 'Prix non disponible',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.blueGrey[900],
                ),
              ),
            ],
          ),

          // Itinerary Button
          if (activity.lat != null && activity.lng != null)
            SizedBox(
              width: double.infinity,
              child: TextButton.icon(
                onPressed: () {
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
                      const SnackBar(content: Text("Format des coordonnées invalide")),
                    );
                  }
                },
                icon: const Icon(Icons.directions, size: 18),
                label: const Text('Itinéraire'),
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
