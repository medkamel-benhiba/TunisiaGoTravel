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
    // Fetch the selected artisanat by slug
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

        // Loading
        if (provider.isLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // Error or empty
        if (artisanat == null) {
          return Scaffold(
            appBar: AppBar(title: const Text("Artisanat")),
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(15),
                child: Text(
                  provider.error ?? 'Aucune information disponible pour cet artisanat.',
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
              artisanat.name,
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
                // Gallery
                if (artisanat.images.isNotEmpty)
                  ImageGridPreview(images: artisanat.images),

                const SizedBox(height: 12),

                // Artisanat Info Card
                ArtisanatInfoCard(artisanat: artisanat),

                const SizedBox(height: 12),

                // Description
                if (artisanat.description.isNotEmpty)
                  DescriptionCard(description: artisanat.description),

                const SizedBox(height: 12),

                // Video section if available
                if (artisanat.videoLink.isNotEmpty)
                  Card(
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.play_circle_filled,
                                color: Colors.red[600],
                                size: 24,
                              ),
                              const SizedBox(width: 12),
                              const Text(
                                'Vidéo démonstrative',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: () {
                                // Handle video play - you can integrate with url_launcher
                                // or a video player
                              },
                              icon: const Icon(Icons.play_arrow),
                              label: const Text('Regarder la vidéo'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red[600],
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 12),
                              ),
                            ),
                          ),
                        ],
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