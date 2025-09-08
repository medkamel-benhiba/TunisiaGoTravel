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
  final ScrollController _scrollController = ScrollController();
  String? selectedDestinationId;
  String? selectedDestinationTitle;
  HotelsViewType _viewType = HotelsViewType.list;
  bool _isFromSearch = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 300) {
      // Auto-load more when near bottom (optional)
      final hotelProvider = Provider.of<HotelProvider>(context, listen: false);
      if (hotelProvider.hasMoreSearchResults && !hotelProvider.isLoadingMoreResults) {
        hotelProvider.loadMoreSearchResults();
      }
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final globalProvider = Provider.of<GlobalProvider>(context, listen: false);
    final hotelProvider = Provider.of<HotelProvider>(context, listen: false);

    // Check if coming from search
    if (globalProvider.selectedCityForHotels != null &&
        globalProvider.availableHotels.isNotEmpty &&
        selectedDestinationTitle == null) {

      WidgetsBinding.instance.addPostFrameCallback((_) {
        final city = globalProvider.selectedCityForHotels!;

        setState(() {
          selectedDestinationTitle = city;
          _isFromSearch = true;
        });

        // Clean up after getting data
        globalProvider.setSelectedCityForHotels(null);
      });
    }
    // Normal destination selection
    else if (globalProvider.selectedCityForHotels != null && selectedDestinationTitle == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final city = globalProvider.selectedCityForHotels!;
        final destId = hotelProvider.getDestinationIdByCity(city);

        if (destId != null) {
          setState(() {
            selectedDestinationTitle = city;
            selectedDestinationId = destId;
            _isFromSearch = false;
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

    // Choose which hotels to display
    final List<dynamic> filteredHotels;

    if (_isFromSearch) {
      // Use search results (which get updated silently in background)
      filteredHotels = globalProvider.availableHotels;
    } else if (selectedDestinationId != null) {
      // Use destination-based hotels
      filteredHotels = hotelProvider.getHotelsByDestination(selectedDestinationId!);
    } else {
      filteredHotels = <dynamic>[];
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(10.0,10.0,10.0,5.0),
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
              padding: const EdgeInsets.symmetric(horizontal: 1.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton.icon(
                    onPressed: () {
                      setState(() {
                        selectedDestinationId = null;
                        selectedDestinationTitle = null;
                        _isFromSearch = false;
                      });
                      Provider.of<GlobalProvider>(context, listen: false).setAvailableHotels([]);
                      // Reset search when going back
                      hotelProvider.resetSearch();
                    },
                    icon: const Icon(Icons.arrow_back, size: 16),
                    label: const Text('Destinations'),
                  ),
                  if (_isFromSearch)
                    Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: Text(
                        '${filteredHotels.length} Hôtels (plus en cours...)',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
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
                  _isFromSearch = false;
                });
                hotelProvider.setHotelsByDestination(destination.id);
              },
            )
                : _buildHotels(
                filteredHotels,
                hotelProvider.isLoading ||
                    hotelProvider.isLoadingAvailableHotels ||
                    (hotelProvider.isInitialSearchLoading && _isFromSearch)
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHotels(List<dynamic> hotels, bool isLoading) {
    // Show initial loading only
    if (isLoading && hotels.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (hotels.isEmpty && !isLoading) {
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
          ],
        ),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(12),
      itemCount: hotels.length,
      itemBuilder: (_, index) => HotelCard(
        hotel: hotels[index],
        showReservationButton: _isFromSearch,
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}