import 'package:flutter/material.dart';
import '../../models/restaurant.dart';
import 'package:flutter_html/flutter_html.dart';
import '../base_card.dart';
import '../section_header.dart';

class RestaurantDescriptionCard extends StatelessWidget {
  final Restaurant restaurant;

  const RestaurantDescriptionCard({super.key, required this.restaurant});

  @override
  Widget build(BuildContext context) {
    if (restaurant.crtDescription == null || restaurant.crtDescription!.isEmpty) {
      return const SizedBox.shrink();
    }

    return BaseCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(
            icon: Icons.description,
            title: 'About this Restaurant',
            iconColor: Colors.green[600]!,
          ),
          const SizedBox(height: 16),
          Html(
            data: restaurant.crtDescription!,
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
