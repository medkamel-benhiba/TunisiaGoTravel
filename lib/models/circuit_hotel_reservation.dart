import 'dart:convert';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import '../models/hotelTgt.dart';
import '../models/hotelBhr.dart';
import '../models/mouradi.dart';

class CircuitHotelProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();

  // State for hotel availability check
  bool _isLoadingAvailability = false;
  Map<String, dynamic> _availableHotels = {};
  Map<String, String> _hotelErrors = {};

  // State for hotel selections
  Map<String, Map<String, dynamic>> _hotelSelections = {};

  // Circuit booking state
  bool _isBookingCircuit = false;
  String? _bookingError;

  // Getters
  bool get isLoadingAvailability => _isLoadingAvailability;
  Map<String, dynamic> get availableHotels => _availableHotels;
  Map<String, String> get hotelErrors => _hotelErrors;
  Map<String, Map<String, dynamic>> get hotelSelections => _hotelSelections;
  bool get isBookingCircuit => _isBookingCircuit;
  String? get bookingError => _bookingError;

  // Check if hotel has confirmed selection
  bool hasHotelSelection(String hotelKey) {
    return _hotelSelections.containsKey(hotelKey);
  }

  // Get hotel availability
  dynamic getHotelAvailability(String hotelKey) {
    return _availableHotels[hotelKey];
  }

  // Get hotel error
  String? getHotelError(String hotelKey) {
    return _hotelErrors[hotelKey];
  }

  Future<void> checkHotelAvailability({
    required String hotelKey,
    required Map<String, dynamic> hotel,
    required DateTime checkIn,
    required DateTime checkOut,
    required List<Map<String, dynamic>> rooms,
  }) async {
    _isLoadingAvailability = true;
    _hotelErrors.remove(hotelKey);
    notifyListeners();

    try {
      final slug = hotel['slug']?.toString();
      final isMouradi = (hotel['Name'] ?? hotel['name'] ?? '').toLowerCase().contains('mouradi');

      if (isMouradi) {
        // Handle Mouradi hotel
        final mouradiId = hotel['idHotelMouradi']?.toString();
        final cityId = hotel['idCityMouradi']?.toString();

        if (mouradiId == null || cityId == null) {
          _hotelErrors[hotelKey] = 'Informations manquantes pour cet hôtel Mouradi';
          return;
        }

        final mouradiResponse = await _apiService.showMouradiDisponibility(
          hotelId: mouradiId,
          city: cityId,
          dateStart: '${checkIn.year.toString().padLeft(4, '0')}-${checkIn.month.toString().padLeft(2, '0')}-${checkIn.day.toString().padLeft(2, '0')}',
          dateEnd: '${checkOut.year.toString().padLeft(4, '0')}-${checkOut.month.toString().padLeft(2, '0')}-${checkOut.day.toString().padLeft(2, '0')}',
          rooms: rooms,
        );

        if (mouradiResponse == null || mouradiResponse.isEmpty) {
          _hotelErrors[hotelKey] = 'Aucune disponibilité trouvée pour ces dates';
          return;
        }

        final mouradiHotel = MouradiHotel.fromJson(mouradiResponse);
        _availableHotels[hotelKey] = {'type': 'mouradi', 'data': mouradiHotel};

      } else if (slug != null) {
        // Handle BHR/TGT hotels
        final dateFormat = DateFormat("dd-MM-yyyy");
        final start = dateFormat.format(checkIn);
        final end = dateFormat.format(checkOut);

        final rawResponse = await _apiService.checkDisponibilityRaw(slug, start, end, rooms);

        if (rawResponse == null || (rawResponse.containsKey('pensions') && rawResponse['pensions'].isEmpty)) {
          _hotelErrors[hotelKey] = 'Aucune disponibilité trouvée pour ces dates';
          return;
        }

        if (rawResponse.containsKey('disponibilitytype')) {
          final disponibilityType = rawResponse['disponibilitytype'] as String;

          if (disponibilityType == 'tgt') {
            final hotelTgt = HotelTgt.fromAvailabilityJson(rawResponse, hotel);
            _availableHotels[hotelKey] = {'type': 'tgt', 'data': hotelTgt};
          } else if (disponibilityType == 'bhr') {
            final hotelBhr = HotelBhr.fromAvailabilityJson(rawResponse, hotel);
            _availableHotels[hotelKey] = {'type': 'bhr', 'data': hotelBhr};
          }
        }
      } else {
        _hotelErrors[hotelKey] = 'Informations manquantes pour vérifier la disponibilité';
      }

    } catch (e) {
      _hotelErrors[hotelKey] = 'Erreur lors de la vérification: $e';
    } finally {
      _isLoadingAvailability = false;
      notifyListeners();
    }
  }

  Future<void> saveHotelSelection({
    required String hotelKey,
    required Map<String, dynamic> selection,
  }) async {
    _hotelSelections[hotelKey] = selection;
    notifyListeners();

    // Save to SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('circuit_hotel_selections', jsonEncode(_hotelSelections));
  }

  Future<void> loadHotelSelections() async {
    final prefs = await SharedPreferences.getInstance();
    final selectionsJson = prefs.getString('circuit_hotel_selections');

    if (selectionsJson != null) {
      try {
        final decoded = jsonDecode(selectionsJson) as Map<String, dynamic>;
        _hotelSelections = decoded.map((key, value) => MapEntry(key, Map<String, dynamic>.from(value)));
        notifyListeners();
      } catch (e) {
        print('Error loading hotel selections: $e');
      }
    }
  }

  Future<bool> bookCircuit({
    required Map<String, dynamic> circuitData,
    required double totalPrice,
  }) async {
    _isBookingCircuit = true;
    _bookingError = null;
    notifyListeners();

    try {
      // Prepare booking data with hotel selections
      final bookingData = {
        'circuit': circuitData,
        'hotelSelections': _hotelSelections,
        'totalPrice': totalPrice,
        'timestamp': DateTime.now().toIso8601String(),
      };

      // Call the API (adjust based on your actual API method)
      final result = await _apiService.createCircuitReservation(bookingData);

      if (result != null) {
        // Clear selections after successful booking
        await _clearSelections();
        return true;
      } else {
        _bookingError = 'Erreur lors de la réservation du circuit';
        return false;
      }

    } catch (e) {
      _bookingError = 'Erreur lors de la réservation: $e';
      return false;
    } finally {
      _isBookingCircuit = false;
      notifyListeners();
    }
  }

  Future<void> _clearSelections() async {
    _hotelSelections.clear();
    _availableHotels.clear();
    _hotelErrors.clear();

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('circuit_hotel_selections');

    notifyListeners();
  }

  double calculateTotalPrice() {
    double total = 0.0;

    for (final selection in _hotelSelections.values) {
      if (selection.containsKey('totalPrice')) {
        total += (selection['totalPrice'] as num).toDouble();
      }
    }

    return total;
  }
}