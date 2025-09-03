import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import '../../models/hotel_details.dart';
import '../base_card.dart';
import '../section_header.dart';

class HotelDescriptionCard extends StatelessWidget {
  final HotelDetail hotel;

  const HotelDescriptionCard({super.key, required this.hotel});

  @override
  Widget build(BuildContext context) {
    return BaseCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(
            icon: Icons.description,
            title: "À propos de l'hôtel",
            iconColor: Colors.green[600]!,
          ),
          const SizedBox(height: 16),
          Html(
            data: hotel.description,
            style: {
              "body": Style(
                margin: Margins.zero,
                fontSize: FontSize(16),
                lineHeight: const LineHeight(1.5),
                color: Colors.grey[700],
              ),
            },
          ),
        ],
      ),
    );
  }
}