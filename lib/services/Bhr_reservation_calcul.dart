import '../models/hotelBhr.dart';

class BhrReservationCalculator {
  static const double COMMISSION = 1.1;

  /// Calculates the maximum number of rooms allowed based on search criteria
  static int getMaxRoomsAllowed(Map<String, dynamic> searchCriteria) {
    final rooms = searchCriteria['rooms'] as List<Map<String, dynamic>>? ?? [];
    return rooms.length;
  }

  /// Calculates the total number of selected rooms across all boardings
  static int getTotalSelectedRooms(Map<String, Map<String, int>> selectedRoomsByBoarding) {
    int total = 0;
    selectedRoomsByBoarding.forEach((_, rooms) {
      total += rooms.values.fold(0, (a, b) => a + b);
    });
    return total;
  }

  /// Calculates the price for a specific room with boarding
  static double calculateRoomPrice(BoardingBhr boarding) {
    return boarding.rate * COMMISSION;
  }

  /// Calculates the cancellation fee for a specific boarding
  static double calculateCancellationFee(BoardingBhr boarding) {
    return boarding.cancellationPolicy.fee * COMMISSION;
  }

  /// Calculates the total price for all selected rooms
  static double calculateTotal(
      Map<String, Map<String, int>> selectedRoomsByBoarding,
      List<RoomBhr> rooms,
      ) {
    double total = 0;
    selectedRoomsByBoarding.forEach((boardingId, selectedRooms) {
      if (selectedRooms.isNotEmpty) {
        selectedRooms.forEach((roomId, qty) {
          try {
            final room = rooms.firstWhere((r) => r.id == roomId);
            final boarding = room.boardings.firstWhere((b) => b.id == boardingId);
            total += calculateRoomPrice(boarding) * qty;
          } catch (e) {
            // Room or boarding not found, skip
          }
        });
      }
    });
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

  /// Gets all unique boarding titles from rooms
  static List<String> getAllBoardingTitles(List<RoomBhr> rooms) {
    return rooms
        .expand((room) => room.boardings)
        .map((boarding) => boarding.title)
        .toSet()
        .toList();
  }

  /// Gets rooms that have a specific boarding title
  static List<RoomBhr> getRoomsForBoarding(List<RoomBhr> rooms, String boardingTitle) {
    return rooms
        .where((room) => room.boardings.any((boarding) => boarding.title == boardingTitle))
        .toList();
  }

  /// Gets the boarding object for a room with specific title
  static BoardingBhr? getBoardingForRoom(RoomBhr room, String boardingTitle) {
    try {
      return room.boardings.firstWhere((b) => b.title == boardingTitle);
    } catch (_) {
      return null;
    }
  }

  /// Gets total selected rooms for a specific boarding title
  static int getTotalForBoarding(
      List<RoomBhr> rooms,
      String boardingTitle,
      Map<String, Map<String, int>> selectedRoomsByBoarding,
      ) {
    int total = 0;
    final seenRoomIds = <String>{};

    for (var room in rooms) {
      if (seenRoomIds.contains(room.id)) continue;
      seenRoomIds.add(room.id);

      final boarding = getBoardingForRoom(room, boardingTitle);
      if (boarding != null) {
        final selected = selectedRoomsByBoarding[boarding.id] ?? {};
        final roomTotal = selected[room.id] ?? 0;
        total += roomTotal;
      }
    }
    return total;
  }

  /// Validates if the selection meets requirements
  static Map<String, dynamic> validateSelection(
      Map<String, Map<String, int>> selectedRoomsByBoarding,
      Map<String, dynamic> searchCriteria,
      ) {
    final totalSelected = getTotalSelectedRooms(selectedRoomsByBoarding);
    final maxAllowed = getMaxRoomsAllowed(searchCriteria);

    return {
      'isValid': totalSelected == maxAllowed && totalSelected > 0,
      'totalSelected': totalSelected,
      'maxAllowed': maxAllowed,
      'hasSelection': totalSelected > 0,
    };
  }

  /// Validates if a new room quantity can be added without exceeding limits
  static bool canUpdateRoomQuantity(
      Map<String, Map<String, int>> selectedRoomsByBoarding,
      String boardingId,
      String roomId,
      int newQty,
      int maxRooms,
      ) {
    final boardingRooms = selectedRoomsByBoarding[boardingId] ?? {};
    final currentQty = boardingRooms[roomId] ?? 0;
    final totalOtherRooms = getTotalSelectedRooms(selectedRoomsByBoarding) - currentQty;

    return totalOtherRooms + newQty <= maxRooms;
  }

  /// Prepares selected rooms data for API submission
  static Map<String, dynamic> prepareSelectedRoomsData(
      Map<String, Map<String, int>> selectedRoomsByBoarding,
      List<RoomBhr> rooms,
      ) {
    List<String> boardingIds = [];
    List<String> roomIds = [];
    List<int> quantities = [];
    String selectedRoomsSummary = '';

    selectedRoomsByBoarding.forEach((boardingId, roomsMap) {
      if (roomsMap.isNotEmpty) {
        try {
          roomsMap.forEach((roomId, qty) {
            try {
              final room = rooms.firstWhere((r) => r.id == roomId);
              final boarding = room.boardings.firstWhere((b) => b.id == boardingId);

              boardingIds.add(boardingId);
              roomIds.add(roomId);
              quantities.add(qty);

              if (selectedRoomsSummary.isNotEmpty) selectedRoomsSummary += ', ';
              selectedRoomsSummary += '${room.title} (${boarding.title}) x$qty';
            } catch (e) {
              // Room or boarding not found, skip
            }
          });
        } catch (e) {
          // Error processing boarding, skip
        }
      }
    });

    return {
      'boardingIds': boardingIds,
      'roomIds': roomIds,
      'quantities': quantities,
      'selectedRoomsSummary': selectedRoomsSummary,
    };
  }
}