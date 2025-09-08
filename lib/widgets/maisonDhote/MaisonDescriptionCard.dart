import 'package:flutter/material.dart';
import '../../models/maisondHote.dart';
import 'package:flutter_html/flutter_html.dart';

import '../base_card.dart';
import '../section_header.dart';

class MaisonDescriptionCard extends StatelessWidget {
  final MaisonDHote maison;

  const MaisonDescriptionCard({super.key, required this.maison});

  @override
  Widget build(BuildContext context) {
    if (maison.description.isEmpty) return const SizedBox.shrink();

    return BaseCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(
            icon: Icons.description,
            title: 'À propos',
            iconColor: Colors.green[600]!,
          ),
          const SizedBox(height: 16),
          Html(
            data: maison.description,
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
