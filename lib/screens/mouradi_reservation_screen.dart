import 'package:flutter/material.dart';
import '../models/mouradi.dart';
import '../theme/color.dart';
import '../widgets/reservation/HotelHeader.dart';
import '../widgets/reservation/boarding_selection.dart';
import '../widgets/reservation/reservation_bottom_bar.dart';
import '../widgets/reservation/search_summary.dart';

class MouradiReservationScreen extends StatefulWidget {
  final MouradiHotel hotel;
  final Map<String, dynamic> searchCriteria;

  const MouradiReservationScreen({
    super.key,
    required this.hotel,
    required this.searchCriteria,
  });

  @override
  State<MouradiReservationScreen> createState() =>
      _MouradiReservationScreenState();
}

class _MouradiReservationScreenState extends State<MouradiReservationScreen> {
  BoardingOption? selectedBoarding;

  // Track rooms selected per boarding option
  Map<int, Map<int, int>> selectedRoomsByBoarding = {};

  @override
  void initState() {
    super.initState();
    selectedBoarding = widget.hotel.boardings.first;

    // Initialize empty selection for each boarding
    for (var boarding in widget.hotel.boardings) {
      selectedRoomsByBoarding[boarding.id] = {};
    }
  }

  int maxRoomsAllowed() {
    final rooms =
        widget.searchCriteria['rooms'] as List<Map<String, dynamic>>? ?? [];
    return rooms.length;
  }

  /// Total selected rooms across all boardings
  int totalSelectedRooms() {
    int total = 0;
    selectedRoomsByBoarding.forEach((_, rooms) {
      total += rooms.values.fold(0, (a, b) => a + b);
    });
    return total;
  }

  double calculateTotal() {
    double total = 0;
    for (var boarding in widget.hotel.boardings) {
      final rooms = selectedRoomsByBoarding[boarding.id] ?? {};
      for (var pax in boarding.pax) {
        for (var room in pax.rooms) {
          final qty = rooms[room.id] ?? 0;
          total += room.price * qty;
        }
      }
    }
    return total;
  }

  String _getTravelersSummary() {
    final rooms =
        widget.searchCriteria['rooms'] as List<Map<String, dynamic>>? ?? [];
    final totalAdults = rooms.fold<int>(
        0, (s, r) => s + int.tryParse(r['adults']?.toString() ?? '0')!);
    final totalChildren = rooms.fold<int>(
        0, (s, r) => s + int.tryParse(r['children']?.toString() ?? '0')!);
    return "$totalAdults adultes, $totalChildren enfants";
  }

  void _updateRoomSelection(int boardingId, int roomId, int qty) {
    final boardingRooms = selectedRoomsByBoarding[boardingId] ?? {};

    // Total rooms selected excluding current boarding
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

  @override
  Widget build(BuildContext context) {
    final hotel = widget.hotel;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          hotel.name,
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
            HotelHeader(hotel: hotel),
            const SizedBox(height: 16),
            SearchCriteriaCard(
              searchCriteria: widget.searchCriteria,
              travelersSummary: _getTravelersSummary(),
            ),
            const SizedBox(height: 16),

            BoardingRoomSelection(
              boardings: hotel.boardings,
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
        currency: hotel.currency,
        onReserve: () => _handleFinalReservation(context),
      ),
    );
  }

  void _handleFinalReservation(BuildContext context) {
    final total = calculateTotal();

    final selectedRoomDetails = widget.hotel.boardings.map((boarding) {
      final rooms = selectedRoomsByBoarding[boarding.id] ?? {};
      if (rooms.isEmpty) return null;
      final roomDetails = rooms.entries.map((e) {
        final room = boarding.pax
            .expand((p) => p.rooms)
            .firstWhere((r) => r.id == e.key);
        return '${room.name} x ${e.value}';
      }).join(', ');
      return '${boarding.name}: $roomDetails';
    }).whereType<String>().join('\n');

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Réservation confirmée'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Hôtel: ${widget.hotel.name}"),
            if (selectedRoomDetails.isNotEmpty)
              Text("Chambres:\n$selectedRoomDetails"),
            Text("Prix total: ${total.toStringAsFixed(2)} ${widget.hotel.currency}"),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }
}
