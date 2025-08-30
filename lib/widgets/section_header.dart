
import 'package:flutter/material.dart';

class SectionHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color iconColor;

  const SectionHeader({
    super.key,
    required this.icon,
    required this.title,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            size: 18,
            color: iconColor,
          ),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
            color: Colors.grey[800],
          ),
        ),
      ],
    );
  }
}