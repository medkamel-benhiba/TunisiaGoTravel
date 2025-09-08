import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import '../../models/activity.dart';
import '../base_card.dart';
import '../section_header.dart';

class ActivityDescriptionCard extends StatelessWidget {
  final Activity activity;

  const ActivityDescriptionCard({super.key, required this.activity});

  @override
  Widget build(BuildContext context) {
    if (activity.description == null || activity.description!.isEmpty) {
      return const SizedBox.shrink();
    }

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
            data: activity.description!,
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
