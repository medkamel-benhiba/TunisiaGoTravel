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

        // Si festival introuvable
        if (festival == null) {
          return Scaffold(
            appBar: AppBar(title: const Text("Festival")),
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(15),
                child: Text(
                  provider.error ??
                      'Aucune information disponible pour ce festival.',
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
              festival.name,
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
                // Galerie d’images
                if (festival.images.isNotEmpty)
                  ImageGridPreview(images: festival.images),

                // Carte info festival
                FestivalInfoCard(festival: festival),

                const SizedBox(height: 12),

                // Description
                if (festival.description.isNotEmpty)
                  DescriptionCard(description: festival.description),

                const SizedBox(height: 12),

                // Destination
                if (festival.destination != null &&
                    festival.destination!.name.isNotEmpty)
                  _buildDestinationCard(festival.destination!.name),

                const SizedBox(height: 12),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Widget séparé pour la carte Destination
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
                    const Text(
                      'Destination',
                      style: TextStyle(
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
