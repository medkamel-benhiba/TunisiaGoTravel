import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:tunisiagotravel/models/activity.dart';
import 'package:tunisiagotravel/screens/activity_details_screen.dart';

class ActivityCardDest extends StatelessWidget {
  final Activity activity;
  final double cardHeight;
  final double screenWidth;

  const ActivityCardDest({
    super.key,
    required this.activity,
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
            builder: (_) => ActivityDetailsScreen(activity: activity),
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
            // Activity Image
            ClipRRect(
              borderRadius: BorderRadius.circular(screenWidth < 600 ? 12 : 16),
              child: CachedNetworkImage(
                imageUrl: activity.cover ?? '',
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
                    Icons.local_activity,
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
            // Activity Info
            Positioned(
              left: screenWidth < 600 ? 12 : 16,
              bottom: screenWidth < 600 ? 12 : 16,
              right: screenWidth < 600 ? 12 : 16,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Activity Name
                  Text(
                    activity.getName(Localizations.localeOf(context)),
                    style: TextStyle(
                      fontSize: screenWidth < 600 ? 14 : 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  // Activity Subtype
                  if (activity.subtype != null && activity.subtype!.isNotEmpty)
                    Row(
                      children: [
                        Icon(
                          Icons.category,
                          size: screenWidth < 600 ? 12 : 14,
                          color: Colors.white.withOpacity(0.8),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          activity.getSubtype(Localizations.localeOf(context)),
                          style: TextStyle(
                            fontSize: screenWidth < 600 ? 10 : 12,
                            color: Colors.white.withOpacity(0.8),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  const SizedBox(height: 4),
                  // Activity Location
                  if (activity.address != null && activity.address!.isNotEmpty)
                    Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          size: screenWidth < 600 ? 12 : 14,
                          color: Colors.white.withOpacity(0.8),
                        ),
                        const SizedBox(width: 2),
                        Expanded(
                          child: Text(
                            activity.getAddress(Localizations.localeOf(context)),
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