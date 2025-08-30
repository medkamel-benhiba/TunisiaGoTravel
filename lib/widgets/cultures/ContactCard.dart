import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactCard extends StatelessWidget {
  final double lat;
  final double lng;
  final String phone;
  final String email;

  const ContactCard({
    super.key,
    required this.lat,
    required this.lng,
    this.phone = '',
    this.email = '',
  });

  void _launchMaps() async {
    final url = 'https://www.google.com/maps/search/?api=1&query=$lat,$lng';
    if (await canLaunch(url)) await launch(url);
  }

  void _callPhone() async {
    if (phone.isNotEmpty) {
      final url = 'tel:$phone';
      if (await canLaunch(url)) await launch(url);
    }
  }

  void _sendEmail() async {
    if (email.isNotEmpty) {
      final url = 'mailto:$email';
      if (await canLaunch(url)) await launch(url);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (lat != 0 && lng != 0)
              TextButton.icon(
                onPressed: _launchMaps,
                icon: const Icon(Icons.location_on),
                label: const Text('Voir sur la carte'),
              ),
            if (phone.isNotEmpty)
              TextButton.icon(
                onPressed: _callPhone,
                icon: const Icon(Icons.phone),
                label: Text(phone),
              ),
            if (email.isNotEmpty)
              TextButton.icon(
                onPressed: _sendEmail,
                icon: const Icon(Icons.email),
                label: Text(email),
              ),
          ],
        ),
      ),
    );
  }
}
