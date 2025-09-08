import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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

    // Fetch maisons once after first frame
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
            padding:
            const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
            child: ScreenTitle(
              icon: selectedDestinationId == null
                  ? Icons.location_on
                  : Icons.house,
              title: selectedDestinationId == null
                  ? 'Destinations'
                  : "Maisons d'hôtes à $selectedDestinationTitle",
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
      padding: const EdgeInsets.all(12),
      itemCount: maisons.length,
      itemBuilder: (context, index) {
        return MaisonCard(maison: maisons[index]);
      },
    );
  }
}