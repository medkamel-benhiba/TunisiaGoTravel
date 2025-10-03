import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:tunisiagotravel/providers/destination_provider.dart';
import 'package:tunisiagotravel/theme/color.dart';
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
  Set<String> _selectedCategories = {};

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

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text('hotelsScreen.filterByCategory'.tr()),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildCategoryCheckbox('1', '⭐', setDialogState),
                    _buildCategoryCheckbox('2', '⭐⭐', setDialogState),
                    _buildCategoryCheckbox('3', '⭐⭐⭐', setDialogState),
                    _buildCategoryCheckbox('4', '⭐⭐⭐⭐', setDialogState),
                    _buildCategoryCheckbox('5', '⭐⭐⭐⭐⭐', setDialogState),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    setDialogState(() {
                      _selectedCategories.clear();
                    });
                    setState(() {});
                    Navigator.of(context).pop();
                  },
                  child: Text('hotelsScreen.clearFilters'.tr(),
                  style: TextStyle(
                    color: AppColorstatic.darker.withOpacity(0.4)
                  )
                    ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text('common.cancel'.tr()),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColorstatic.primary,
                      ),
                      onPressed: () {
                        setState(() {});
                        Navigator.of(context).pop();
                      },
                      child: Text(
                        'common.apply'.tr(),
                        style: TextStyle(
                          color: AppColorstatic.lightTextColor
                        ),

                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildCategoryCheckbox(String code, String label, StateSetter setDialogState) {
    return CheckboxListTile(
      title: Text(label),
      value: _selectedCategories.contains(code),
      onChanged: (bool? value) {
        setDialogState(() {
          if (value == true) {
            _selectedCategories.add(code);
          } else {
            _selectedCategories.remove(code);
          }
        });
      },
    );
  }

  List<dynamic> _applyFilters(List<dynamic> hotels) {
    if (_selectedCategories.isEmpty) {
      return hotels;
    }
    return hotels.where((hotel) {
      final categoryCode = hotel.categoryCode?.toString() ?? '';
      return _selectedCategories.contains(categoryCode);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final locale = context.locale;
    final hotelProvider = Provider.of<HotelProvider>(context);
    final globalProvider = Provider.of<GlobalProvider>(context);

    final List<dynamic> filteredHotels;
    if (_isFromSearch) {
      filteredHotels = _applyFilters(globalProvider.availableHotels);
    } else if (selectedDestinationId != null) {
      filteredHotels = _applyFilters(
          hotelProvider.getHotelsByDestination(selectedDestinationId!));
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
            padding: const EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 0.0),
            child: Builder(builder: (context) {
              final destinationProvider =
              Provider.of<DestinationProvider>(context, listen: false);

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

          // Back button, filter button.
          if (selectedDestinationTitle != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 1.0),
              child: Row(
                children: [
                  TextButton.icon(
                    onPressed: () {
                      setState(() {
                        selectedDestinationId = null;
                        selectedDestinationTitle = null;
                        _isFromSearch = false;
                        _selectedCategories.clear();
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
                  const SizedBox(width: 8),

                  const Spacer(),
                  // Filter button
                  Stack(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.filter_list, size: 20),
                        onPressed: _showFilterDialog,
                        tooltip: 'hotelsScreen.filter'.tr(),
                      ),
                      if (_selectedCategories.isNotEmpty)
                        Positioned(
                          top: 4,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                            child: Text(
                              _selectedCategories.length.toString(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                    ],
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
      padding: const EdgeInsets.symmetric(vertical: 2.0, horizontal: 12.0),
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