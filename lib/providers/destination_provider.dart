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

  // Fetch all destinations once
  Future<void> fetchDestinations() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _destinations = await _apiService.getDestinations();
    } catch (e) {
      _destinations = [];
      _error = "Error fetching destinations: $e";
      debugPrint(_error);
    }

    _isLoading = false;
    notifyListeners();
  }

  // Get a destination by its ID
  Destination? getDestinationById(String id) {
    try {
      return _destinations.firstWhere((d) => d.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Optionally get by name
  Destination? getDestinationByName(String name) {
    try {
      return _destinations
          .firstWhere((d) => d.name.toLowerCase() == name.toLowerCase());
    } catch (e) {
      return null;
    }
  }
}
