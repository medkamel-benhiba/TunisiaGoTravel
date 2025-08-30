import 'package:flutter/material.dart';
import '../../models/maisondHote.dart';
import '../base_card.dart';
import '../section_header.dart';

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
            title: 'Maison Info',
            iconColor: Colors.deepPurple[600]!,
          ),
          const SizedBox(height: 16),
          Text(
            maison.name,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            maison.ville,
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
                    maison.noteGoogle.isNotEmpty ? maison.noteGoogle : '0.0',
                    style: TextStyle(
                        fontSize: 14, color: Colors.grey[800], fontWeight: FontWeight.w500),
                  ),
                ],
              ),
              Text(
                maison.startingPrice > 0
                    ? '${maison.startingPrice.toStringAsFixed(2)} TND'
                    : 'Prix non disponible',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.blueGrey[900],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
