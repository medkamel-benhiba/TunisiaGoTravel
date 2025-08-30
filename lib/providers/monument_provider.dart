import 'package:flutter/material.dart';
import '../models/destination.dart';
import '../models/monument.dart';
import '../services/api_service.dart';

class MonumentProvider with ChangeNotifier {
  final ApiService apiService;

  MonumentProvider({required this.apiService});

  List<Monument> _monuments = [];
  Monument? _selectedMonument;
  bool _isLoading = false;
  String? _error;

  List<Monument> get monuments => _monuments;
  Monument? get selectedMonument => _selectedMonument;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchMonuments({String page = '1'}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _monuments = await apiService.getmonument(page);
    } catch (e) {
      _error = e.toString();
      _monuments = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchMonumentBySlug(String slug) async {
    _isLoading = true;
    _error = null;
    _selectedMonument = null;
    notifyListeners();

    try {
      // First, try to find in existing monuments list
      final existingMonument = _monuments.firstWhere(
            (monument) => monument.slug == slug,
        orElse: () => Monument(
          id: '',
          name: '',
          description: '',
          categories: '',
          lat: 0.0,
          lng: 0.0,
          images: [],
          cover: '',
          vignette: '',
          slug: '',
          destination: Destination.fromJson({}),
        ),
      );

      if (existingMonument.id.isNotEmpty) {
        _selectedMonument = existingMonument;
      } else {
        // If not found in list, fetch from API
        // You'll need to add this method to your ApiService
        _selectedMonument = await apiService.getMonumentBySlug(slug);
      }
    } catch (e) {
      _error = e.toString();
      _selectedMonument = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Clear selected monument (useful when navigating away)
  void clearSelectedMonument() {
    _selectedMonument = null;
    notifyListeners();
  }

  // Reset error state
  void clearError() {
    _error = null;
    notifyListeners();
  }
}