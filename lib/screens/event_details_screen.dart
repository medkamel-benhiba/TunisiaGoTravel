import 'package:flutter/material.dart';
import '../models/event.dart';
import '../widgets/screen_title.dart';

class EventDetailsScreen extends StatelessWidget {
  final Event event;

  const EventDetailsScreen({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(event.title)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (event.cover != null)
              Image.network(event.cover!, width: double.infinity, fit: BoxFit.cover),
            const SizedBox(height: 12),
            Text(event.title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(event.description ?? '', style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 12),
            if (event.address != null)
              Text('Adresse: ${event.address}', style: const TextStyle(fontSize: 16)),
            if (event.price != null)
              Text('Prix: ${event.price}', style: const TextStyle(fontSize: 16)),
            if (event.startDate != null && event.endDate != null)
              Text('Date: ${event.startDate} - ${event.endDate}', style: const TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }
}
