import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:tunisiagotravel/models/musee.dart';
import 'package:tunisiagotravel/screens/musee_details_screen.dart';

class MuseesCardDest extends StatelessWidget {
  final Musees musees;
  final double cardHeight;
  final double screenWidth;

  const MuseesCardDest({
    super.key,
    required this.musees,
    required this.cardHeight,
    required this.screenWidth,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => MuseeDetailsScreen(museeSlug: musees.slug),
          ),
        );
      },
      child: Container(
        height: cardHeight,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(screenWidth < 600 ? 12 : 16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: screenWidth < 600 ? 6 : 10,
              offset: Offset(0, screenWidth < 600 ? 2 : 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Museum Image
            ClipRRect(
              borderRadius: BorderRadius.circular(screenWidth < 600 ? 12 : 16),
              child: CachedNetworkImage(
                imageUrl: musees.cover,
                width: double.infinity,
                height: double.infinity,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: Colors.grey.shade200,
                  child: const Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  color: Colors.grey.shade200,
                  child: Icon(
                    Icons.museum,
                    color: Colors.grey.shade400,
                    size: screenWidth < 600 ? 30 : 40,
                  ),
                ),
              ),
            ),
            // Gradient overlay
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(screenWidth < 600 ? 12 : 16),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.6),
                  ],
                ),
              ),
            ),
            // Museum Info
            Positioned(
              left: screenWidth < 600 ? 12 : 16,
              bottom: screenWidth < 600 ? 12 : 16,
              right: screenWidth < 600 ? 12 : 16,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Museum Name
                  Text(
                    musees.getName(Localizations.localeOf(context)),
                    style: TextStyle(
                      fontSize: screenWidth < 600 ? 14 : 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}