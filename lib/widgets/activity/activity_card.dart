import 'package:easy_localization/easy_localization.dart'; // Ajout
import 'package:flutter/material.dart';
import 'package:tunisiagotravel/theme/color.dart';
import '../../models/activity.dart';
import '../../screens/activity_details_screen.dart';
import '../../screens/ItineraryScreen.dart';
import 'package:latlong2/latlong.dart';

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
          SnackBar(content: Text(tr("invalid_coordinates"))),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(tr("coordinates_unavailable"))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final locale = context.locale;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      elevation: 4,
      shadowColor: Colors.black.withOpacity(0.1),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- IMAGE ---
          Stack(
            children: [
              if (activity.cover != null)
                Image.network(
                  activity.cover!,
                  height: 180,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(
                      height: 180,
                      color: Colors.grey[200],
                      child: const Center(child: CircularProgressIndicator()),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 180,
                      color: Colors.grey[200],
                      child: const Center(
                        child: Icon(Icons.local_activity,
                            size: 50, color: Colors.grey),
                      ),
                    );
                  },
                )
              else
                Container(
                  height: 180,
                  color: Colors.grey[200],
                  child: const Center(
                    child: Icon(Icons.local_activity,
                        size: 50, color: Colors.grey),
                  ),
                ),

              // Dégradé en bas
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  height: 60,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.3),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),

          // --- CONTENU ---
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Nom
                Text(
                  activity.getName(locale),
                  maxLines: 2,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Colors.black87,
                  ),
                ),

                const SizedBox(height: 8),

                // Note + Prix
                Row(
                  children: [
                    Icon(Icons.star, color: Colors.amber[700], size: 18),
                    const SizedBox(width: 4),
                    Text(
                      activity.rate != null
                          ? activity.rate!.toStringAsFixed(1)
                          : 'N/A',
                      style: TextStyle(
                        color: Colors.grey[800],
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Spacer(),
                    if (activity.price != null && activity.price != "0")
                      Text(
                        tr("starting_price_tnd",
                            args: [activity.price.toString()]),
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.blueGrey[900],
                        ),
                      ),
                  ],
                ),

                const SizedBox(height: 12),

                // Adresse
                Row(
                  children: [
                    Icon(Icons.location_on,
                        size: 16, color: AppColorstatic.primary),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        activity.getAddress(locale).isNotEmpty
                            ? activity.getAddress(locale)
                            : tr("address_unavailable"),
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(color: Colors.grey[600], fontSize: 13),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Boutons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _navigateToDetails(context),
                        icon: const Icon(Icons.info_outline, size: 16),
                        label: Text(tr("details")),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColorstatic.primary,
                          side: BorderSide(color: AppColorstatic.primary),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _handleItinerary(context),
                        icon: const Icon(Icons.directions, size: 16),
                        label: Text(tr("itinerary")),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColorstatic.primary,
                          foregroundColor: Colors.white,
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
