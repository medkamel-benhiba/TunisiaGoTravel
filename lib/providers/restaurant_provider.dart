import 'package:flutter/material.dart';
import '../models/restaurant.dart';
import '../services/api_service.dart';

class RestaurantProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();

  /// Cached restaurants per destination
  final Map<String, List<Restaurant>> _restaurantsByDestination = {};

  /// All fetched restaurants
  List<Restaurant> _allRestaurants = [];

  /// Current displayed restaurants
  List<Restaurant> _restaurants = [];
  List<Restaurant> get restaurants => _restaurants;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // ===== Fetch all restaurants once =====
  Future<void> fetchAllRestaurants() async {
    _isLoading = true;
    notifyListeners();

    try {
      _allRestaurants = await _apiService.getAllRestaurants();
      // Pre-cache per destination
      for (var r in _allRestaurants) {
        final destId = r.destinationId?.toString() ?? 'unknown';
        _restaurantsByDestination.putIfAbsent(destId, () => []);
        _restaurantsByDestination[destId]!.add(r);
      }
    } catch (e) {
      _allRestaurants = [];
      debugPrint("Error fetching restaurants: $e");
    }

    _isLoading = false;
    notifyListeners();
  }

  // ===== Get restaurants by destination from cache =====
  void setRestaurantsByDestination(String destinationId) {
    _restaurants = _restaurantsByDestination[destinationId] ?? [];
    notifyListeners();
  }

  // Optional: get restaurants by destination directly
  List<Restaurant> getRestaurantsByDestination(String destinationId) {
    return _restaurantsByDestination[destinationId] ?? [];
  }
}
