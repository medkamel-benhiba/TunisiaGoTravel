import 'package:flutter/material.dart';
import '../models/voyage.dart';
import '../services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class VoyageProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  List<Voyage> _voyages = [];
  Voyage? _selectedVoyage;
  bool _isLoading = false;
  String? _error;

  List<Voyage> get voyages => _voyages;
  Voyage? get selectedVoyage => _selectedVoyage;
  bool get isLoading => _isLoading;
  String? get error => _error;

  final String _cacheKey = 'cached_voyages';

  /// Fetch all voyages from API and cache them
  Future<void> fetchVoyages() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final fetchedVoyages = await _apiService.getAllVoyage();
      _voyages = fetchedVoyages;

      final prefs = await SharedPreferences.getInstance();
      prefs.setString(_cacheKey,
          jsonEncode(_voyages.map((v) => v.toJson()).toList()));
    } catch (e) {
      _error = 'Failed to load voyages: $e';
      await _loadCachedVoyages();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Fetch a single voyage by its ID
  Future<void> getVoyageById(String id) async {
    try {
      final voyage = _voyages.firstWhere((v) => v.id == id);
      _selectedVoyage = voyage;
    } catch (_) {
      _selectedVoyage = null;
      _error = 'Voyage not found';
    }
    notifyListeners();
  }

  /// Load cached voyages if API fails
  Future<void> _loadCachedVoyages() async {
    final prefs = await SharedPreferences.getInstance();
    final cachedData = prefs.getString(_cacheKey);
    if (cachedData != null) {
      try {
        final List jsonList = jsonDecode(cachedData);
        _voyages = jsonList.map((v) => Voyage.fromJson(v)).toList();
        _error = null;
      } catch (_) {
        _voyages = [];
      }
    }
  }

  /// Clear cache manually
  Future<void> clearCache() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_cacheKey);
    _voyages = [];
    _selectedVoyage = null;
    notifyListeners();
  }
}
