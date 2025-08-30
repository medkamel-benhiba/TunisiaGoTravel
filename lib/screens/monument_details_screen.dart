import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/monument_provider.dart';
import '../theme/color.dart';
import '../widgets/cultures/DescriptionCard.dart';
import '../widgets/cultures/monument_info_card.dart';
import '../widgets/cultures/ContactCard.dart';
import '../widgets/gallery.dart';

class MonumentDetailsScreen extends StatefulWidget {
  final String monumentSlug;

  const MonumentDetailsScreen({super.key, required this.monumentSlug});

  @override
  State<MonumentDetailsScreen> createState() => _MonumentDetailsScreenState();
}

class _MonumentDetailsScreenState extends State<MonumentDetailsScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch the selected monument by slug
    Future.microtask(() {
      final provider = Provider.of<MonumentProvider>(context, listen: false);
      provider.fetchMonumentBySlug(widget.monumentSlug);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MonumentProvider>(
      builder: (context, provider, child) {
        final monument = provider.selectedMonument;

        // Loading
        if (provider.isLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // Error or empty
        if (monument == null) {
          return Scaffold(
            appBar: AppBar(title: const Text("Monument")),
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(15),
                child: Text(
                  provider.error ?? 'Aucune information disponible pour ce monument.',
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
              monument.name,
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
                if (monument.images.isNotEmpty)
                  ImageGridPreview(images: monument.images),

                const SizedBox(height: 12),

                // Monument Info Card
                MonumentInfoCard(monument: monument),

                const SizedBox(height: 12),

                // Description
                if (monument.description.isNotEmpty)
                  DescriptionCard(description: monument.description),

                const SizedBox(height: 12),

                // Destination Info
                if (monument.destination.name.isNotEmpty)
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
                                    monument.destination.name,
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

                const SizedBox(height: 12),
              ],
            ),
          ),
        );
      },
    );
  }
}