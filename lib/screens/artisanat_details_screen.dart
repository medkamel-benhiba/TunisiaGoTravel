import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/artisanat_provider.dart';
import '../theme/color.dart';
import '../widgets/cultures/DescriptionCard.dart';
import '../widgets/cultures/artisanat_info_card.dart';
import '../widgets/gallery.dart';

class ArtisanatDetailsScreen extends StatefulWidget {
  final String artisanatSlug;

  const ArtisanatDetailsScreen({super.key, required this.artisanatSlug});

  @override
  State<ArtisanatDetailsScreen> createState() => _ArtisanatDetailsScreenState();
}

class _ArtisanatDetailsScreenState extends State<ArtisanatDetailsScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final provider = Provider.of<ArtisanatProvider>(context, listen: false);
      provider.fetchArtisanatBySlug(widget.artisanatSlug);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ArtisanatProvider>(
      builder: (context, provider, child) {
        final artisanat = provider.selectedArtisanat;

        if (provider.isLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (artisanat == null) {
          return Scaffold(
            appBar: AppBar(title: Text('artisanat'.tr())),
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(15),
                child: Text(
                  provider.error ?? 'no_info_artisanat'.tr(),
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
              artisanat.getName(Localizations.localeOf(context)),
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
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (artisanat.images.isNotEmpty)
                  ImageGridPreview(images: artisanat.images),

                const SizedBox(height: 12),

                ArtisanatInfoCard(artisanat: artisanat),

                const SizedBox(height: 12),

                if (artisanat.description.isNotEmpty)
                  DescriptionCard(description: artisanat.getDescription(Localizations.localeOf(context))),

                const SizedBox(height: 12),
              ],
            ),
          ),
        );
      },
    );
  }
}
