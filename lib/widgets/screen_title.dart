import 'package:flutter/material.dart';
import '../theme/color.dart';

class ScreenTitle extends StatelessWidget {
  final IconData? icon; // Optional IconData
  final String? imagePath; // Optional image path
  final String title;

  const ScreenTitle({
    super.key,
    this.icon,
    this.imagePath,
    required this.title,
  }) : assert(
  (icon != null && imagePath == null) || (icon == null && imagePath != null),
  'Either icon or imagePath must be provided, but not both.',
  );

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
          if (icon != null)
            Icon(icon, color: Colors.white)
          else if (imagePath != null)
            Image.asset(
              imagePath!,
              width: 24,
              height: 24,
              fit: BoxFit.contain,
            ),
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