import 'package:flutter/material.dart';
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
    final imageUrl = maison.cover.isNotEmpty
        ? maison.cover
        : (maison.images.isNotEmpty ? maison.images.first : null);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      elevation: 4,
      shadowColor: Colors.black.withOpacity(0.1),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image with gradient overlay
          Stack(
            children: [
              if (imageUrl != null)
                Image.network(
                  imageUrl,
                  height: 150,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(
                      height: 150,
                      color: Colors.grey[200],
                      child: const Center(
                        child: CircularProgressIndicator(),
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 150,
                      color: Colors.grey[200],
                      child: const Center(
                        child: Icon(Icons.home,
                            size: 50, color: Colors.grey),
                      ),
                    );
                  },
                )
              else
                Container(
                  height: 150,
                  color: Colors.grey[200],
                  child: const Center(
                    child: Icon(Icons.home, size: 50, color: Colors.grey),
                  ),
                ),

              // Gradient overlay at bottom
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

              // Special tag if maison is special
              if (maison.isSpecial == 'true')
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.redAccent,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'Spécial',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),

          // Content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Maison name
                Text(
                  maison.name,
                  maxLines: 2,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Colors.black87,
                  ),
                ),

                const SizedBox(height: 8),

                // Rating and price row
                Row(
                  children: [
                    Icon(
                      Icons.star,
                      color: Colors.amber[700],
                      size: 18,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      maison.noteGoogle.isNotEmpty ? maison.noteGoogle : '0.0',
                      style: TextStyle(
                        color: Colors.grey[800],
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      maison.startingPrice > 0
                          ? '${maison.startingPrice.toStringAsFixed(0)} TND'
                          : '',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.blueGrey[900],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Location
                Row(
                  children: [
                    Icon(
                      Icons.location_on,
                      size: 16,
                      color: AppColorstatic.primary,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        maison.ville,
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

                // Action buttons
                Row(
                  children: [
                    // Details button
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

                    // Itinerary button
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