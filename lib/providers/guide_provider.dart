import 'package:flutter/material.dart';
import '../models/guide.dart';
import '../services/api_service.dart';

class GuideProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();

  List<Guide> _guides = [];
  bool _isLoading = false;
  String? _error;

  List<Guide> get guides => _guides;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchGuides() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _guides = await _apiService.getallguide();
    } catch (e) {
      _guides = [];
      _error = "Erreur lors du chargement des guides: $e";
    }

    _isLoading = false;
    notifyListeners();
  }

  Guide? getGuideById(String id) {
    try {
      return _guides.firstWhere((g) => g.id == id);
    } catch (e) {
      return null;
    }
  }
}
