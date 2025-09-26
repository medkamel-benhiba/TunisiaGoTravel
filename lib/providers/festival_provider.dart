import 'package:flutter/material.dart';
import '../models/festival.dart';
import '../services/api_service.dart';

class FestivalProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();

  /// Cached festivals per destination
  final Map<String, List<Festival>> _festivalsByDestination = {};

  /// All fetched festivals
  List<Festival> allFestivals = [];

  /// Current displayed festivals
  List<Festival> _festivals = [];
  List<Festival> get festivals => _festivals;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _hasMore = true;
  bool get hasMore => _hasMore;

  int _currentPage = 1;

  Festival? selectedFestival;
  String? error;

  /// Flag to track if all festivals have been fetched
  bool _allFestivalsFetched = false;

  /// Fetch all festivals once
  Future<void> fetchAllFestivals() async {
    // Prevent duplicate fetching
    if (_allFestivalsFetched || _isLoading) return;

    _isLoading = true;
    notifyListeners();

    try {
      allFestivals = await _apiService.getfestival(_currentPage.toString());
      _allFestivalsFetched = true;

      // Clear existing cache before rebuilding
      _festivalsByDestination.clear();

      // Pre-cache per destination
      for (var festival in allFestivals) {
        final destId = festival.destinationId?.toString() ?? 'unknown';
        _festivalsByDestination.putIfAbsent(destId, () => []);
        _festivalsByDestination[destId]!.add(festival);
      }
    } catch (e) {
      allFestivals = [];
      _allFestivalsFetched = false; // Allow retry on error
      print("Error fetching all festivals: $e");
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Fetch festivals for list view, with pagination
  Future<void> fetchFestivals({bool refresh = false}) async {
    if (_isLoading) return;

    _isLoading = true;
    notifyListeners();

    if (refresh) {
      _currentPage = 1;
      _festivals.clear();
      _hasMore = true;
      _allFestivalsFetched = false; // Reset the flag on refresh
    }

    try {
      final List<Festival> newFestivals =
      await _apiService.getfestival(_currentPage.toString());

      if (newFestivals.isEmpty) {
        _hasMore = false;
      } else {
        _festivals.addAll(newFestivals);
        _currentPage++;

        // Update cache with new festivals, avoiding duplicates
        for (var festival in newFestivals) {
          final destId = festival.destinationId?.toString() ?? 'unknown';
          _festivalsByDestination.putIfAbsent(destId, () => []);

          // Check for duplicates before adding
          if (!_festivalsByDestination[destId]!.any((f) => f.id == festival.id)) {
            _festivalsByDestination[destId]!.add(festival);
          }
        }

        // Update allFestivals, removing duplicates
        for (var newFestival in newFestivals) {
          if (!allFestivals.any((f) => f.id == newFestival.id)) {
            allFestivals.add(newFestival);
          }
        }
      }
      error = null;
    } catch (e, stackTrace) {
      print("Erreur fetchFestivals: $e");
      print(stackTrace);
      error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Get festivals by destination from cache
  void setFestivalsByDestination(String destinationId) {
    _festivals = _festivalsByDestination[destinationId] ?? [];
    error = _festivals.isEmpty ? "No festivals found for destination $destinationId" : null;
    notifyListeners();
  }

  /// Optional: get festivals by destination directly
  List<Festival> getFestivalsByDestination(String destinationId) {
    return _festivalsByDestination[destinationId] ?? [];
  }

  /// Fetch single festival by slug
  void getFestivalBySlug(String slug) {
    try {
      selectedFestival = allFestivals.firstWhere(
            (f) => f.slug.toLowerCase() == slug.toLowerCase(),
        orElse: () => throw Exception("Festival introuvable"),
      );
      error = null;
    } catch (e) {
      selectedFestival = null;
      error = "Festival introuvable";
    }
    notifyListeners();
  }

  /// Clear selected festival
  void clearSelectedFestival() {
    selectedFestival = null;
    error = null;
    notifyListeners();
  }

  /// Force refresh all data
  void forceRefresh() {
    _allFestivalsFetched = false;
    _festivalsByDestination.clear();
    allFestivals.clear();
    _festivals.clear();
    notifyListeners();
  }
}