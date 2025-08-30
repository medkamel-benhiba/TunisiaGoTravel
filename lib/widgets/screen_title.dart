import 'package:flutter/material.dart';
import '../theme/color.dart';

class ScreenTitle extends StatelessWidget {
  final IconData icon;
  final String title;

  const ScreenTitle({
    super.key,
    required this.icon,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColorstatic.primary,
        borderRadius: BorderRadius.circular(12),
        ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white),
          const SizedBox(width: 8),
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
