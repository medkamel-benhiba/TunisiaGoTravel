import 'package:flutter/material.dart';

class EmptyStateWidget extends StatelessWidget {
  final String title;
  final String message;
  final IconData icon;
  final Color? iconColor;

  const EmptyStateWidget({
    super.key,
    required this.title,
    required this.message,
    this.icon = Icons.hotel_outlined,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: (iconColor ?? Colors.blue[400])!.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 48,
                color: iconColor ?? Colors.blue[400],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }
}