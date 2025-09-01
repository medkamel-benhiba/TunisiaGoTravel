import 'package:flutter/material.dart';
import '../models/hotelTgt.dart';
import '../theme/color.dart';
import '../widgets/reservation/HotelHeaderTgt.dart';
import '../widgets/reservation/RoomSelectionTgt.dart';
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

  double calculateTotal() {
    double total = 0;
    selectedRoomsByPension.forEach((pensionId, selectedRooms) {
      if (selectedRooms.isNotEmpty) {
        final pension = widget.hotelTgt.disponibility.pensions
            .firstWhere((p) => p.id == pensionId);

        selectedRooms.forEach((roomId, qty) {
          final room = pension.rooms.firstWhere((r) => r.id == roomId);
          if (room.purchasePrice.isNotEmpty) {
            total += room.purchasePrice.first.purchasePrice * qty;
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

    // Navigate to form screen
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
/*import 'package:flutter/material.dart';
import '../models/hotelTgt.dart';
import '../services/hotelTgt_calcul.dart';
import '../theme/color.dart';
import '../widgets/reservation/HotelHeaderTgt.dart';
import '../widgets/reservation/RoomSelectionTgt.dart';
import '../widgets/reservation/reservation_bar_tgt.dart';
import '../widgets/reservation/reservation_bottom_bar.dart';
import '../widgets/reservation/search_summary.dart';

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
  Map<String, Map<String, int>> selectedRoomsByPurchasePrice = {};
  late int nights;

  @override
  void initState() {
    super.initState();
    nights = HotelCalculationService.calculateNights(widget.searchCriteria);
    _initializeSelectedRooms();
  }

  void _initializeSelectedRooms() {
    // Initialize with unique prices only to avoid duplicates
    final Set<String> seenPriceIds = {};

    for (var pension in widget.hotelTgt.disponibility.pensions) {
      final uniqueRooms = HotelCalculationService.getUniqueRoomsFromPension(
          pension);

      for (var room in uniqueRooms) {
        final bestPrice = HotelCalculationService.getBestPriceForRoom(
            room, widget.searchCriteria);
        if (bestPrice != null && !seenPriceIds.contains(bestPrice.id)) {
          selectedRoomsByPurchasePrice[bestPrice.id] = {};
          seenPriceIds.add(bestPrice.id);
        }
      }
    }
  }

  int maxRoomsAllowed() {
    final rooms = widget.searchCriteria['rooms'] as List<
        Map<String, dynamic>>? ?? [];
    return rooms.length > 0 ? rooms.length : 1;
  }

  int totalSelectedRooms() {
    int total = 0;
    selectedRoomsByPurchasePrice.forEach((_, rooms) {
      total += rooms.values.fold(0, (a, b) => a + b);
    });
    return total;
  }

  double calculateTotal() {
    return HotelCalculationService.calculateTotalPrice(
      selectedRoomsByPurchasePrice,
      widget.hotelTgt.disponibility.pensions,
      nights,
    );
  }

  String _getTravelersSummary() {
    final rooms = widget.searchCriteria['rooms'] as List<
        Map<String, dynamic>>? ?? [];
    if (rooms.isEmpty) {
      return "2 adultes, 0 enfants";
    }

    final totalAdults = rooms.fold<int>(
        0, (s, r) => s + (int.tryParse(r['adults']?.toString() ?? '2') ?? 2));
    final totalChildren = rooms.fold<int>(
        0, (s, r) => s + (int.tryParse(r['children']?.toString() ?? '0') ?? 0));
    return "$totalAdults adultes, $totalChildren enfants";
  }

  void _updateRoomSelection(String priceId, String roomId, int qty) {
    setState(() {
      final roomSelection = selectedRoomsByPurchasePrice[priceId] ?? {};
      int totalOtherRooms = totalSelectedRooms() -
          roomSelection.values.fold(0, (a, b) => a + b);

      if (totalOtherRooms + qty <= maxRoomsAllowed()) {
        if (qty > 0) {
          roomSelection[roomId] = qty;
          selectedRoomsByPurchasePrice[priceId] = roomSelection;
        } else {
          roomSelection.remove(roomId);
          selectedRoomsByPurchasePrice[priceId] = roomSelection;
        }
      } else {
        _showRoomLimitError();
      }
    });
  }

  void _showRoomLimitError() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Vous ne pouvez pas dépasser ${maxRoomsAllowed()} chambres au total.',
        ),
        backgroundColor: Colors.orange,
        duration: const Duration(seconds: 3),
        action: SnackBarAction(
          label: 'OK',
          textColor: Colors.white,
          onPressed: () => ScaffoldMessenger.of(context).hideCurrentSnackBar(),
        ),
      ),
    );
  }

  void _handleFinalReservation(BuildContext context) {
    final validation = HotelCalculationService.validateRoomSelection(
      selectedRoomsByPurchasePrice,
      widget.searchCriteria,
      widget.hotelTgt.disponibility.pensions,
    );

    if (!validation['isValid']) {
      _showValidationErrors(validation['errors']);
      return;
    }

    final total = calculateTotal();
    final summary = HotelCalculationService.getAccommodationSummary(
      selectedRoomsByPurchasePrice,
      widget.hotelTgt.disponibility.pensions,
    );

    _showReservationConfirmation(total, summary);
  }

  void _showValidationErrors(List<String> errors) {
    showDialog(
      context: context,
      builder: (_) =>
          AlertDialog(
            title: const Text('Sélection invalide'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: errors.map((error) => Text('• $error')).toList(),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Compris"),
              ),
            ],
          ),
    );
  }

  void _showReservationConfirmation(double total,
      Map<String, dynamic> summary) {
    final formattedSummary = HotelCalculationService.formatAccommodationSummary(
        summary, nights);

    showDialog(
      context: context,
      builder: (_) =>
          AlertDialog(
            title: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green[600], size: 28),
                const SizedBox(width: 8),
                const Text('Réservation confirmée'),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "🏨 ${widget.hotelTgt.name}",
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  Text("📅 Séjour de $nights nuit${nights > 1 ? 's' : ''}"),
                  const SizedBox(height: 8),
                  Text("👥 ${_getTravelersSummary()}"),
                  const SizedBox(height: 12),
                  if (formattedSummary.isNotEmpty) ...[
                    const Text(
                      "Détails de la réservation:",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(formattedSummary),
                    const SizedBox(height: 12),
                  ],
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.green[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.green[200]!),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Prix total:",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        Text(
                          "${total.toStringAsFixed(2)} TND",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: Colors.green[700],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Fermer"),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  // Here you would typically navigate to payment or booking confirmation
                  _proceedToBooking();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColorstatic.primary,
                  foregroundColor: Colors.white,
                ),
                child: const Text("Confirmer"),
              ),
            ],
          ),
    );
  }

  void _proceedToBooking() {
    // Navigate to payment screen or booking confirmation
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Redirection vers la page de paiement...'),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.hotelTgt.name,
          style: const TextStyle(
            color: AppColorstatic.lightTextColor,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppColorstatic.primary,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 2,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  HotelHeaderTgt(
                    hotelName: widget.hotelTgt.name,
                    address: widget.hotelTgt.idCityBbx ??
                        'Adresse non disponible',
                    cover: '', // Add cover image URL if available
                  ),
                  const SizedBox(height: 16),
                  SearchCriteriaCard(
                    searchCriteria: widget.searchCriteria,
                    travelersSummary: _getTravelersSummary(),
                  ),
                  const SizedBox(height: 16),
                  BoardingRoomSelectionTgt(
                    pensions: widget.hotelTgt.disponibility.pensions,
                    selectedRoomsByPurchasePrice: selectedRoomsByPurchasePrice,
                    maxRooms: maxRoomsAllowed(),
                    totalSelected: totalSelectedRooms(),
                    searchCriteria: widget.searchCriteria,
                    onUpdate: _updateRoomSelection,
                  ),
                  const SizedBox(height: 100), // Space for bottom bar
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: ReservationBottomBarTgt(
          total: calculateTotal(),
          currency: 'TND',
          nights: nights,
          totalRooms: totalSelectedRooms(),
          onReserve: () => _handleFinalReservation(context),
        ),
      ),
    );
  }
}*/