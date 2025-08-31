// services/hotel_calculation_service.dart

import '../models/hotelTgt.dart';

class HotelCalculationService {
  /// Calculate total nights between check-in and check-out
  static int calculateNights(Map<String, dynamic> searchCriteria) {
    try {
      final checkIn = DateTime.parse(searchCriteria['checkIn'] ?? '');
      final checkOut = DateTime.parse(searchCriteria['checkOut'] ?? '');
      final nights = checkOut.difference(checkIn).inDays;
      return nights > 0 ? nights : 1;
    } catch (e) {
      return 1;
    }
  }

  /// Get unique rooms from pension (removes duplicates based on room ID)
  static List<RoomTgt> getUniqueRoomsFromPension(PensionTgt pension) {
    final Map<String, RoomTgt> uniqueRooms = {};

    for (var room in pension.rooms) {
      if (!uniqueRooms.containsKey(room.id)) {
        uniqueRooms[room.id] = room;
      }
    }

    return uniqueRooms.values.toList();
  }

  /// Get the best available price for a room within search dates
  static PurchasePrice? getBestPriceForRoom(
      RoomTgt room,
      Map<String, dynamic> searchCriteria
      ) {
    if (room.purchasePrice.isEmpty) return null;

    // Filter prices that are valid for the search dates
    final validPrices = room.purchasePrice.where((price) =>
        isPriceValidForDates(price, searchCriteria)).toList();

    if (validPrices.isEmpty) return null;

    // Remove duplicates based on ID (your API has duplicate entries)
    final Map<String, PurchasePrice> uniquePrices = {};
    for (var price in validPrices) {
      if (!uniquePrices.containsKey(price.id) ||
          price.purchasePrice < uniquePrices[price.id]!.purchasePrice) {
        uniquePrices[price.id] = price;
      }
    }

    // Return the lowest price
    final prices = uniquePrices.values.toList();
    prices.sort((a, b) => a.purchasePrice.compareTo(b.purchasePrice));
    return prices.first;
  }

  /// Check if a price is valid for the given search dates
  static bool isPriceValidForDates(
      PurchasePrice price,
      Map<String, dynamic> searchCriteria
      ) {
    if (!price.status) return false;

    try {
      final searchStart = DateTime.parse(searchCriteria['checkIn'] ?? '');
      final searchEnd = DateTime.parse(searchCriteria['checkOut'] ?? '');
      final priceStart = DateTime.parse(price.dateStart);
      final priceEnd = DateTime.parse(price.dateEnd);

      // Check if search dates overlap with price validity dates
      return searchStart.isBefore(priceEnd) && searchEnd.isAfter(priceStart);
    } catch (e) {
      return false;
    }
  }

  /// Calculate total price for selected rooms
  static double calculateTotalPrice(
      Map<String, Map<String, int>> selectedRoomsByPurchasePrice,
      List<PensionTgt> pensions,
      int nights
      ) {
    double total = 0;

    selectedRoomsByPurchasePrice.forEach((priceId, selectedRooms) {
      if (selectedRooms.isNotEmpty) {
        // Find the corresponding price object
        PurchasePrice? foundPrice = findPurchasePriceById(priceId, pensions);

        if (foundPrice != null) {
          selectedRooms.forEach((roomId, qty) {
            // Price is per night, so multiply by number of nights and quantity
            total += foundPrice.purchasePrice * nights * qty;
          });
        }
      }
    });

    return total;
  }

  /// Find a purchase price by ID across all pensions and rooms
  static PurchasePrice? findPurchasePriceById(String priceId, List<PensionTgt> pensions) {
    for (var pension in pensions) {
      for (var room in pension.rooms) {
        for (var price in room.purchasePrice) {
          if (price.id == priceId) {
            return price;
          }
        }
      }
    }
    return null;
  }

  /// Get accommodation summary for selected rooms
  static Map<String, dynamic> getAccommodationSummary(
      Map<String, Map<String, int>> selectedRoomsByPurchasePrice,
      List<PensionTgt> pensions
      ) {
    Map<String, List<Map<String, dynamic>>> pensionSummary = {};

    selectedRoomsByPurchasePrice.forEach((priceId, selectedRooms) {
      if (selectedRooms.isNotEmpty) {
        // Find corresponding pension, room, and price
        for (var pension in pensions) {
          for (var room in pension.rooms) {
            for (var price in room.purchasePrice) {
              if (price.id == priceId) {
                selectedRooms.forEach((roomId, qty) {
                  if (qty > 0 && roomId == room.id) {
                    if (!pensionSummary.containsKey(pension.name)) {
                      pensionSummary[pension.name] = [];
                    }

                    pensionSummary[pension.name]!.add({
                      'roomTitle': room.title,
                      'quantity': qty,
                      'pricePerNight': price.purchasePrice,
                      'currency': price.currency,
                    });
                  }
                });
              }
            }
          }
        }
      }
    });

    return {
      'pensions': pensionSummary,
      'totalRooms': selectedRoomsByPurchasePrice.values
          .fold<int>(0, (sum, rooms) =>
      sum + rooms.values.fold<int>(0, (s, qty) => s + qty)),
    };
  }

  /// Format accommodation summary for display
  static String formatAccommodationSummary(
      Map<String, dynamic> summary,
      int nights
      ) {
    List<String> details = [];
    final pensions = summary['pensions'] as Map<String, List<Map<String, dynamic>>>;

    pensions.forEach((pensionName, rooms) {
      details.add('\n📋 $pensionName:');
      for (var room in rooms) {
        final totalPrice = room['pricePerNight'] * nights * room['quantity'];
        details.add(
            '  • ${room['roomTitle']} x ${room['quantity']}\n'
                '    ${room['pricePerNight'].toStringAsFixed(2)} ${room['currency']}/nuit\n'
                '    Total: ${totalPrice.toStringAsFixed(2)} ${room['currency']}'
        );
      }
    });

    return details.join('\n');
  }

  /// Get pension type icon based on name
  static String getPensionTypeDescription(String pensionName) {
    final name = pensionName.toLowerCase();
    if (name.contains('all inclusive') || name.contains('tout compris')) {
      return 'Tous les repas et boissons inclus';
    } else if (name.contains('demi pension') || name.contains('half board')) {
      return 'Petit-déjeuner et dîner inclus';
    } else if (name.contains('petit déjeuner') || name.contains('breakfast')) {
      return 'Petit-déjeuner inclus';
    } else if (name.contains('pension complète') || name.contains('full board')) {
      return 'Tous les repas inclus';
    } else {
      return 'Logement seul';
    }
  }

  /// Validate room selection against search criteria
  static Map<String, dynamic> validateRoomSelection(
      Map<String, Map<String, int>> selectedRooms,
      Map<String, dynamic> searchCriteria,
      List<PensionTgt> pensions
      ) {
    final requestedRooms = searchCriteria['rooms'] as List<Map<String, dynamic>>? ?? [];
    final maxRoomsAllowed = requestedRooms.length;

    int totalSelected = 0;
    selectedRooms.forEach((_, rooms) {
      totalSelected += rooms.values.fold(0, (a, b) => a + b);
    });

    return {
      'isValid': totalSelected <= maxRoomsAllowed && totalSelected > 0,
      'totalSelected': totalSelected,
      'maxAllowed': maxRoomsAllowed,
      'errors': _getValidationErrors(totalSelected, maxRoomsAllowed),
    };
  }

  static List<String> _getValidationErrors(int totalSelected, int maxAllowed) {
    List<String> errors = [];

    if (totalSelected == 0) {
      errors.add('Veuillez sélectionner au moins une chambre');
    }
    if (totalSelected > maxAllowed) {
      errors.add('Vous avez sélectionné plus de chambres que demandé ($totalSelected/$maxAllowed)');
    }

    return errors;
  }
}