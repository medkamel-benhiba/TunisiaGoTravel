import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:tunisiagotravel/theme/color.dart';
import 'package:html/parser.dart' as html_parser;

class ItemTile extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String? description;        // Optional plain text
  final String? descriptionHtml;    // Optional HTML string
  final String imageUrl;
  final VoidCallback onTap;

  const ItemTile({
    super.key,
    required this.title,
    this.subtitle,
    this.description,
    this.descriptionHtml,
    required this.imageUrl,
    required this.onTap,
  });

  // Convert HTML to plain text for preview
  String _parseHtmlToPlainText(String htmlString) {
    final document = html_parser.parse(htmlString);
    return document.body?.text ?? "";
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    // Pick preview text: HTML stripped or normal description
    final String? previewText = descriptionHtml != null
        ? _parseHtmlToPlainText(descriptionHtml!)
        : description;

    // Responsive card height
    double cardHeight;
    if (screenWidth < 600) {
      cardHeight = 170; // Mobile
    } else if (screenWidth < 900) {
      cardHeight = 190; // Small tablet
    } else if (screenWidth < 1200) {
      cardHeight = 210; // Large tablet
    } else {
      cardHeight = 220; // Desktop
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: cardHeight,
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(screenWidth < 600 ? 12 : 16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: screenWidth < 600 ? 6 : 10,
              offset: Offset(0, screenWidth < 600 ? 2 : 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Background image
            ClipRRect(
              borderRadius: BorderRadius.circular(screenWidth < 600 ? 12 : 16),
              child: CachedNetworkImage(
                imageUrl: imageUrl,
                width: double.infinity,
                height: double.infinity,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: Colors.grey[200],
                  child: const Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  color: Colors.grey[200],
                  child: Center(
                    child: Icon(
                      Icons.photo,
                      size: screenWidth < 600 ? 30 : 40,
                      color: Colors.grey,
                    ),
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
                    AppColorstatic.mainColor.withOpacity(0.7),
                  ],
                ),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(screenWidth < 600 ? 12 : 16),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    AppColorstatic.primary.withOpacity(0.6),
                  ],
                ),
              ),
            ),
            // Title
            Positioned(
              left: screenWidth < 600 ? 12 : 16,
              bottom: screenWidth < 600 ? 45 : 55,
              right: screenWidth < 600 ? 12 : 16,
              child: Text(
                title,
                style: TextStyle(
                  fontSize: screenWidth < 600 ? 14 : 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                maxLines: screenWidth < 600 ? 2 : 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            // Description and subtitle
            Positioned(
              left: screenWidth < 600 ? 12 : 16,
              bottom: screenWidth < 600 ? 25 : 35,
              right: screenWidth < 600 ? 12 : 16,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Subtitle (address)
                  if (subtitle != null && subtitle!.isNotEmpty)
                    Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          size: screenWidth < 600 ? 14 : 16,
                          color: AppColorstatic.primary2,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            subtitle!,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: screenWidth < 600 ? 10 : 12,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 2,
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