import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:tunisiagotravel/theme/color.dart';
import '../models/activity.dart';
import '../widgets/gallery.dart';
import '../widgets/activity/activity_info_card.dart';
import '../widgets/activity/activity_description_card.dart';

class ActivityDetailsScreen extends StatelessWidget {
  final Activity activity;

  const ActivityDetailsScreen({super.key, required this.activity});

  @override
  Widget build(BuildContext context) {
    final locale = context.locale;
    final title = activity.getName(locale);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          title ?? '',
          style: const TextStyle(
            color: AppColorstatic.lightTextColor,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: AppColorstatic.primary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (activity.images != null && activity.images!.isNotEmpty)
              ImageGridPreview(images: activity.images!),

            const SizedBox(height: 12),
            ActivityInfoCard(activity: activity),
            ActivityDescriptionCard(activity: activity),
          ],
        ),
      ),
    );
  }
}
