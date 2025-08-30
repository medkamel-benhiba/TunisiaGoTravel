import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/musee_provider.dart';
import '../theme/color.dart';
import '../widgets/cultures/ContactCard.dart';
import '../widgets/cultures/DescriptionCard.dart';
import '../widgets/cultures/musee_info_card.dart';
import '../widgets/gallery.dart';

class MuseeDetailsScreen extends StatefulWidget {
  final String museeSlug;

  const MuseeDetailsScreen({super.key, required this.museeSlug});

  @override
  State<MuseeDetailsScreen> createState() => _MuseeDetailsScreenState();
}

class _MuseeDetailsScreenState extends State<MuseeDetailsScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch the selected museum by slug
    Future.microtask(() {
      final provider = Provider.of<MuseeProvider>(context, listen: false);
      provider.fetchMuseeBySlug(widget.museeSlug);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MuseeProvider>(
      builder: (context, provider, child) {
        final musee = provider.selectedMusee;

        // Loading
        if (provider.isLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // Error or empty
        if (musee == null) {
          return Scaffold(
            appBar: AppBar(title: const Text("Musée")),
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(15),
                child: Text(
                  provider.error ?? 'Aucune information disponible pour ce musée.',
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
              musee.name,
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
                if (musee.images.isNotEmpty)
                  ImageGridPreview(images: musee.images),

                const SizedBox(height: 12),

                // Info Card
                MuseeInfoCard(musee: musee),

                const SizedBox(height: 12),
                // Description
                if (musee.description.isNotEmpty)
                  DescriptionCard(description: musee.description),
                const SizedBox(height: 12),

                // Destination Info
                if (musee.situation.isNotEmpty)
                  Padding(
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
                                    musee.situation,
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
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
