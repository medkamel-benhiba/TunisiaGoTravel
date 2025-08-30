import 'package:flutter/material.dart';
import '../models/festival.dart';
import '../services/api_service.dart';

class FestivalProvider with ChangeNotifier {
  List<Festival> _festivals = [];
  int _currentPage = 1;
  bool _isLoading = false;
  bool _hasMore = true;
  Festival? selectedFestival;
  String? error;

  final ApiService _apiService = ApiService();

  List<Festival> get festivals => _festivals;
  bool get isLoading => _isLoading;
  bool get hasMore => _hasMore;

  /// Fetch festivals for list view, with pagination
  Future<void> fetchFestivals({bool refresh = false}) async {
    if (_isLoading) return;

    _isLoading = true;
    notifyListeners();

    if (refresh) {
      _currentPage = 1;
      _festivals.clear();
      _hasMore = true;
    }

    try {
      print("Fetching festivals page $_currentPage...");
      final List<Festival> newFestivals =
      await _apiService.getfestival(_currentPage.toString());

      if (newFestivals.isEmpty) {
        _hasMore = false;
      } else {
        _festivals.addAll(newFestivals);
        _currentPage++;
      }
    } catch (e, stackTrace) {
      print("Erreur fetchFestivals: $e");
      print(stackTrace);
      error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Fetch single festival by slug
  void getFestivalBySlug(String slug) {
    try {
      selectedFestival = festivals.firstWhere((f) => f.slug == slug);
      notifyListeners();
    } catch (e) {
      selectedFestival = null;
      error = "Festival introuvable";
      notifyListeners();
    }
  }


  /// Clear selected festival (optional)
  void clearSelectedFestival() {
    selectedFestival = null;
    error = null;
    notifyListeners();
  }
}
