import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tunisiagotravel/theme/color.dart';
import '../../models/hotel.dart';
import '../../models/hotelAvailabilityResponse.dart';
import '../../models/hotelBhr.dart';
import '../../models/hotelTgt.dart';
import '../../screens/hotelBhr_reservation_screen.dart';
import '../../screens/hotelTgt_reservation_screen.dart';
import '../../screens/mouradi_reservation_screen.dart';
import '../../providers/hotel_provider.dart';
import '../../providers/global_provider.dart';
import '../../screens/hotel_details_screen.dart';

class HotelCard extends StatelessWidget {
  final Hotel hotel;
  final bool showReservationButton;

  const HotelCard({
    super.key,
    required this.hotel,
    this.showReservationButton = false,
  });

  void _navigateToDetails(BuildContext context) async {
    final provider = Provider.of<HotelProvider>(context, listen: false);

    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Chargement des détails...'),
              ],
            ),
          ),
        ),
      ),
    );

    try {
      await provider.fetchHotelDetail(hotel.slug);
      Navigator.pop(context);

      if (provider.selectedHotel != null) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => HotelDetailsScreen(hotelSlug: hotel.slug),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Impossible de charger les détails de l\'hôtel'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      Navigator.pop(context); // Close loading dialog
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _handleReservation(BuildContext context, dynamic hotel) async {
    final globalProvider = Provider.of<GlobalProvider>(context, listen: false);

    // Préparer les rooms à partir des critères de recherche
    List<Map<String, dynamic>> originalRooms = [];
    if (globalProvider.searchCriteria['rooms'] is List) {
      originalRooms = List<Map<String, dynamic>>.from(globalProvider.searchCriteria['rooms']);
    } else {
      originalRooms = [
        {
          "adults": globalProvider.searchCriteria['adults'] ?? 1,
          "children": globalProvider.searchCriteria['children'] ?? 0,
          "childAges": []
        }
      ];
    }

    final rooms = originalRooms.map((room) => {
      "adults": room['adults'] ?? 1,
      "children": room['children'] ?? 0,
      "childAges": room['childAges'] ?? []
    }).toList();

    final dateStart = globalProvider.searchCriteria['dateStart'] as String;
    final dateEnd = globalProvider.searchCriteria['dateEnd'] as String;

    final hotelProvider = Provider.of<HotelProvider>(context, listen: false);

    // --- 1. Check if it's a TGT hotel first ---
    if (hotel is HotelTgt) {
      print("Navigating to TGT hotel: ${hotel.name}");
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => HotelTgtReservationScreen(
            hotelTgt: hotel,
            searchCriteria: {
              'dateStart': dateStart,
              'dateEnd': dateEnd,
              'rooms': rooms,
              'adults': globalProvider.searchCriteria['adults'],
              'children': globalProvider.searchCriteria['children'],
              'destinationId': globalProvider.searchCriteria['destinationId'],
              'destinationName': globalProvider.searchCriteria['destinationName'],
              'roomsCount': rooms.length.toString(),
            },
          ),
        ),
      );
      return;
    }

    // --- 2. Check if it's a regular Hotel with TGT availability ---
    if (hotel is Hotel) {
      // First check if we have availability data for this hotel
      HotelData? foundHotelData;
      if (hotelProvider.hotelDisponibilityPontion != null) {
        try {
          // Try multiple search strategies
          print("Searching for hotel: ${hotel.name} with ID: ${hotel.id}");
          print("Available hotels in data:");
          for (var h in hotelProvider.hotelDisponibilityPontion!.data) {
            print("  - ID: ${h.id}, Name: ${h.name}, Type: ${h.disponibility.disponibilityType}");
          }

          // First try by ID
          try {
            foundHotelData = hotelProvider.hotelDisponibilityPontion!.data
                .firstWhere((h) => h.id == hotel.id);
            print("Found hotel by ID: ${hotel.name}");
          } catch (e) {
            // If ID search fails, try by name (with normalization)
            String normalizedSearchName = hotel.name.toLowerCase().trim();
            try {
              foundHotelData = hotelProvider.hotelDisponibilityPontion!.data
                  .firstWhere((h) => h.name.toLowerCase().trim() == normalizedSearchName);
              print("Found hotel by name: ${hotel.name}");
            } catch (e2) {
              // If exact name fails, try partial name match
              try {
                foundHotelData = hotelProvider.hotelDisponibilityPontion!.data
                    .firstWhere((h) => h.name.toLowerCase().contains('joya') && h.name.toLowerCase().contains('paradise'));
                print("Found hotel by partial name match: ${foundHotelData.name}");
              } catch (e3) {
                print("Hotel ${hotel.name} not found with any search strategy");
                foundHotelData = null;
              }
            }
          }

          if (foundHotelData != null) {
            print("Found hotel data for ${hotel.name}, type: ${foundHotelData.disponibility.disponibilityType}");
          }
        } catch (e) {
          print("Error searching for hotel ${hotel.name}: $e");
          foundHotelData = null;
        }
      }

      // Check if it's a TGT type hotel
      if (foundHotelData != null &&
          foundHotelData.disponibility.disponibilityType == 'tgt') {
        print("Converting Hotel to HotelTgt for: ${hotel.name}");
        print("Pensions data: ${foundHotelData.disponibility.pensions}");
        print("Pensions length: ${foundHotelData.disponibility.pensions.length}");

        // Check if we have valid pension data
        if (foundHotelData.disponibility.pensions.isEmpty) {
          print("No pensions found for TGT hotel ${hotel.name}");
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Aucune disponibilité trouvée pour ce séjour"),
              backgroundColor: Colors.orange,
            ),
          );
          return;
        }

        // Convert Hotel to HotelTgt
        final hotelTgt = _convertHotelToTgt(foundHotelData, hotel);

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => HotelTgtReservationScreen(
              hotelTgt: hotelTgt,
              searchCriteria: {
                'dateStart': dateStart,
                'dateEnd': dateEnd,
                'rooms': rooms,
                'adults': globalProvider.searchCriteria['adults'],
                'children': globalProvider.searchCriteria['children'],
                'destinationId': hotel.destinationId,
                'destinationName': hotel.destinationName,
                'roomsCount': rooms.length.toString(),
              },
            ),
          ),
        );
        return;
      }

      // If no hotel data found, try to fetch more data or handle gracefully
      if (foundHotelData == null) {
        print("No availability data found for ${hotel.name}");
        print("Current page: ${hotelProvider.hotelDisponibilityPontion?.currentPage}");
        print("Last page: ${hotelProvider.hotelDisponibilityPontion?.lastPage}");

        // For TGT hotels that aren't found in availability data,
        // we can still try to create a basic HotelTgt object
        // This allows navigation even when availability data is incomple

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Hotel ${hotel.name} non trouvé dans les données de disponibilité"),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }



      // --- 3. Handle Mouradi hotels ---
      if (hotel.name.toLowerCase().contains('mouradi') &&
          hotel.idHotelMouradi != null &&
          hotel.idCityMouradi != null) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => const Center(child: CircularProgressIndicator()),
        );

        await hotelProvider.fetchMouradiHotelAvailability(
          hotelId: hotel.idHotelMouradi!,
          cityId: hotel.idCityMouradi!,
          dateStart: dateStart,
          dateEnd: dateEnd,
          rooms: rooms,
        );

        Navigator.pop(context); // fermer le loader

        if (hotelProvider.selectedMouradiHotel == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Aucune disponibilité trouvée pour ce séjour"),
              backgroundColor: Colors.orange,
            ),
          );
          return;
        }

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => MouradiReservationScreen(
              hotel: hotelProvider.selectedMouradiHotel!,
              searchCriteria: {
                'dateStart': dateStart,
                'dateEnd': dateEnd,
                'rooms': rooms,
                'destinationId': globalProvider.searchCriteria['destinationId'],
                'destinationName': globalProvider.searchCriteria['destinationName'],
                'adults': globalProvider.searchCriteria['adults'],
                'children': globalProvider.searchCriteria['children'],
                'roomsCount': rooms.length.toString(),
              },
            ),
          ),
        );
        return;
      }

      // --- 4. Handle BHR hotels (default case) ---
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const Center(child: CircularProgressIndicator()),
      );

      Navigator.pop(context); // fermer le loader

      if (foundHotelData == null || foundHotelData.disponibility.pensions.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Aucune disponibilité trouvée pour ce séjour"),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      final hotelBhr = _convertToHotelBhr(foundHotelData, hotel);

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => HotelBhrReservationScreen(
            hotelBhr: hotelBhr,
            searchCriteria: {
              'dateStart': dateStart,
              'dateEnd': dateEnd,
              'rooms': rooms,
              'destinationId': hotel.destinationId,
              'destinationName': hotel.destinationName,
              'adults': globalProvider.searchCriteria['adults'],
              'children': globalProvider.searchCriteria['children'],
              'roomsCount': rooms.length.toString(),
            },
            allHotels: hotelProvider.allHotels,
          ),
        ),
      );
      return;
    }

    // If we reach here, show a generic error
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Type d'hôtel non reconnu"),
        backgroundColor: Colors.red,
      ),
    );
  }

// Helper method to convert Hotel + HotelData to HotelTgt
  HotelTgt _convertHotelToTgt(HotelData hotelData, Hotel originalHotel) {
    print("Converting to TGT: ${hotelData.name}");
    print("Raw pensions data: ${hotelData.disponibility.pensions}");

    // Convert the pensions data to TGT format
    List<PensionTgt> pensionsList = [];

    if (hotelData.disponibility.pensions.isNotEmpty) {
      for (var pension in hotelData.disponibility.pensions) {
        print("Processing pension: $pension");
        print("Pension type: ${pension.runtimeType}");

        if (pension is Map<String, dynamic>) {
          // Extract rooms data - it might be nested differently
          List<dynamic> roomsData = [];
          if (pension['rooms'] is List) {
            roomsData = pension['rooms'];
          } else if (pension['rooms'] != null) {
            roomsData = [pension['rooms']];
          }

          print("Rooms data for pension: $roomsData");

          pensionsList.add(PensionTgt(
            id: pension['id'] ?? '',
            name: pension['name'] ?? '',
            nameAr: pension['name_ar'],
            nameEn: pension['name_en'],
            devise: pension['devise'] ?? 'TND',
            description: pension['description'] ?? '',
            descriptionAr: pension['description_ar'],
            descriptionEn: pension['description_en'],
            rooms: _convertRoomsToTgt(roomsData),
          ));
        } else {
          print("Pension is not a Map: $pension, type: ${pension.runtimeType}");
        }
      }
    }

    print("Converted ${pensionsList.length} pensions");

    return HotelTgt(
      id: hotelData.id,
      name: hotelData.name,
      slug: hotelData.slug,
      idCityBbx: hotelData.idCityBbx,
      idHotelBbx: hotelData.idHotelBbx,
      disponibility: DisponibilityTgt(  // Use the renamed class
        disponibilitytype: hotelData.disponibility.disponibilityType,
        pensions: pensionsList,
      ),
    );
  }

// Helper method to convert rooms data to TGT format
  // Helper method to convert rooms data to TGT format
  List<RoomTgt> _convertRoomsToTgt(List<dynamic> roomsData) {
    List<RoomTgt> rooms = [];

    for (var roomData in roomsData) {
      if (roomData is Map<String, dynamic>) {
        // Safely convert conversion_rates map
        Map<String, dynamic>? rawConversionRates = roomData['conversion_rates'];
        Map<String, double>? conversionRates;
        if (rawConversionRates != null) {
          conversionRates = rawConversionRates.map(
                (key, value) => MapEntry(key, (value as num).toDouble()),
          );
        }

        rooms.add(RoomTgt(
          id: roomData['id'] ?? '',
          title: roomData['title'] ?? '',
          capacity: _convertCapacityToTgt(roomData['capacity'] ?? []),
          attributes: (roomData['attributes'] as List<dynamic>?)
              ?.map((attr) => attr.toString())
              .toList() ?? [],
          stillAvailable: roomData['still_available'] ?? 0,
          purchasePrice: _convertPurchasePriceToTgt(roomData['purchase_price'] ?? []),
          conversionRates: conversionRates, // Use the new converted map
        ));
      }
    }
    return rooms;
  }

  List<Capacity> _convertCapacityToTgt(List<dynamic> capacityData) {
    List<Capacity> capacities = [];

    for (var cap in capacityData) {
      if (cap is Map<String, dynamic>) {
        capacities.add(Capacity(
          adults: cap['adults'] ?? 0,
          children: cap['children'] ?? 0,
          babies: cap['babies'] ?? 0,
          maxBabiesAge: cap['max_babies_age'],
        ));
      }
    }

    return capacities;
  }

  List<PurchasePrice> _convertPurchasePriceToTgt(List<dynamic> priceData) {
    List<PurchasePrice> prices = [];

    for (var price in priceData) {
      if (price is Map<String, dynamic>) {
        // Correctly handle the conversion_rates map
        Map<String, dynamic>? rawConversionRates = price['conversion_rates'];
        Map<String, double>? conversionRates;

        if (rawConversionRates != null) {
          conversionRates = rawConversionRates.map(
                (key, value) => MapEntry(key, (value as num).toDouble()),
          );
        }

        prices.add(PurchasePrice(
          id: price['id'] ?? '',
          roomId: price['room_id'] ?? '',
          accomodationId: price['accomodation_id'] ?? '',
          purchasePrice: (price['purchase_price'] ?? 0).toDouble(),
          commission: (price['commission'] ?? 0).toDouble(),
          dateStart: price['date_start'] ?? '',
          dateEnd: price['date_end'] ?? '',
          status: price['status'] ?? false,
          partners: (price['partners'] as List<dynamic>?)
              ?.map((partner) => Partner.fromJson(partner))
              .toList() ?? [],
          marchiId: price['marchi_id'] ?? '',
          currency: price['currency'] ?? 'TND',
          conversionRates: conversionRates, // Use the corrected map
          updatedAt: price['updated_at'] ?? '',
          createdAt: price['created_at'] ?? '',
          accommodation: price['accommodation'] != null
              ? AccommodationDetails.fromJson(price['accommodation'])
              : null,
        ));
      }
    }
    return prices;
  }



  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      elevation: 4,
      shadowColor: Colors.black.withOpacity(0.1),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image with gradient overlay
          Stack(
            children: [
              if (hotel.cover.isNotEmpty)
                Image.network(
                  hotel.cover,
                  height: 180,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(
                      height: 180,
                      color: Colors.grey[200],
                      child: const Center(
                        child: CircularProgressIndicator(),
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 180,
                      color: Colors.grey[200],
                      child: const Center(
                        child: Icon(Icons.image_not_supported,
                            size: 50, color: Colors.grey),
                      ),
                    );
                  },
                ),

              // Gradient overlay at bottom
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  height: 60,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.3),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),

          // Content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Hotel name
                Text(
                  hotel.name,
                  maxLines: 2,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Colors.black87,
                  ),
                ),

                const SizedBox(height: 8),
                // Stars rating
                if (hotel.categoryCode != null)
                  Row(
                    children: [
                      ...List.generate(
                        hotel.categoryCode!,
                            (index) => const Icon(
                          Icons.star,
                          color: Colors.amber,
                          size: 18,
                        ),
                      ),
                      ...List.generate(
                        5 - hotel.categoryCode!,
                            (index) => Icon(
                          Icons.star_border,
                          color: Colors.grey[300],
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${hotel.categoryCode} étoiles',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),

                const SizedBox(height: 12),

                // Location
                Row(
                  children: [
                    Icon(
                      Icons.location_on,
                      size: 16,
                      color: AppColorstatic.primary,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        hotel.address ?? 'Adresse non disponible',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                          fontSize: 13,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Action buttons
                Row(
                  children: [
                    // Details button
                    Expanded(
                      flex: showReservationButton ? 1 : 2,
                      child: OutlinedButton.icon(
                        onPressed: () => _navigateToDetails(context),
                        icon: const Icon(Icons.info_outline, size: 16),
                        label: const Text('Détails'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColorstatic.primary,
                          side: BorderSide(color: AppColorstatic.primary),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),

                    // Reservation button (only for available hotels)
                    if (showReservationButton) ...[
                      const SizedBox(width: 8),
                      Expanded(
                        flex: 1,
                        child: ElevatedButton.icon(
                          onPressed: () => _handleReservation(context,hotel),
                          icon: const Icon(Icons.book_online, size: 16),
                          label: const Text('Réserver'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColorstatic.primary,
                            foregroundColor: Colors.white,
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Helper method to convert HotelData to HotelBhr
  HotelBhr _convertToHotelBhr(HotelData hotelData, Hotel originalHotel) {
    List<RoomBhr> roomsBhr = [];

    // Process pensions data
    for (var pension in hotelData.disponibility.pensions) {
      if (pension is Map<String, dynamic>) {
        final roomsData = pension['rooms'];

        // Handle different room data structures
        List<dynamic> roomList = [];
        if (roomsData != null) {
          if (roomsData['room'] is List) {
            roomList = roomsData['room'];
          } else if (roomsData['room'] != null) {
            roomList = [roomsData['room']];
          }
        }

        // Convert each room
        for (var roomData in roomList) {
          if (roomData is Map<String, dynamic>) {
            final boardingsData = roomData['Boardings'];
            List<BoardingBhr> boardings = [];

            if (boardingsData != null) {
              List<dynamic> boardingList = [];
              if (boardingsData['Boarding'] is List) {
                boardingList = boardingsData['Boarding'];
              } else if (boardingsData['Boarding'] != null) {
                boardingList = [boardingsData['Boarding']];
              }

              for (var boardingData in boardingList) {
                if (boardingData is Map<String, dynamic>) {
                  boardings.add(BoardingBhr(
                    id: boardingData['@attributes']?['id']?.toString() ?? '',
                    title: boardingData['Title']?.toString() ?? '',
                    available: boardingData['Available']?.toString() ?? '',
                    rate: double.tryParse(boardingData['Rate']?.toString() ?? '0') ?? 0,
                    rateWithoutPromotion: double.tryParse(boardingData['RateWithoutPromotion']?.toString() ?? '0') ?? 0,
                    nonRefundable: boardingData['NonRefundable']?.toString().toLowerCase() == 'true',
                    cancellationPolicy: CancellationPolicy(
                      fromDate: boardingData['CancellationPolicy']?['FromDate']?.toString() ?? '',
                      fee: double.tryParse(boardingData['CancellationPolicy']?['Fee']?.toString() ?? '0') ?? 0,
                    ),
                  ));
                }
              }
            }

            roomsBhr.add(RoomBhr(
              id: roomData['@attributes']?['id']?.toString() ?? '',
              title: roomData['Title']?.toString() ?? '',
              adults: int.tryParse(roomData['Adult']?.toString() ?? '0') ?? 0,
              children: int.tryParse(roomData['Child']?.toString() ?? '0') ?? 0,
              infants: int.tryParse(roomData['Infant']?.toString() ?? '0') ?? 0,
              availableQuantity: int.tryParse(roomData['AvailableQuantity']?.toString() ?? '0') ?? 0,
              boardings: boardings,
            ));
          }
        }
      }
    }

    return HotelBhr(
      id: hotelData.id,
      name: hotelData.name,
      slug: hotelData.slug,
      disponibilityType: hotelData.disponibility.disponibilityType,
      disponibility: DisponibilityBhr(
        id: hotelData.id,
        title: originalHotel.name,
        category: originalHotel.categoryCode?.toString() ?? '',
        summary: originalHotel.shortDescription ?? '',
        address: originalHotel.address,
        promotionDateTime: '',
        rooms: roomsBhr,
      ),
    );
  }
}