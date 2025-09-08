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
          const SnackBar(content: Text("Format de coordonnées invalide")),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Coordonnées non disponibles")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      elevation: 4,
      shadowColor: Colors.black.withOpacity(0.1),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image avec overlay
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
                      child: const Center(
                        child: CircularProgressIndicator(),
                      ),
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

          // Contenu
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Nom de l’activité
                Text(
                  activity.title,
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
                        'À partir de ${activity.price} TND',
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
                        activity.address ?? 'Adresse non disponible',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                          fontSize: 13,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Boutons d’action
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _navigateToDetails(context),
                        icon: const Icon(Icons.info_outline, size: 16),
                        label: const Text('Détails'),
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
                        label: const Text('Itinéraire'),
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
