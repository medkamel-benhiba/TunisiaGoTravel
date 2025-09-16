import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:tunisiagotravel/providers/destination_provider.dart';
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
      final hotelProvider = Provider.of<HotelProvider>(context, listen: false);
      if (hotelProvider.hasMoreSearchResults &&
          !hotelProvider.isLoadingMoreResults) {
        hotelProvider.loadMoreSearchResults();
      }
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final globalProvider = Provider.of<GlobalProvider>(context, listen: false);
    final hotelProvider = Provider.of<HotelProvider>(context, listen: false);

    if (globalProvider.selectedCityForHotels != null &&
        globalProvider.availableHotels.isNotEmpty &&
        selectedDestinationTitle == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final city = globalProvider.selectedCityForHotels!;
        setState(() {
          selectedDestinationTitle = city;
          _isFromSearch = true;
        });
        globalProvider.setSelectedCityForHotels(null);
      });
    } else if (globalProvider.selectedCityForHotels != null &&
        selectedDestinationTitle == null) {
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
    final locale=context.locale;
    final hotelProvider = Provider.of<HotelProvider>(context);
    final globalProvider = Provider.of<GlobalProvider>(context);

    final List<dynamic> filteredHotels;
    if (_isFromSearch) {
      filteredHotels = globalProvider.availableHotels;
    } else if (selectedDestinationId != null) {
      filteredHotels =
          hotelProvider.getHotelsByDestination(selectedDestinationId!);
    } else {
      filteredHotels = <dynamic>[];
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Screen title
          Padding(
            padding: const EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 5.0),
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
                icon: selectedDestinationId == null ? Icons.location_on : Icons.hotel,
                title: selectedDestinationId == null
                    ? 'hotelsScreen.destinations'.tr()
                    : _isFromSearch
                    ? 'hotelsScreen.availableHotels'.tr(args: [displayDestination])
                    : 'hotelsScreen.hotelsInDestination'.tr(args: [displayDestination]),
              );
            }),
          ),



          // Back button and hotel count
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
                      Provider.of<GlobalProvider>(context, listen: false)
                          .setAvailableHotels([]);
                      hotelProvider.resetSearch();
                    },
                    icon: const Icon(Icons.arrow_back, size: 16),
                    label: Builder(
                      builder: (context) =>
                          Text('hotelsScreen.destinations'.tr()),
                    ),
                  ),
                  if (_isFromSearch)
                    Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: Builder(
                        builder: (context) => Text(
                          '${filteredHotels.length} ${'hotelsScreen.hotelsCount'.tr()}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),

          // Hotels list or destinations list
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
                  (hotelProvider.isInitialSearchLoading && _isFromSearch),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHotels(List<dynamic> hotels, bool isLoading) {
    if (isLoading && hotels.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (hotels.isEmpty && !isLoading) {
      return Center(
        child: Builder(builder: (context) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.hotel_outlined, size: 64, color: Colors.grey[400]),
              const SizedBox(height: 16),
              Text(
                _isFromSearch
                    ? 'hotelsScreen.noHotelsForSearch'.tr()
                    : 'hotelsScreen.noHotelsForDestination'.tr(),
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          );
        }),
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
