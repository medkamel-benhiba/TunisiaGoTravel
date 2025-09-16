import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/festival_provider.dart';
import '../theme/color.dart';
import '../widgets/cultures/DescriptionCard.dart';
import '../widgets/cultures/festival_info_card.dart';
import '../widgets/gallery.dart';

class FestivalDetailsScreen extends StatefulWidget {
  final String festivalSlug;

  const FestivalDetailsScreen({super.key, required this.festivalSlug});

  @override
  State<FestivalDetailsScreen> createState() => _FestivalDetailsScreenState();
}

class _FestivalDetailsScreenState extends State<FestivalDetailsScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final provider = Provider.of<FestivalProvider>(context, listen: false);
      provider.getFestivalBySlug(widget.festivalSlug);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<FestivalProvider>(
      builder: (context, provider, child) {
        final festival = provider.selectedFestival;

        if (festival == null) {
          return Scaffold(
            appBar: AppBar(title: Text('festival'.tr())),
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(15),
                child: Text(
                  provider.error ?? 'no_info_festival'.tr(),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          );
        }

        return Scaffold(
          appBar: AppBar(
            titleSpacing: 0,
            title: Text(
              festival.getName(Localizations.localeOf(context)),
              style: const TextStyle(
                color: AppColorstatic.lightTextColor,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            backgroundColor: AppColorstatic.primary,
            iconTheme: const IconThemeData(color: Colors.white),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (festival.images.isNotEmpty)
                  ImageGridPreview(images: festival.images),
                FestivalInfoCard(festival: festival),
                const SizedBox(height: 12),
                if (festival.description.isNotEmpty)
                  DescriptionCard(description: festival.getDescription(Localizations.localeOf(context))),
                const SizedBox(height: 12),
                if (festival.getDestinationName(Localizations.localeOf(context)) != null &&
                    festival.getDestinationName(Localizations.localeOf(context)).isNotEmpty)
                  _buildDestinationCard(festival.getDestinationName(Localizations.localeOf(context))),
                const SizedBox(height: 12),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDestinationCard(String destinationName) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Card(
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Icon(
                Icons.location_city,
                color: Colors.blue[600],
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'destination'.tr(),
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      destinationName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
