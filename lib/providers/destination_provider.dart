import 'package:flutter/material.dart';
import '../models/destination.dart';
import '../services/api_service.dart';

class DestinationProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  /// Cached destinations
  List<Destination> _destinations = [];
  List<Destination> get destinations => _destinations;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  DestinationProvider() {
    fetchDestinations();
  }

  /// Fetch all destinations once
  Future<void> fetchDestinations() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _destinations = await _apiService.getDestinations();
    } catch (e) {
      _destinations = [];
      _error = "Aucune destination disponible";
      debugPrint(_error);
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Get a destination by its ID
  Destination? getDestinationById(String id) {
    try {
      return _destinations.firstWhere((d) => d.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Get a destination by its name (case-insensitive)
  Destination? getDestinationByName(String name) {
    try {
      return _destinations
          .firstWhere((d) => d.name.toLowerCase() == name.toLowerCase());
    } catch (e) {
      return null;
    }
  }

  /// Get destinations by state (case-insensitive)
  List<Destination> getDestinationsByState(String state) {
    try {
      return _destinations
          .where((d) => d.state.toLowerCase() == state.toLowerCase())
          .toList();
    } catch (e) {
      return [];
    }
  }

  /// Get a destination's localized name
  String getDestinationName(String id, Locale locale) {
    final destination = getDestinationById(id);
    if (destination == null) return "";
    return destination.getName(locale);
  }

  /// Get a destination's localized description
  String? getDestinationDescription(String id, Locale locale) {
    final destination = getDestinationById(id);
    if (destination == null) return null;
    return destination.getDescription(locale);
  }

  /// Get a destination's localized title
  String? getDestinationTitle(String id, Locale locale) {
    final destination = getDestinationById(id);
    if (destination == null) return null;
    return destination.getTitle(locale);
  }

  /// Get a destination's localized subtitle
  String? getDestinationSubtitle(String id, Locale locale) {
    final destination = getDestinationById(id);
    if (destination == null) return null;
    return destination.getSubtitle(locale);
  }
}
