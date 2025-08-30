import 'package:flutter/material.dart';
import '../models/maisondHote.dart';
import '../theme/color.dart';
import '../widgets/gallery.dart';
import '../widgets/maisonDhote/MaisonContactCard.dart';
import '../widgets/maisonDhote/MaisonDescriptionCard.dart';
import '../widgets/maisonDhote/MaisonInfoCard.dart';

class MaisonDetailsScreen extends StatelessWidget {
  final MaisonDHote maison;

  const MaisonDetailsScreen({super.key, required this.maison});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          maison.name,
          style: TextStyle(color: AppColorstatic.lightTextColor),
        ),
        backgroundColor: AppColorstatic.primary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image grid preview
            if (maison.images.isNotEmpty)
              ImageGridPreview(images: maison.images),
            const SizedBox(height: 10),
            MaisonInfoCard(maison: maison),
            MaisonDescriptionCard(maison: maison),
            MaisonContactCard(maison: maison),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
