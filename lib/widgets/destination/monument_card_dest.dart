import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:tunisiagotravel/models/monument.dart';
import 'package:tunisiagotravel/screens/monument_details_screen.dart';

class MonumentCardDest extends StatelessWidget {
  final Monument monument;
  final double cardHeight;
  final double screenWidth;

  const MonumentCardDest({
    super.key,
    required this.monument,
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
            builder: (_) => MonumentDetailsScreen(monumentSlug: monument.slug),
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
            // Monument Image
            ClipRRect(
              borderRadius: BorderRadius.circular(screenWidth < 600 ? 12 : 16),
              child: CachedNetworkImage(
                imageUrl: monument.cover,
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
                    Icons.account_balance,
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
            // Monument Info
            Positioned(
              left: screenWidth < 600 ? 12 : 16,
              bottom: screenWidth < 600 ? 12 : 16,
              right: screenWidth < 600 ? 12 : 16,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Monument Name
                  Text(
                    monument.getName(Localizations.localeOf(context)),
                    style: TextStyle(
                      fontSize: screenWidth < 600 ? 14 : 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  // Monument Categories
                  if (monument.categories.isNotEmpty)
                    Row(
                      children: [
                        Icon(
                          Icons.category,
                          size: screenWidth < 600 ? 12 : 14,
                          color: Colors.white.withOpacity(0.8),
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            monument.getCategories(Localizations.localeOf(context)),
                            style: TextStyle(
                              fontSize: screenWidth < 600 ? 10 : 12,
                              color: Colors.white.withOpacity(0.8),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
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