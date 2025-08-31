import 'package:flutter/material.dart';
import '../models/hotel.dart';
import '../models/hotelBhr.dart';
import '../theme/color.dart';
import '../widgets/reservation/HotelHeaderBhr.dart';
import '../widgets/reservation/BoardingRoomSelectionBhr.dart';
import '../widgets/reservation/reservation_bottom_bar.dart';
import '../widgets/reservation/search_summary.dart';
import 'hotel_reservation_form.dart';

class HotelBhrReservationScreen extends StatefulWidget {
  final HotelBhr hotelBhr;
  final List<Hotel> allHotels;
  final Map<String, dynamic> searchCriteria;

  const HotelBhrReservationScreen({
    super.key,
    required this.hotelBhr,
    required this.allHotels,
    required this.searchCriteria,
  });

  @override
  State<HotelBhrReservationScreen> createState() =>
      _HotelBhrReservationScreenState();
}

class _HotelBhrReservationScreenState extends State<HotelBhrReservationScreen> {
  Map<String, Map<String, int>> selectedRoomsByBoarding = {};

  @override
  void initState() {
    super.initState();
    for (var room in widget.hotelBhr.disponibility.rooms) {
      for (var boarding in room.boardings) {
        selectedRoomsByBoarding[boarding.id] = {};
      }
    }
  }

  int maxRoomsAllowed() {
    final rooms = widget.searchCriteria['rooms'] as List<Map<String, dynamic>>? ?? [];
    return rooms.length;
  }

  int totalSelectedRooms() {
    int total = 0;
    selectedRoomsByBoarding.forEach((_, rooms) {
      total += rooms.values.fold(0, (a, b) => a + b);
    });
    return total;
  }

  double calculateTotal() {
    double total = 0;
    selectedRoomsByBoarding.forEach((boardingId, selectedRooms) {
      if (selectedRooms.isNotEmpty) {
        final boarding = widget.hotelBhr.disponibility.rooms
            .expand((room) => room.boardings)
            .firstWhere((b) => b.id == boardingId);

        selectedRooms.forEach((roomId, qty) {
          total += boarding.rate * qty;
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

  void _updateRoomSelection(String boardingId, String roomId, int qty) {
    final boardingRooms = selectedRoomsByBoarding[boardingId] ?? {};
    int totalOtherBoardings =
        totalSelectedRooms() - boardingRooms.values.fold(0, (a, b) => a + b);

    if (totalOtherBoardings + qty <= maxRoomsAllowed()) {
      if (qty > 0) {
        boardingRooms[roomId] = qty;
      } else {
        boardingRooms.remove(roomId);
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
      selectedRoomsByBoarding[boardingId] = boardingRooms;
    });
  }

  Hotel? getHotelFromBhr() {
    try {
      return widget.allHotels.firstWhere(
            (h) => (h.id ?? '').trim() == widget.hotelBhr.id.trim(),
      );
    } catch (_) {
      debugPrint('No hotel found for HotelBhr ID: ${widget.hotelBhr.id}');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final mappedHotel = getHotelFromBhr();
    final hotelCover = mappedHotel?.cover ?? '';
    final hotelName = mappedHotel?.name ?? widget.hotelBhr.name;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          hotelName,
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
            HotelHeaderBhr(
              hotelName: hotelName,
              address: widget.hotelBhr.disponibility.address,
              cover: hotelCover,
              category: widget.hotelBhr.disponibility.category,
            ),
            const SizedBox(height: 16),
            SearchCriteriaCard(
              searchCriteria: widget.searchCriteria,
              travelersSummary: _getTravelersSummary(),
            ),
            const SizedBox(height: 16),
            BoardingRoomSelectionBhr(
              rooms: widget.hotelBhr.disponibility.rooms,
              selectedRoomsByBoarding: selectedRoomsByBoarding,
              maxRooms: maxRoomsAllowed(),
              totalSelected: totalSelectedRooms(),
              onUpdate: _updateRoomSelection,
            ),
          ],
        ),
      ),
      bottomNavigationBar: ReservationBottomBar(
        total: calculateTotal(),
        currency: 'TND',
        onReserve: () => _handleFinalReservation(context, hotelName),
      ),
    );
  }

  void _handleFinalReservation(BuildContext context, String hotelName) {
    final total = calculateTotal();
    final totalSelected = totalSelectedRooms();
    final maxAllowed = maxRoomsAllowed();

    // Check if the exact number of rooms are selected
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
    List<String> boardingIds = [];
    List<String> roomIds = [];
    List<int> quantities = [];

    // Create rooms summary for display
    String selectedRoomsSummary = '';
    selectedRoomsByBoarding.forEach((boardingId, rooms) {
      if (rooms.isNotEmpty) {
        final boarding = widget.hotelBhr.disponibility.rooms
            .expand((room) => room.boardings)
            .firstWhere((b) => b.id == boardingId);

        rooms.forEach((roomId, qty) {
          final room = widget.hotelBhr.disponibility.rooms
              .firstWhere((r) => r.boardings.any((b) => b.id == boardingId));

          boardingIds.add(boardingId);
          roomIds.add(roomId);
          quantities.add(qty);

          if (selectedRoomsSummary.isNotEmpty) selectedRoomsSummary += ', ';
          selectedRoomsSummary += '${room.title} (${boarding.title}) x$qty';
        });
      }
    });

    // Navigate to form screen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => HotelReservationFormScreen(
          hotelName: hotelName,
          hotelId: widget.hotelBhr.id,
          searchCriteria: widget.searchCriteria,
          totalPrice: total,
          currency: 'TND',
          selectedRoomsData: {
            'boardingIds': boardingIds,
            'roomIds': roomIds,
            'quantities': quantities,
            'selectedRoomsSummary': selectedRoomsSummary,
          },
          hotelType: 'bhr',
        ),
      ),
    );
  }
}