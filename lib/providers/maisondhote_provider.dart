import 'package:flutter/material.dart';
import '../models/maisondHote.dart';
import '../services/api_service.dart';

class MaisonProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();

  /// Cached maisons per destination
  final Map<String, List<MaisonDHote>> _maisonsByDestination = {};

  /// All fetched maisons
  List<MaisonDHote> _allMaisons = [];
  List<MaisonDHote> get allMaisons => _allMaisons;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  // ===== Fetch all maisons once =====
  Future<void> fetchMaisons() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _allMaisons = await _apiService.getmaisons();

      // Cache per destination
      for (var maison in _allMaisons) {
        final destId = maison.destinationId;
        if (!_maisonsByDestination.containsKey(destId)) {
          _maisonsByDestination[destId] = [];
        }
        _maisonsByDestination[destId]!.add(maison);
      }
    } catch (e) {
      _allMaisons = [];
      _errorMessage = "Error fetching maisons: $e";
      debugPrint(_errorMessage);
    }

    _isLoading = false;
    notifyListeners();
  }

  // ===== Get maisons by destination from cache =====
  List<MaisonDHote> getMaisonsByDestination(String destinationId) {
    return _maisonsByDestination[destinationId] ?? [];
  }

  // Optional: by name
  List<MaisonDHote> getMaisonsByDestinationName(String name) {
    return _allMaisons
        .where((m) => m.destination.name.toLowerCase() == name.toLowerCase())
        .toList();
  }
}
