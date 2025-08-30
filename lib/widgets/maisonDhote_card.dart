import 'package:flutter/material.dart';
import '../models/maisondHote.dart';
import '../screens/maisonDhote_details_screen.dart';

class MaisonCard extends StatelessWidget {
  final MaisonDHote maison;

  const MaisonCard({super.key, required this.maison});

  @override
  Widget build(BuildContext context) {
    final imageUrl = maison.cover.isNotEmpty
        ? maison.cover
        : (maison.images.isNotEmpty ? maison.images.first : null);

    return LayoutBuilder(
      builder: (context, constraints) {
        final isSmallScreen = constraints.maxWidth < 350;
        final imageHeight = isSmallScreen ? 140.0 : 155.0;
        final overlayHeight = isSmallScreen ? 50.0 : 60.0;
        final paddingHorizontal = isSmallScreen ? 8.0 : 12.0;
        final paddingVertical = isSmallScreen ? 8.0 : 10.0;
        final titleFontSize = isSmallScreen ? 16.0 : 18.0;
        final subtitleFontSize = isSmallScreen ? 12.0 : 14.0;
        final noteFontSize = isSmallScreen ? 12.0 : 14.0;
        final priceFontSize = isSmallScreen ? 12.0 : 14.0;

        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => MaisonDetailsScreen(maison: maison),
              ),
            );
          },
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 6,
            shadowColor: Colors.black.withOpacity(0.1),
            clipBehavior: Clip.hardEdge,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  children: [
                    imageUrl != null
                        ? Image.network(
                      imageUrl,
                      height: imageHeight,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, progress) {
                        if (progress == null) return child;
                        return Container(
                          height: imageHeight,
                          color: Colors.grey[200],
                          child: const Center(
                            child: CircularProgressIndicator(),
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) =>
                          Container(
                            height: imageHeight,
                            color: Colors.grey[200],
                            child: const Icon(Icons.broken_image, size: 50),
                          ),
                    )
                        : Container(
                      height: imageHeight,
                      width: double.infinity,
                      color: Colors.grey[200],
                      child: Icon(
                        Icons.home,
                        size: 50,
                        color: Colors.grey[500],
                      ),
                    ),
                    // Gradient overlay
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        height: overlayHeight,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: [
                              Colors.black.withOpacity(0.4),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    ),
                    // Special tag
                    if (maison.isSpecial == 'true')
                      Positioned(
                        top: 8,
                        left: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.redAccent,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'Special',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                // Maison info
                Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: paddingHorizontal, vertical: paddingVertical),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        maison.name,
                        style: TextStyle(
                          fontSize: titleFontSize,
                          fontWeight: FontWeight.w700,
                          color: Colors.black87,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: paddingVertical / 2),
                      Text(
                        maison.ville,
                        style: TextStyle(
                          fontSize: subtitleFontSize,
                          color: Colors.grey[700],
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      SizedBox(height: paddingVertical),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.star,
                                color: Colors.amber[700],
                                size: noteFontSize + 4,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                maison.noteGoogle.isNotEmpty
                                    ? maison.noteGoogle
                                    : '0.0',
                                style: TextStyle(
                                  fontSize: noteFontSize,
                                  color: Colors.grey[800],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: paddingVertical),
                          Text(
                            maison.startingPrice > 0
                                ? '${maison.startingPrice.toStringAsFixed(2)} TND'
                                : 'Prix non disponible',
                            style: TextStyle(
                              fontSize: priceFontSize,
                              fontWeight: FontWeight.w600,
                              color: Colors.blueGrey[900],
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
      },
    );
  }
}
