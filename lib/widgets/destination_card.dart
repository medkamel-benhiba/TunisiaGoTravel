import 'package:flutter/material.dart';
import '../models/destination.dart';

class DestinationCard extends StatelessWidget {
  final Destination destination;
  final VoidCallback onTap;

  const DestinationCard({super.key, required this.destination, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        margin: const EdgeInsets.only(bottom: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        clipBehavior: Clip.antiAlias,
        elevation: 3,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (destination.cover != null)
              Image.network(
                destination.cover.toString(),
                height: 180,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Text(
                destination.name,
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.w600)
              ),
            ),
          ],
        ),
      ),
    );
  }
}
