import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tunisiagotravel/providers/destination_provider.dart';
import '../providers/maisondhote_provider.dart';
import '../widgets/maisonDhote/maisonDhote_card.dart';
import '../widgets/screen_title.dart';
import '../widgets/destinations_list.dart';

class MaisonsScreenContent extends StatefulWidget {
  const MaisonsScreenContent({super.key});

  @override
  State<MaisonsScreenContent> createState() => _MaisonsScreenState();
}

class _MaisonsScreenState extends State<MaisonsScreenContent> {
  String? selectedDestinationId;
  String? selectedDestinationTitle;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<MaisonProvider>(context, listen: false);
      if (provider.allMaisons.isEmpty) {
        provider.fetchMaisons();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<MaisonProvider>(context);

    final filteredMaisons = selectedDestinationId != null
        ? provider.getMaisonsByDestination(selectedDestinationId!)
        : <dynamic>[];

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 0.0),
            child: Builder(builder: (context) {
              final destinationProvider =
              Provider.of<DestinationProvider>(context, listen: false);

              // Get the localized destination name if selected
              String displayDestination = '';
              if (selectedDestinationId != null) {
                displayDestination = destinationProvider
                    .getDestinationName(selectedDestinationId!, context.locale);
              }

              return ScreenTitle(
                icon: selectedDestinationId == null ? Icons.location_on : Icons.maps_home_work_rounded,
                title: selectedDestinationId == null
                    ? 'restaurantsScreen.destinations'.tr()
                    : 'maisons_dhote_at'.tr(
                  args: [displayDestination],
                ),
              );
            }),
          ),

          if (selectedDestinationId != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 1.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton.icon(
                    onPressed: () {
                      setState(() {
                        selectedDestinationId = null;
                        selectedDestinationTitle = null;
                      });
                    },
                    icon: const Icon(Icons.arrow_back, size: 16),
                    label: Text('restaurantsScreen.destinations'.tr()),
                  ),
                ],
              ),
            ),

          Expanded(
            child: selectedDestinationId == null
                ? DestinationsList(
              onDestinationSelected: (destination) {
                setState(() {
                  selectedDestinationId = destination.id;
                  selectedDestinationTitle = destination.name;
                });
              },
            )
                : _buildMaisons(filteredMaisons, provider.isLoading,
                provider.errorMessage),
          ),
        ],
      ),
    );
  }

  Widget _buildMaisons(
      List<dynamic> maisons, bool isLoading, String? errorMessage) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (errorMessage != null) {
      return Center(child: Text(errorMessage));
    }

    if (maisons.isEmpty) {
      return const Center(
          child: Text('Aucune maison disponible pour cette destination'));
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 2.0, horizontal: 12.0),
      itemCount: maisons.length,
      itemBuilder: (context, index) {
        return MaisonCard(maison: maisons[index]);
      },
    );
  }
}