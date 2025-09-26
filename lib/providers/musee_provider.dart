import 'package:flutter/material.dart';
import '../models/musee.dart';
import '../services/api_service.dart';

class MuseeProvider with ChangeNotifier {
  final ApiService apiService;

  MuseeProvider({required this.apiService});

  List<Musees> _musees = [];
  bool _isLoading = false;
  String? _error;
  Musees? selectedMusee;

  List<Musees> get musees => _musees;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchMusees() async {
    _setLoading(true);
    try {
      _musees = await apiService.getmusee();
      _error = null;
    } catch (e) {
      _musees = [];
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  /// Fetch a single musee by slug safely
  Future<void> fetchMuseeBySlug(String slug) async {
    _setLoading(true);
    try {
      selectedMusee = await apiService.getMuseeBySlug(slug);
      if (selectedMusee == null) {
        _error = "Musée introuvable";
      } else {
        _error = null;
      }
    } catch (e) {
      selectedMusee = null;
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> refreshMusees() async => fetchMusees();

  /// 🔍 Filter musées par destination (id)
  List<Musees> getMuseesByDestination(String destinationId) {
    return _musees.where((m) => m.destinationId == destinationId).toList();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
