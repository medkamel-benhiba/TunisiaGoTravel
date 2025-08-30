import 'package:flutter/material.dart';
import '../../theme/color.dart';
import 'ItemCard.dart';

class SectionWidget extends StatelessWidget {
  final String title;
  final List items;
  const SectionWidget({super.key, required this.title, required this.items});

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'hôtels':
        return AppColorstatic.primary85;
      case 'restaurants':
        return AppColorstatic.primary2.withOpacity(0.6);
      case 'activités':
        return AppColorstatic.secondary;
      case 'musées':
        return AppColorstatic.buttonbg;
      case 'monuments':
        return AppColorstatic.appBgColor;
      default:
        return AppColorstatic.primary;
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'hôtels':
        return Icons.hotel;
      case 'restaurants':
        return Icons.restaurant;
      case 'activités':
        return Icons.local_activity;
      case 'musées':
        return Icons.museum;
      case 'monuments':
        return Icons.account_balance;
      default:
        return Icons.place;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox();

    final color = _getCategoryColor(title);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Container(
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [color, color.withOpacity(0.8)],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Icon(_getCategoryIcon(title), color: Colors.white),
              const SizedBox(width: 12),
              Text(
                "$title (${items.length})",
                style: const TextStyle(
                    fontWeight: FontWeight.bold, color: Colors.white, fontSize: 16),
              ),
            ],
          ),
        ),

        // Items
        ...items.map((item) => ItemCard(item: Map<String, dynamic>.from(item), categoryColor: color)),
      ],
    );
  }
}
