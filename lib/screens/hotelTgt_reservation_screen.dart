import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/hotel.dart';
import '../models/hotelTgt.dart';
import '../providers/hotel_provider.dart';
import '../theme/color.dart';
import '../widgets/reservation/HotelHeaderTgt.dart';
import '../widgets/reservation/PensionRoomSelectionTgt.dart';
import '../widgets/reservation/reservation_bottom_bar.dart';
import '../widgets/reservation/search_summary.dart';
import 'hotel_reservation_form.dart';

class HotelTgtReservationScreen extends StatefulWidget {
  final HotelTgt hotelTgt;
  final Map<String, dynamic> searchCriteria;

  const HotelTgtReservationScreen({
    super.key,
    required this.hotelTgt,
    required this.searchCriteria,
  });

  @override
  State<HotelTgtReservationScreen> createState() =>
      _HotelTgtReservationScreenState();
}

class _HotelTgtReservationScreenState extends State<HotelTgtReservationScreen> {
  Map<String, Map<String, int>> selectedRoomsByPension = {};

  @override
  void initState() {
    super.initState();
    for (var pension in widget.hotelTgt.disponibility.pensions) {
      selectedRoomsByPension[pension.id] = {};
    }
  }
  Hotel? getOriginalHotel() {
    try {
      final hotelProvider = Provider.of<HotelProvider>(context, listen: false);
      return hotelProvider.allHotels.firstWhere(
            (h) => h.id == widget.hotelTgt.id || h.slug == widget.hotelTgt.slug,
      );
    } catch (e) {
      debugPrint('No original hotel found for HotelTgt: ${widget.hotelTgt.name}');
      return null;
    }
  }

  int maxRoomsAllowed() {
    final rooms = widget.searchCriteria['rooms'] as List<Map<String, dynamic>>? ?? [];
    return rooms.length;
  }

  int totalSelectedRooms() {
    int total = 0;
    selectedRoomsByPension.forEach((_, rooms) {
      total += rooms.values.fold(0, (a, b) => a + b);
    });
    return total;
  }

  // Helper method to calculate number of nights
  int calculateNights() {
    try {
      final checkIn = DateTime.parse(widget.searchCriteria['checkIn']);
      final checkOut = DateTime.parse(widget.searchCriteria['checkOut']);
      return checkOut.difference(checkIn).inDays;
    } catch (e) {
      return 1; // Default fallback
    }
  }

  // Helper method to calculate base price per night per person
  double calculateBasePrice(double purchasePrice, double commission, int nbOfPersons) {
    return (purchasePrice + (purchasePrice * 12 / 100)) * nbOfPersons;
  }

  // Method to calculate price for a specific room
  double calculateRoomPrice(String pensionId, String roomId) {
    final nights = calculateNights();
    final rooms = widget.searchCriteria['rooms'] as List<Map<String, dynamic>>? ?? [];

    final pension = widget.hotelTgt.disponibility.pensions
        .firstWhere((p) => p.id == pensionId);
    final room = pension.rooms.firstWhere((r) => r.id == roomId);

    if (room.purchasePrice.isEmpty) return 0;

    final totalAdults = rooms.fold<int>(
        0, (s, r) => s + int.tryParse(r['adults']?.toString() ?? '0')!);
    final totalRooms = maxRoomsAllowed();
    final adultsPerRoom = (totalAdults / totalRooms).ceil();

    double roomTotalPrice = 0;
    for (var price in room.purchasePrice) {
      final basePricePerNight = calculateBasePrice(
        price.purchasePrice,
        price.commission,
        adultsPerRoom,
      );
      roomTotalPrice += basePricePerNight;
    }

    return roomTotalPrice * nights;
  }

  // Updated calculateTotal method with proper pricing logic
  double calculateTotal() {
    double total = 0;
    final nights = calculateNights();
    final rooms = widget.searchCriteria['rooms'] as List<Map<String, dynamic>>? ?? [];

    selectedRoomsByPension.forEach((pensionId, selectedRooms) {
      if (selectedRooms.isNotEmpty) {
        final pension = widget.hotelTgt.disponibility.pensions
            .firstWhere((p) => p.id == pensionId);

        selectedRooms.forEach((roomId, quantity) {
          final room = pension.rooms.firstWhere((r) => r.id == roomId);

          if (room.purchasePrice.isNotEmpty) {
            // Get the number of adults for this room selection
            // For simplicity, we'll use the total adults divided by total rooms
            // In a more complex implementation, you'd track which room gets which guests
            final totalAdults = rooms.fold<int>(
                0, (s, r) => s + int.tryParse(r['adults']?.toString() ?? '0')!);
            final totalRooms = maxRoomsAllowed();
            final adultsPerRoom = (totalAdults / totalRooms).ceil();

            // Calculate total purchase price from all price entries and their commissions
            double roomTotalPrice = 0;
            for (var price in room.purchasePrice) {
              final basePricePerNight = calculateBasePrice(
                price.purchasePrice,
                price.commission,
                adultsPerRoom,
              );
              roomTotalPrice += basePricePerNight;
            }

            // Calculate total for this room selection
            final roomTotal = roomTotalPrice * quantity * nights;
            total += roomTotal;
          }
        });
      }
    });

    return total;
  }

  String _getTravelersSummary() {
    final rooms = widget.searchCriteria['rooms'] as List<Map<String, dynamic>>? ?? [];
    final totalAdults = rooms.fold<int>(
        0, (s, r) => s + int.tryParse(r['adults']?.toString() ?? '0')!);
    final totalChildren = rooms.fold<int>(
        0, (s, r) => s + int.tryParse(r['children']?.toString() ?? '0')!);
    return "$totalAdults adultes, $totalChildren enfants";
  }

  void _updateRoomSelection(String pensionId, String roomId, int qty) {
    final pensionRooms = selectedRoomsByPension[pensionId] ?? {};
    int totalOtherPensions =
        totalSelectedRooms() - pensionRooms.values.fold(0, (a, b) => a + b);

    if (totalOtherPensions + qty <= maxRoomsAllowed()) {
      if (qty > 0) {
        pensionRooms[roomId] = qty;
      } else {
        pensionRooms.remove(roomId);
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Vous ne pouvez pas dépasser ${maxRoomsAllowed()} chambres au total.',
          ),
        ),
      );
    }

    setState(() {
      selectedRoomsByPension[pensionId] = pensionRooms;
    });
  }

  @override
  Widget build(BuildContext context) {
    final originalHotel = getOriginalHotel();
    final hotelCover = originalHotel?.cover ?? '';
    final hotelAddress = originalHotel?.address ?? '';
    final categoryCode = originalHotel?.categoryCode?.toString() ?? '';

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.hotelTgt.name,
          style: const TextStyle(
            color: AppColorstatic.lightTextColor,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppColorstatic.primary,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            HotelHeaderTgt(
              hotelName: widget.hotelTgt.name,
              slug: widget.hotelTgt.slug,
              cover: hotelCover,
              address: hotelAddress,
              category: categoryCode.isNotEmpty ? '$categoryCode étoiles' : null,

            ),
            const SizedBox(height: 16),
            SearchCriteriaCard(
              searchCriteria: widget.searchCriteria,
              travelersSummary: _getTravelersSummary(),
            ),
            const SizedBox(height: 16),
            PensionRoomSelectionTgt(
              pensions: widget.hotelTgt.disponibility.pensions,
              selectedRoomsByPension: selectedRoomsByPension,
              maxRooms: maxRoomsAllowed(),
              totalSelected: totalSelectedRooms(),
              onUpdate: _updateRoomSelection,
              calculateRoomPrice: calculateRoomPrice,
              nights: calculateNights(),
            ),
          ],
        ),
      ),
      bottomNavigationBar: ReservationBottomBar(
        total: calculateTotal(),
        currency: 'TND',
        onReserve: () => _handleFinalReservation(context),
      ),
    );
  }

  void _handleFinalReservation(BuildContext context) {
    final total = calculateTotal();
    final totalSelected = totalSelectedRooms();
    final maxAllowed = maxRoomsAllowed();

    if (totalSelected == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez sélectionner au moins une chambre.'),
        ),
      );
      return;
    }

    if (totalSelected != maxAllowed) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Vous devez sélectionner exactement $maxAllowed chambre(s). Actuellement: $totalSelected sélectionnée(s).'),
        ),
      );
      return;
    }

    // Prepare selected rooms data for API
    List<String> pensionIds = [];
    List<String> roomIds = [];
    List<int> quantities = [];

    // Create rooms summary for display
    String selectedRoomsSummary = '';
    selectedRoomsByPension.forEach((pensionId, rooms) {
      if (rooms.isNotEmpty) {
        final pension = widget.hotelTgt.disponibility.pensions
            .firstWhere((p) => p.id == pensionId);

        rooms.forEach((roomId, qty) {
          final room = pension.rooms.firstWhere((r) => r.id == roomId);

          pensionIds.add(pensionId);
          roomIds.add(roomId);
          quantities.add(qty);

          if (selectedRoomsSummary.isNotEmpty) selectedRoomsSummary += ', ';
          selectedRoomsSummary += '${room.title} (${pension.name}) x$qty';
        });
      }
    });

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => HotelReservationFormScreen(
          hotelName: widget.hotelTgt.name,
          hotelId: widget.hotelTgt.id,
          searchCriteria: widget.searchCriteria,
          totalPrice: total,
          currency: 'TND',
          selectedRoomsData: {
            'pensionIds': pensionIds,
            'roomIds': roomIds,
            'quantities': quantities,
            'selectedRoomsSummary': selectedRoomsSummary,
          },
          hotelType: 'tgt',
        ),
      ),
    );
  }
}
