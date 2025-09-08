import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import '../../models/maisondHote.dart';
import '../base_card.dart';
import '../section_header.dart';
import '../../screens/ItineraryScreen.dart';

class MaisonInfoCard extends StatelessWidget {
  final MaisonDHote maison;

  const MaisonInfoCard({super.key, required this.maison});

  @override
  Widget build(BuildContext context) {
    return BaseCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(
            icon: Icons.home,
            title: "Maison D'hôte",
            iconColor: Colors.deepPurple[600]!,
          ),
          const SizedBox(height: 16),
          Text(
            maison.name,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            maison.address,
            style: TextStyle(fontSize: 16, color: Colors.grey[700]),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.star, color: Colors.amber[700], size: 18),
                  const SizedBox(width: 4),
                  Text(
                    maison.noteGoogle.isNotEmpty ? maison.noteGoogle : '',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[800],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              Text(
                maison.startingPrice > 0
                    ? '${maison.startingPrice.toStringAsFixed(2)} TND'
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

          // ✅ Bouton Itinéraire
          SizedBox(
            width: double.infinity,
            child: TextButton.icon(
              onPressed: () {
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
              label: const Text('Itinéraire'),
              style: TextButton.styleFrom(
                foregroundColor: Colors.deepPurple[600],
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
