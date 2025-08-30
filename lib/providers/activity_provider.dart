import 'package:flutter/material.dart';
import '../models/activity.dart';
import '../services/api_service.dart';

class ActivityProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();

  List<Activity> _activities = [];
  List<Activity> get activities => _activities;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Future<void> fetchActivities() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _activities = await _apiService.getallactivitys();
    } catch (e) {
      _activities = [];
      _errorMessage = "Erreur lors du chargement: $e";
      debugPrint(_errorMessage);
    }

    _isLoading = false;
    notifyListeners();
  }

  List<Activity> getByCity(String cityId) {
    return _activities.where((a) => a.cityId == cityId).toList();
  }
}
