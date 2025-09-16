import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
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
    // Pick preview text: HTML stripped or normal description
    final String? previewText = descriptionHtml != null
        ? _parseHtmlToPlainText(descriptionHtml!)
        : description;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              child: imageUrl.isNotEmpty
                  ? Image.network(
                imageUrl,
                width: double.infinity,
                height: 180,
                fit: BoxFit.cover,
              )
                  : Container(
                width: double.infinity,
                height: 180,
                color: Colors.grey[300],
                child: const Icon(Icons.photo, size: 40, color: Colors.white70),
              ),
            ),

            const SizedBox(height: 12),

            // Title
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                title,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),

            const SizedBox(height: 6),

            // Location
            if (subtitle != null && subtitle!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  children: [
                    const Icon(Icons.location_on, size: 16, color: Colors.redAccent),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        subtitle ?? "",
                        style: const TextStyle(fontSize: 14, color: Colors.black54),
                      ),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 6),

            // Description (preview, max 2 lines)
            if (previewText != null && previewText.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  previewText,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 14, color: Colors.black87),
                ),
              ),

            const SizedBox(height: 12),

            // Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 8),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: onTap,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColorstatic.buttonbg,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    "view_details".tr(),
                    style: TextStyle(
                      color: AppColorstatic.lightTextColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
