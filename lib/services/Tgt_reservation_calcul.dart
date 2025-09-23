import '../models/hotelTgt.dart';

class TgtReservationCalculator {
  /// Calculates the number of nights between check-in and check-out dates
  static int calculateNights(Map<String, dynamic> searchCriteria) {
    try {
      final checkIn = DateTime.parse(searchCriteria['checkIn']);
      final checkOut = DateTime.parse(searchCriteria['checkOut']);
      return checkOut.difference(checkIn).inDays;
    } catch (e) {
      return 1;
    }
  }

  /// Calculates the maximum number of rooms allowed based on search criteria
  static int getMaxRoomsAllowed(Map<String, dynamic> searchCriteria) {
    final rooms = searchCriteria['rooms'] as List<Map<String, dynamic>>? ?? [];
    return rooms.length;
  }

  /// Calculates the total number of selected rooms
  static int getTotalSelectedRooms(Map<String, Map<String, int>> selectedRoomsByPension) {
    int total = 0;
    selectedRoomsByPension.forEach((pensionId, rooms) {
      rooms.forEach((roomId, qty) {
        total += qty;
      });
    });
    return total;
  }

  /// Calculates the price for a specific room
  static double calculateRoomPrice(
      String pensionId,
      String roomId,
      List<PensionTgt> pensions,
      int nights, {
        required int numberOfAdults,
      }) {
    try {
      final pension = pensions.firstWhere((p) => p.id == pensionId);
      final room = pension.rooms.firstWhere((r) => r.id == roomId);

      if (room.purchasePrice.isEmpty) return 0;

      double roomTotalPrice = 0;
      for (var price in room.purchasePrice) {
        final basePricePerNight = (price.purchasePrice + (price.purchasePrice * 12 / 100)) * numberOfAdults;
        roomTotalPrice += basePricePerNight;
      }

      return roomTotalPrice * nights;
    } catch (e) {
      return 0;
    }
  }

  /// Calculates the total price for all selected rooms
  static double calculateTotal(
      Map<String, Map<String, int>> selectedRoomsByPension,
      List<PensionTgt> pensions,
      Map<String, dynamic> searchCriteria,
      ) {
    final nights = calculateNights(searchCriteria);
    double total = 0;

    // Step 1: Collect all selected room instances (repeat by qty)
    List<Map<String, dynamic>> selectedRoomList = [];
    selectedRoomsByPension.forEach((pensionId, roomsMap) {
      try {
        final pension = pensions.firstWhere((p) => p.id == pensionId);
        roomsMap.forEach((roomId, qty) {
          try {
            final room = pension.rooms.firstWhere((r) => r.id == roomId);
            final capacityAdults = room.capacity.isNotEmpty ? room.capacity.first.adults : 0;
            for (int i = 0; i < qty; i++) {
              selectedRoomList.add({
                'pensionId': pensionId,
                'roomId': roomId,
                'capacity': capacityAdults,
              });
            }
          } catch (e) {
            // Room not found, skip
          }
        });
      } catch (e) {
        // Pension not found, skip
      }
    });

    // Step 2: Sort selected rooms by capacity descending
    selectedRoomList.sort((a, b) => b['capacity'].compareTo(a['capacity']));

    // Step 3: Sort searchRooms by adults descending
    var searchRooms = searchCriteria['rooms'] as List<Map<String, dynamic>>? ?? [];
    var sortedSearchRooms = List<Map<String, dynamic>>.from(searchRooms);
    sortedSearchRooms.sort((a, b) =>
    (int.tryParse(b['adults'].toString()) ?? 0) -
        (int.tryParse(a['adults'].toString()) ?? 0));

    // Step 4: Assign adults to rooms and calculate total
    for (int i = 0; i < selectedRoomList.length && i < sortedSearchRooms.length; i++) {
      final sel = selectedRoomList[i];
      final adults = int.tryParse(sortedSearchRooms[i]['adults'].toString()) ?? 0;

      // Cap at room capacity to avoid overpricing
      final effectiveAdults = adults > sel['capacity'] ? sel['capacity'] : adults;

      total += calculateRoomPrice(
        sel['pensionId'],
        sel['roomId'],
        pensions,
        nights,
        numberOfAdults: effectiveAdults,
      );
    }

    return total;
  }

  /// Gets a summary of travelers from search criteria
  static String getTravelersSummary(Map<String, dynamic> searchCriteria) {
    final rooms = searchCriteria['rooms'] as List<Map<String, dynamic>>? ?? [];
    final totalAdults = rooms.fold<int>(
        0, (s, r) => s + (int.tryParse(r['adults']?.toString() ?? '0') ?? 0));
    final totalChildren = rooms.fold<int>(
        0, (s, r) => s + (int.tryParse(r['children']?.toString() ?? '0') ?? 0));
    return '$totalAdults Adults, $totalChildren Children';
  }

  /// Validates if the selection meets requirements
  static Map<String, dynamic> validateSelection(
      Map<String, Map<String, int>> selectedRoomsByPension,
      Map<String, dynamic> searchCriteria,
      ) {
    final totalSelected = getTotalSelectedRooms(selectedRoomsByPension);
    final maxAllowed = getMaxRoomsAllowed(searchCriteria);

    return {
      'isValid': totalSelected == maxAllowed && totalSelected > 0,
      'totalSelected': totalSelected,
      'maxAllowed': maxAllowed,
      'hasSelection': totalSelected > 0,
    };
  }

  /// Prepares selected rooms data for API submission
  static Map<String, dynamic> prepareSelectedRoomsData(
      Map<String, Map<String, int>> selectedRoomsByPension,
      List<PensionTgt> pensions,
      ) {
    List<String> pensionIds = [];
    List<String> roomIds = [];
    List<int> quantities = [];
    String selectedRoomsSummary = '';

    selectedRoomsByPension.forEach((pensionId, rooms) {
      if (rooms.isNotEmpty) {
        try {
          final pension = pensions.firstWhere((p) => p.id == pensionId);

          rooms.forEach((roomId, qty) {
            try {
              final room = pension.rooms.firstWhere((r) => r.id == roomId);

              pensionIds.add(pensionId);
              roomIds.add(roomId);
              quantities.add(qty);

              if (selectedRoomsSummary.isNotEmpty) selectedRoomsSummary += ', ';
              selectedRoomsSummary += '${room.title} (${pension.name}) x$qty';
            } catch (e) {
              // Room not found, skip
            }
          });
        } catch (e) {
          // Pension not found, skip
        }
      }
    });

    return {
      'pensionIds': pensionIds,
      'roomIds': roomIds,
      'quantities': quantities,
      'selectedRoomsSummary': selectedRoomsSummary,
    };
  }
}