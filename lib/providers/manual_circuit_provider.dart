import 'package:flutter/material.dart';
import '../models/destination.dart';
import '../models/listjour.dart';
import '../services/api_service.dart';

enum CircuitLoadingState { idle, fetchingDestinations, creatingCircuit }

class ManualCircuitProvider extends ChangeNotifier {
  CircuitLoadingState _loadingState = CircuitLoadingState.idle;
  List<DestinationSelection> _destinations = [];
  Listjour? _circuit;
  String? _error;

  final ApiService _apiService = ApiService();

  // Getters
  CircuitLoadingState get loadingState => _loadingState;
  List<DestinationSelection> get destinations => _destinations;
  Listjour? get circuit => _circuit;
  String? get error => _error;

  bool get isLoading => _loadingState != CircuitLoadingState.idle;
  bool get isFetchingDestinations => _loadingState == CircuitLoadingState.fetchingDestinations;
  bool get isCreatingCircuit => _loadingState == CircuitLoadingState.creatingCircuit;

  // Nombre total de jours sélectionnés
  int get totalSelectedDays => _destinations.fold(0, (sum, dest) => sum + dest.days);

  // Ville de départ sélectionnée
  DestinationSelection? get startDestination {
    try {
      return _destinations.firstWhere((d) => d.isStart);
    } catch (e) {
      return null; // Aucun élément trouvé
    }
  }

  //Réinitialiser l'état du provider
  void reset() {
    _loadingState = CircuitLoadingState.idle;
    _destinations = [];
    _circuit = null;
    _error = null;
    notifyListeners();
  }

  //les destinations possibles
  Future<bool> fetchDestinations({
    required String budget,
    required String start,
    required String end,
    required String depart,
    required String arrive,
    required String adults,
    required String children,
    required String room,
    required int duration,
  }) async {
    _loadingState = CircuitLoadingState.fetchingDestinations;
    _error = null;
    _destinations = [];
    notifyListeners();

    try {
      final result = await _apiService.getcircuitmanulledes(
        budget,
        start,
        end,
        depart,
        arrive,
        adults,
        children,
        room,
        duration,
      );

      if (result.destinations != null && result.destinations!.isNotEmpty) {
        _destinations = result.destinations!
            .map((d) => DestinationSelection(
          id: d.id,
          name: d.name,
          days: 0, // <-- 0 jour par défaut
          isStart: false,
        ))
            .toList();

        // Marquer automatiquement la première destination comme ville de départ
        if (_destinations.isNotEmpty) {
          _destinations.first.isStart = true;
        }

        _error = null;
        _loadingState = CircuitLoadingState.idle;
        notifyListeners();
        return true;
      } else {
        _error = "Aucune destination disponible pour vos critères";
        _loadingState = CircuitLoadingState.idle;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = "Erreur lors du chargement des destinations: ${e.toString()}";
      _loadingState = CircuitLoadingState.idle;
      _destinations = [];
      notifyListeners();
      return false;
    }
  }

  /// Mettre à jour le nombre de jours pour une destination
  /// Mettre à jour le nombre de jours pour une destination
  void updateDestinationDays(String destinationId, int days, int maxDuration) {
    final index = _destinations.indexWhere((d) => d.id == destinationId);
    if (index == -1) return;

    final dest = _destinations[index];

    // Ville de départ doit avoir au moins 1 jour
    if (dest.isStart && days < 1) {
      dest.days = 1;
    } else {
      // Calculer le nombre de jours restants pour les autres destinations
      final remainingDays = maxDuration - totalSelectedDays + dest.days;
      dest.days = days > remainingDays ? remainingDays : days;
    }

    notifyListeners();
  }


  /// Définir la ville de départ (une seule autorisée)
  void setStartDestination(String destinationId) {
    for (var dest in _destinations) {
      dest.isStart = dest.id == destinationId;
    }
    notifyListeners();
  }

  /// Valider la sélection des destinations
  String? validateDestinationSelection(int maxDuration) {
    final selectedDestinations = _destinations.where((d) => d.days > 0).toList();

    if (selectedDestinations.isEmpty) {
      return "Veuillez sélectionner au moins une destination";
    }

    final startDestinations = _destinations.where((d) => d.isStart).length;
    if (startDestinations == 0) {
      return "Veuillez sélectionner une ville de départ";
    }
    if (startDestinations > 1) {
      return "Une seule ville de départ est autorisée";
    }

    final startDest = _destinations.firstWhere((d) => d.isStart);
    if (startDest.days == 0) {
      return "La ville de départ doit avoir au moins 1 jour";
    }

    if (totalSelectedDays > maxDuration) {
      return "Le total des jours ($totalSelectedDays) dépasse la durée du voyage ($maxDuration)";
    }

    return null;
  }

  /// Étape 2 : Créer le circuit avec les destinations sélectionnées
  Future<bool> createCircuit({
    required String budget,
    required String start,
    required String end,
    required String adults,
    required String children,
    required String room,
    required int maxDuration,
  }) async {
    final validationError = validateDestinationSelection(maxDuration);
    if (validationError != null) {
      _error = validationError;
      notifyListeners();
      return false;
    }

    _loadingState = CircuitLoadingState.creatingCircuit;
    _error = null;
    _circuit = null;
    notifyListeners();

    try {
      final selectedDestinations = _destinations
          .where((d) => d.days > 0)
          .map((d) => {
        "id": d.id,
        "days": d.days,
        "isStart": d.isStart,
      })
          .toList();

      final result = await _apiService.getcircuitmanulle(
        budget,
        start,
        end,
        selectedDestinations,
        room,
        adults,
        children,
      );

      _circuit = result;
      _error = null;
      _loadingState = CircuitLoadingState.idle;
      notifyListeners();
      return true;
    } catch (e) {
      _error = "Erreur lors de la création du circuit: ${e.toString()}";
      _loadingState = CircuitLoadingState.idle;
      _circuit = null;
      notifyListeners();
      return false;
    }
  }

  //résume circuit sélectionné
  Map<String, dynamic> getCircuitSummary() {
    final selectedDests = _destinations.where((d) => d.days > 0).toList();
    return {
      'destinationsCount': selectedDests.length,
      'totalDays': totalSelectedDays,
      'startCity': startDestination?.name ?? 'Non définie',
      'destinations': selectedDests
          .map((d) => {
        'name': d.name,
        'days': d.days,
        'isStart': d.isStart,
      })
          .toList(),
    };
  }
}
