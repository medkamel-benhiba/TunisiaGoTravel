import 'package:flutter/material.dart';
import '../models/activity.dart';
import '../widgets/gallery.dart';

class ActivityDetailsScreen extends StatelessWidget {
  final Activity activity;
  final String locale; // e.g., 'en', 'ar', 'ru', 'zh', etc.

  const ActivityDetailsScreen({
    super.key,
    required this.activity,
    this.locale = 'en',
  });

  // Helper to get translated field
  String? getLocalizedTitle() {
    switch (locale) {
      case 'ar':
        return activity.titleAr ?? activity.title;
      case 'ru':
        return activity.titleRu ?? activity.title;
      case 'zh':
        return activity.titleZh ?? activity.title;
      case 'ko':
        return activity.titleKo ?? activity.title;
      case 'ja':
        return activity.titleJa ?? activity.title;
      case 'en':
      default:
        return activity.titleEn ?? activity.title;
    }
  }

  String? getLocalizedDescription() {
    switch (locale) {
      case 'ar':
        return activity.descriptionAr ?? activity.description;
      case 'ru':
        return activity.descriptionRu ?? activity.description;
      case 'zh':
        return activity.descriptionZh ?? activity.description;
      case 'ko':
        return activity.descriptionKo ?? activity.description;
      case 'ja':
        return activity.descriptionJa ?? activity.description;
      case 'en':
      default:
        return activity.descriptionEn ?? activity.description;
    }
  }

  String? getLocalizedAddress() {
    switch (locale) {
      case 'ar':
        return activity.addressAr ?? activity.address;
      case 'ru':
        return activity.addressRu ?? activity.address;
      case 'zh':
        return activity.addressZh ?? activity.address;
      case 'ko':
        return activity.addressKo ?? activity.address;
      case 'ja':
        return activity.addressJa ?? activity.address;
      case 'en':
      default:
        return activity.addressEn ?? activity.address;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(getLocalizedTitle() ?? ''),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cover image or first image
            GestureDetector(
              onTap: () {
                if (activity.images != null && activity.images!.isNotEmpty) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => FullScreenGallery(
                        images: activity.images!,
                      ),
                    ),
                  );
                }
              },
              child: Container(
                height: 200,
                color: Colors.grey[300],
                child: activity.cover != null
                    ? Image.network(
                  activity.cover!,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  errorBuilder: (context, error, stackTrace) =>
                  const Icon(Icons.broken_image, size: 50),
                )
                    : activity.images != null && activity.images!.isNotEmpty
                    ? Image.network(
                  activity.images!.first,
                  fit: BoxFit.cover,
                  width: double.infinity,
                )
                    : const Icon(Icons.broken_image, size: 50),
              ),
            ),

            const SizedBox(height: 16),

            // Title
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                getLocalizedTitle() ?? '',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 8),

            // Subtype
            if (activity.subtype != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  activity.subtype!,
                  style: const TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ),

            const SizedBox(height: 8),

            // Rate & Price
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  if (activity.rate != null)
                    Row(
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 20),
                        const SizedBox(width: 4),
                        Text('${activity.rate}'),
                      ],
                    ),
                  const SizedBox(width: 16),
                  if (activity.price != null)
                    Text(
                      activity.price == "0" ? "Free" : '${activity.price} TND',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Address
            if (getLocalizedAddress() != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    const Icon(Icons.location_on),
                    const SizedBox(width: 8),
                    Expanded(child: Text(getLocalizedAddress()!)),
                  ],
                ),
              ),

            const SizedBox(height: 16),

            // Description
            if (getLocalizedDescription() != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  getLocalizedDescription()!,
                  style: const TextStyle(fontSize: 16),
                ),
              ),

            const SizedBox(height: 16),

            // Image Grid Preview
            if (activity.images != null && activity.images!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: ImageGridPreview(
                  images: activity.images!,
                  maxVisible: 4,
                ),
              ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
