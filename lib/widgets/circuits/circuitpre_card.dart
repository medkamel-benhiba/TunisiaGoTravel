import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/voyage.dart';
import '../../screens/circuitPre_details_screen.dart';
import 'package:tunisiagotravel/theme/color.dart';
import 'package:easy_localization/easy_localization.dart'; // Add this

class CircuitPreCard extends StatelessWidget {
  final Voyage voyage;

  const CircuitPreCard({super.key, required this.voyage});

  @override
  Widget build(BuildContext context) {
    final imageUrl = voyage.images.isNotEmpty
        ? voyage.images.first
        : 'https://via.placeholder.com/300';

    final locale = context.locale; // Get current locale

    return LayoutBuilder(
      builder: (context, constraints) {
        final isSmallScreen = constraints.maxWidth < 350;
        final imageHeight = isSmallScreen ? 140.0 : 180.0;
        final horizontalPadding = isSmallScreen ? 8.0 : 12.0;
        final buttonHorizontalPadding = isSmallScreen ? 24.0 : 50.0;
        final titleFontSize = isSmallScreen ? 16.0 : 18.0;
        final subtitleFontSize = isSmallScreen ? 12.0 : 14.0;
        final descriptionFontSize = isSmallScreen ? 12.0 : 14.0;

        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => CircuitPreDetailsScreen(voyageId: voyage.id),
              ),
            );
          },
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 8),
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
                  child: Image.network(
                    imageUrl,
                    height: imageHeight,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(height: 12),
                // Name
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                  child: Text(
                    voyage.getName(locale),
                    style: TextStyle(
                      fontSize: titleFontSize,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(height: 6),
                // Duration & Price
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${tr("Duration")}: ${voyage.programe.length} ${tr("days")}',
                        style: TextStyle(
                          fontSize: subtitleFontSize,
                          fontWeight: FontWeight.w500,
                          color: Colors.black54,
                        ),
                      ),
                      Text(
                        '${tr("price")}: \$${voyage.price.isNotEmpty ? voyage.price.first.price : 'N/A'}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 6),
                // Description
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                  child: Text(
                    voyage.getDescription(locale),
                    style: TextStyle(
                      fontSize: descriptionFontSize,
                      color: Colors.black87,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(height: 12),
                // Button
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: buttonHorizontalPadding, vertical: 8),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => CircuitPreDetailsScreen(voyageId: voyage.id),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColorstatic.buttonbg,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        tr("view_details"),
                        style: TextStyle(
                          color: AppColorstatic.lightTextColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        );
      },
    );
  }
}
