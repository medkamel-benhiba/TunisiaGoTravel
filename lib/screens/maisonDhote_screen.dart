import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/maisondhote_provider.dart';
import '../widgets/maisonDhote_card.dart';
import '../widgets/screen_title.dart';
import '../widgets/destinations_list.dart';

enum MaisonsViewType { list, grid }

class MaisonsScreenContent extends StatefulWidget {
  const MaisonsScreenContent({super.key});

  @override
  State<MaisonsScreenContent> createState() => _MaisonsScreenState();
}

class _MaisonsScreenState extends State<MaisonsScreenContent> {
  String? selectedDestinationId;
  String? selectedDestinationTitle;
  MaisonsViewType _viewType = MaisonsViewType.list;

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
                  : 'Maisons à $selectedDestinationTitle',
            ),
          ),

          if (selectedDestinationId != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ToggleButton(
                    icon: Icons.list,
                    isSelected: _viewType == MaisonsViewType.list,
                    onTap: () =>
                        setState(() => _viewType = MaisonsViewType.list),
                  ),
                  const SizedBox(width: 8),
                  ToggleButton(
                    icon: Icons.grid_view,
                    isSelected: _viewType == MaisonsViewType.grid,
                    onTap: () =>
                        setState(() => _viewType = MaisonsViewType.grid),
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

    return _viewType == MaisonsViewType.list
        ? ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: maisons.length,
      itemBuilder: (context, index) {
        return MaisonCard(maison: maisons[index]);
      },
    )
        : GridView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: maisons.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.61,
      ),
      itemBuilder: (context, index) {
        return MaisonCard(maison: maisons[index]);
      },
    );
  }
}

// ToggleButton Widget
class ToggleButton extends StatelessWidget {
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const ToggleButton({
    super.key,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue : Colors.grey[200],
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.all(8),
        child: Icon(icon, color: isSelected ? Colors.white : Colors.black),
      ),
    );
  }
}
