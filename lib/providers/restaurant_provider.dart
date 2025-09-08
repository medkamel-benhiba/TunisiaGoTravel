import 'package:flutter/material.dart';
import '../models/restaurant.dart';
import '../services/api_service.dart';

class RestaurantProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();

  /// Cached restaurants per destination
  final Map<String, List<Restaurant>> _restaurantsByDestination = {};

  /// All fetched restaurants
  List<Restaurant> allRestaurants = [];

  /// Current displayed restaurants
  List<Restaurant> _restaurants = [];
  List<Restaurant> get restaurants => _restaurants;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Restaurant? _selectedRestaurant;
  Restaurant? get selectedRestaurant => _selectedRestaurant;


  // ===== Fetch all restaurants once =====
  Future<void> fetchAllRestaurants() async {
    _isLoading = true;
    notifyListeners();

    try {
      allRestaurants = await _apiService.getAllRestaurants();
      // Pre-cache per destination
      for (var r in allRestaurants) {
        final destId = r.destinationId?.toString() ?? 'unknown';
        _restaurantsByDestination.putIfAbsent(destId, () => []);
        _restaurantsByDestination[destId]!.add(r);
      }
    } catch (e) {
      allRestaurants = [];
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

  Future<void> selectRestaurantBySlug(String slug) async {
    final i = allRestaurants.indexWhere(
          (r) => r.slug?.toLowerCase() == slug.toLowerCase(),
    );
    _selectedRestaurant = i != -1 ? allRestaurants[i] : null;
    notifyListeners();
  }




}
