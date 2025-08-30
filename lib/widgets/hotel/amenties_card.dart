import 'package:flutter/material.dart';
import '../../models/hotel_details.dart';
import '../section_header.dart';
import '../base_card.dart';

class HotelAmenitiesCard extends StatelessWidget {
  final HotelDetail hotel;

  const HotelAmenitiesCard({super.key, required this.hotel});

  @override
  Widget build(BuildContext context) {
    return BaseCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(
            icon: Icons.stars,
            title: 'Amenities',
            iconColor: Colors.purple[600]!,
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: hotel.bios.map((bio) => _buildAmenityChip(bio)).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildAmenityChip(bio) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: Colors.blue[100]!),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.check_circle, size: 16, color: Colors.blue[600]),
          const SizedBox(width: 8),
          Text(
            bio.nameEn,
            style: TextStyle(
              color: Colors.blue[800],
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}