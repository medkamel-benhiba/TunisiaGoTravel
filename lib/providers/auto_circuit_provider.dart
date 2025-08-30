import 'package:flutter/material.dart';
import '../models/listjour.dart';
import '../services/api_service.dart';

class AutoCircuitProvider extends ChangeNotifier {
  Listjour? _circuit;
  bool _isLoading = false;
  String? _error;
  String? debugInfo;

  final apiService = ApiService();

  Listjour? get circuit => _circuit;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchCircuit({
    required String budget,
    required String start,
    required String end,
    required String departCityId,
    required String arriveCityId,
    required String adults,
    required String children,
    required String room,
    required int duration,
  }) async {
    _isLoading = true;
    _error = null;
    debugInfo = null;
    notifyListeners();

    try {
      final result = await apiService.getcircuitauto(
        budget,
        start,
        end,
        departCityId,
        arriveCityId,
        adults,
        children,
        room,
        duration,
      );

      _circuit = result;
      debugInfo = 'Circuit fetched successfully';
      _error = null;
    } catch (e) {
      _error = e.toString();
      debugInfo = 'Exception: $e';
      _circuit = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
