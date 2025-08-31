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

    // --- 1. Mouradi ---
    if (hotel is Hotel &&
        hotel.name.toLowerCase().contains('mouradi') &&
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

    // --- 2. BHR normal ---
    if (hotel is Hotel) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const Center(child: CircularProgressIndicator()),
      );

      Navigator.pop(context); // fermer le loader

      // Chercher l'hôtel dans la disponibilité
      HotelData? foundHotelData;
      if (hotelProvider.hotelDisponibilityPontion != null) {
        try {
          foundHotelData = hotelProvider.hotelDisponibilityPontion!.data
              .firstWhere((h) => h.id == hotel.id);
        } catch (e) {
          foundHotelData = null;
        }
      }

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
      else{
    // --- 3. TGT ---
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
            },
          ),
        ),
      );
      return;
    }
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