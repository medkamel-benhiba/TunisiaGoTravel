import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/global_provider.dart';
import '../providers/hotel_provider.dart';
import '../widgets/hotel/hotel_card.dart';
import '../widgets/screen_title.dart';
import '../widgets/destinations_list.dart';

enum HotelsViewType { list, grid }

class HotelsScreenContent extends StatefulWidget {
  const HotelsScreenContent({super.key});

  @override
  State<HotelsScreenContent> createState() => _HotelsScreenState();
}

class _HotelsScreenState extends State<HotelsScreenContent> {
  String? selectedDestinationId;
  String? selectedDestinationTitle;
  HotelsViewType _viewType = HotelsViewType.list;
  bool _isFromSearch = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final globalProvider = Provider.of<GlobalProvider>(context, listen: false);
    final hotelProvider = Provider.of<HotelProvider>(context, listen: false);

    // 🔹 Vérifier si on vient d'une recherche avec des hôtels disponibles
    if (globalProvider.selectedCityForHotels != null &&
        globalProvider.availableHotels.isNotEmpty &&
        selectedDestinationTitle == null) {

      WidgetsBinding.instance.addPostFrameCallback((_) {
        final city = globalProvider.selectedCityForHotels!;

        setState(() {
          selectedDestinationTitle = city;
          _isFromSearch = true;
        });

        // Nettoyer le GlobalProvider après récupération
        globalProvider.setSelectedCityForHotels(null);
      });
    }
    // 🔹 Si on vient d'une sélection normale de destination
    else if (globalProvider.selectedCityForHotels != null && selectedDestinationTitle == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final city = globalProvider.selectedCityForHotels!;
        final destId = hotelProvider.getDestinationIdByCity(city);

        if (destId != null) {
          setState(() {
            selectedDestinationTitle = city;
            selectedDestinationId = destId;
            _isFromSearch = false; // 🔹 Sélection normale
          });
          hotelProvider.setHotelsByDestination(destId);
        }

        globalProvider.setSelectedCityForHotels(null);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final hotelProvider = Provider.of<HotelProvider>(context);
    final globalProvider = Provider.of<GlobalProvider>(context);

    // 🔹 Choisir la liste d'hôtels à afficher
    final List<dynamic> filteredHotels;

    if (_isFromSearch) {
      // 🔹 Si on vient de la recherche, utiliser les hôtels disponibles
      filteredHotels = globalProvider.availableHotels;
    } else if (selectedDestinationId != null) {
      // 🔹 Sinon, utiliser les hôtels par destination
      filteredHotels = hotelProvider.getHotelsByDestination(selectedDestinationId!);
    } else {
      // 🔹 Aucune sélection
      filteredHotels = <dynamic>[];
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            child: ScreenTitle(
              icon: selectedDestinationTitle == null ? Icons.location_on : Icons.hotel,
              title: selectedDestinationTitle == null
                  ? 'Destinations'
                  : _isFromSearch
                  ? 'Hôtels disponibles à $selectedDestinationTitle'
                  : 'Hôtels à $selectedDestinationTitle',
            ),
          ),
          if (selectedDestinationTitle != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // 🔹 Bouton de retour pour revenir à la liste des destinations
                  TextButton.icon(
                    onPressed: () {
                      setState(() {
                        selectedDestinationId = null;
                        selectedDestinationTitle = null;
                        _isFromSearch = false;
                      });
                      // 🔹 Nettoyer les hôtels disponibles du GlobalProvider
                      Provider.of<GlobalProvider>(context, listen: false).setAvailableHotels([]);
                    },
                    icon: const Icon(Icons.arrow_back, size: 16),
                    label: const Text('Destinations'),
                  ),

                ],
              ),
            ),
          Expanded(
            child: selectedDestinationTitle == null
                ? DestinationsList(
              onDestinationSelected: (destination) {
                setState(() {
                  selectedDestinationId = destination.id;
                  selectedDestinationTitle = destination.name;
                  _isFromSearch = false; // 🔹 Sélection normale
                });
                // 🔹 Charger les hôtels par destination
                hotelProvider.setHotelsByDestination(destination.id);
              },
            )
                : _buildHotels(filteredHotels, hotelProvider.isLoading || hotelProvider.isLoadingAvailableHotels),
          ),
        ],
      ),
    );
  }

  Widget _buildHotels(List<dynamic> hotels, bool isLoading) {
    if (isLoading) return const Center(child: CircularProgressIndicator());
    if (hotels.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.hotel_outlined, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              _isFromSearch
                  ? 'Aucun hôtel disponible pour ces critères'
                  : 'Aucun hôtel disponible pour cette destination',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
            if (_isFromSearch) ...[
              const SizedBox(height: 8),
              Text(
                'Essayez de modifier vos dates ou critères de recherche',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[500],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      );
    }

    return _viewType == HotelsViewType.list
        ? ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: hotels.length,
      itemBuilder: (_, index) => HotelCard(
        hotel: hotels[index],
        showReservationButton: _isFromSearch, // 🔹 Bouton réserver seulement pour les recherches
      ),
    )
        : GridView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: hotels.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: _isFromSearch ? 0.75 : 0.46,
      ),
      itemBuilder: (_, index) => HotelCard(
        hotel: hotels[index],
        showReservationButton: _isFromSearch, // 🔹 Bouton réserver seulement pour les recherches
      ),
    );
  }
}