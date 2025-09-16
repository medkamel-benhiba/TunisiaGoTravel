import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../providers/monument_provider.dart';
import '../theme/color.dart';
import '../widgets/cultures/DescriptionCard.dart';
import '../widgets/cultures/monument_info_card.dart';
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
            appBar: AppBar(title: Text("monument".tr())),
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(15),
                child: Text(
                  provider.error ?? 'no_monument_info'.tr(),
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
              monument.getName(Localizations.localeOf(context)),
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
                if (monument.images.isNotEmpty)
                  ImageGridPreview(images: monument.images),

                const SizedBox(height: 12),

                MonumentInfoCard(monument: monument),

                const SizedBox(height: 12),

                if (monument.description.isNotEmpty)
                  DescriptionCard(description: monument.getDescription(Localizations.localeOf(context))),

                const SizedBox(height: 12),

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
                                    monument.getDestinationName(Localizations.localeOf(context)),
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black,
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
