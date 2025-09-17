import 'package:easy_localization/easy_localization.dart';
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
  // Key: Pension ID, Value: Map<Room ID, Quantity>
  Map<String, Map<String, int>> selectedRoomsByPension = {};

  @override
  void initState() {
    super.initState();
    for (var pension in widget.hotelTgt.disponibility.pensions) {
      selectedRoomsByPension[pension.id] = {};
    }

    debugPrint('=== HotelTgt Data ===');
    debugPrint('ID: ${widget.hotelTgt.id}');
    debugPrint('Slug: ${widget.hotelTgt.slug}');
    debugPrint('Name map: ${widget.hotelTgt.name}');
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
    selectedRoomsByPension.forEach((pensionId, rooms) {
      rooms.forEach((roomId, qty) {
        total += qty;
      });
    });
    return total;
  }

  int calculateNights() {
    try {
      final checkIn = DateTime.parse(widget.searchCriteria['checkIn']);
      final checkOut = DateTime.parse(widget.searchCriteria['checkOut']);
      return checkOut.difference(checkIn).inDays;
    } catch (e) {
      return 1;
    }
  }

  double calculateRoomPrice(String pensionId, String roomId, {required int numberOfAdults}) {
    final nights = calculateNights();

    final pension = widget.hotelTgt.disponibility.pensions
        .firstWhere((p) => p.id == pensionId);
    final room = pension.rooms.firstWhere((r) => r.id == roomId);

    if (room.purchasePrice.isEmpty) return 0;

    double roomTotalPrice = 0;
    for (var price in room.purchasePrice) {
      final basePricePerNight = (price.purchasePrice + (price.purchasePrice * 12 / 100)) * numberOfAdults;
      roomTotalPrice += basePricePerNight;
    }

    return roomTotalPrice * nights;
  }

  double calculateTotal() {
    double total = 0;

    // Step 1: Collect all selected room instances (repeat by qty)
    List<Map<String, dynamic>> selectedRoomList = [];
    selectedRoomsByPension.forEach((pensionId, roomsMap) {
      final pension = widget.hotelTgt.disponibility.pensions
          .firstWhere((p) => p.id == pensionId);
      roomsMap.forEach((roomId, qty) {
        final room = pension.rooms.firstWhere((r) => r.id == roomId);
        final capacityAdults = room.capacity.isNotEmpty ? room.capacity.first.adults : 0;
        for (int i = 0; i < qty; i++) {
          selectedRoomList.add({
            'pensionId': pensionId,
            'roomId': roomId,
            'capacity': capacityAdults,
          });
        }
      });
    });

    // Step 2: Sort selected rooms by capacity descending
    selectedRoomList.sort((a, b) => b['capacity'].compareTo(a['capacity']));

    // Step 3: Sort searchRooms by adults descending
    var searchRooms = widget.searchCriteria['rooms'] as List<Map<String, dynamic>>? ?? [];
    var sortedSearchRooms = List<Map<String, dynamic>>.from(searchRooms);
    sortedSearchRooms.sort((a, b) =>
    (int.tryParse(b['adults'].toString()) ?? 0) -
        (int.tryParse(a['adults'].toString()) ?? 0));

    // Step 4: Assign adults to rooms and calculate total
    for (int i = 0; i < selectedRoomList.length && i < sortedSearchRooms.length; i++) {
      final sel = selectedRoomList[i];
      final adults = int.tryParse(sortedSearchRooms[i]['adults'].toString()) ?? 0;

      // Optional: Validate that adults don't exceed room capacity
      if (adults > sel['capacity']) {
        // Log warning or handle mismatch (e.g., skip, cap, or show error)
        // For now, cap at capacity to avoid overpricing
        total += calculateRoomPrice(
          sel['pensionId'],
          sel['roomId'],
          numberOfAdults: sel['capacity'], // Cap at room capacity
        );
      } else {
        total += calculateRoomPrice(
          sel['pensionId'],
          sel['roomId'],
          numberOfAdults: adults,
        );
      }
    }

    return total;
  }

  String _getTravelersSummary() {
    final rooms = widget.searchCriteria['rooms'] as List<Map<String, dynamic>>? ?? [];
    final totalAdults = rooms.fold<int>(
        0, (s, r) => s + int.tryParse(r['adults']?.toString() ?? '0')!);
    final totalChildren = rooms.fold<int>(
        0, (s, r) => s + int.tryParse(r['children']?.toString() ?? '0')!);
    return tr('guests_summary', args: [totalAdults.toString(), totalChildren.toString()]);
  }

  void _updateRoomSelection(String pensionId, String roomId, int newQty) {
    setState(() {
      selectedRoomsByPension[pensionId]![roomId] = newQty;
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
          widget.hotelTgt.getName(context.locale),
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
              hotelName: widget.hotelTgt.getName(context.locale),
              slug: widget.hotelTgt.slug,
              cover: hotelCover,
              address: hotelAddress,
              category: null,
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