import 'package:flutter/material.dart';
import '../models/activity.dart';
import '../screens/activity_details_screen.dart';

class ActivityCard extends StatelessWidget {
  final Activity activity;

  const ActivityCard({super.key, required this.activity});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ActivityDetailsScreen(activity: activity),
          ),
        );
      },
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 3,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              child: activity.cover != null
                  ? Image.network(
                activity.cover!,
                height: 150,
                width: double.infinity,
                fit: BoxFit.cover,
              )
                  : Container(
                height: 140,
                color: Colors.grey[300],
                child: const Icon(Icons.local_activity, size: 50),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    activity.title,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.location_on, size: 14, color: Colors.grey),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          activity.address ?? 'Adresse non disponible',
                          style: const TextStyle(fontSize: 12, color: Colors.grey),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      if (activity.rate != null)
                        Row(
                          children: [
                            const Icon(Icons.star, size: 14, color: Colors.orange),
                            const SizedBox(width: 4),
                            Text(
                              activity.rate!.toStringAsFixed(1),
                              style: const TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                      const Spacer(),
                      if (activity.price != null && activity.price != "0")
                        Text(
                          'À partir de ${activity.price} TND',
                          style: const TextStyle(
                              fontSize: 12, fontWeight: FontWeight.w500),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
