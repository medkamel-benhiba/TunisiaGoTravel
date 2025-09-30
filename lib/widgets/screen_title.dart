import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../theme/color.dart';

class ScreenTitle extends StatelessWidget {
  final IconData? icon;
  final String? imagePath;
  final String title;
  final VoidCallback? onTrailingTap;
  final IconData? trailingIcon;

  const ScreenTitle({
    super.key,
    this.icon,
    this.imagePath,
    required this.title,
    this.onTrailingTap,
    this.trailingIcon,
  }) : assert(
  (icon != null && imagePath == null) || (icon == null && imagePath != null),
  'Either icon or imagePath must be provided, but not both.',
  );

  @override
  Widget build(BuildContext context) {
    final locale = context.locale;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColorstatic.primary, AppColorstatic.secondary.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              if (icon != null)
                Icon(icon, color: Colors.white),
              const SizedBox(width: 8),
              Text(
                title.tr(), // Localized string
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          if (trailingIcon != null)
            IconButton(
              icon: Icon(trailingIcon, color: Colors.white),
              onPressed: onTrailingTap,
              tooltip: 'Historique',
            ),
        ],
      ),
    );
  }
}