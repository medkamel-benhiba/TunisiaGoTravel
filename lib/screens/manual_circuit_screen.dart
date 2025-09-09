import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../widgets/circuits/budget_input.dart';
import '../../widgets/circuits/compose_button.dart';
import '../../widgets/circuits/date_picker_section.dart';
import '../../widgets/screen_title.dart';
import '../../widgets/circuits/city_dropdown.dart';
import '../../providers/manual_circuit_provider.dart';
import 'manual_circuit_selection_screen.dart';
import '../../widgets/reservation/guest_summary.dart';

class ManualCircuitScreen extends StatefulWidget {
  const ManualCircuitScreen({super.key});

  @override
  State<ManualCircuitScreen> createState() => _ManualCircuitScreenState();
}

class _ManualCircuitScreenState extends State<ManualCircuitScreen> {
  final _budgetController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  // Données du formulaire
  DateTime? _startDate;
  DateTime? _endDate;
  String? _startCity;
  String? _endCity;
  String? _startCityId;
  String? _endCityId;

  // Données des chambres pour GuestSummary
  List<Map<String, dynamic>> _roomsData = [
    {"adults": 2, "children": 0, "childAges": <int>[]}
  ];

  // Calcul de la durée
  int get duration => (_startDate != null && _endDate != null)
      ? _endDate!.difference(_startDate!).inDays + 1
      : 0;

  // ---- SAVE & LOAD DATES + ROOMS ----
  Future<void> _saveDatesAndRooms(DateTime start, DateTime end, List<Map<String, dynamic>> rooms) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('manual_start_date', start.toIso8601String());
    await prefs.setString('manual_end_date', end.toIso8601String());
    await prefs.setString('manual_rooms_data', jsonEncode(rooms));
  }

  Future<void> _loadDatesAndRooms() async {
    final prefs = await SharedPreferences.getInstance();
    final start = prefs.getString('manual_start_date');
    final end = prefs.getString('manual_end_date');
    final roomsJson = prefs.getString('manual_rooms_data');

    setState(() {
      _startDate = start != null ? DateTime.tryParse(start) : null;
      _endDate = end != null ? DateTime.tryParse(end) : null;
      _roomsData = roomsJson != null
          ? (jsonDecode(roomsJson) as List<dynamic>)
          .map((e) => Map<String, dynamic>.from(e))
          .toList()
          : [
        {"adults": 2, "children": 0, "childAges": <int>[]}
      ];
    });
  }

  @override
  void initState() {
    super.initState();
    _loadDatesAndRooms();
  }

  @override
  void dispose() {
    _budgetController.dispose();
    super.dispose();
  }

  // Valider et soumettre le formulaire
  Future<void> _handleFormSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    final validationError = _validateForm();
    if (validationError != null) {
      _showErrorSnackBar(validationError);
      return;
    }

    if (_startDate != null && _endDate != null) {
      _saveDatesAndRooms(_startDate!, _endDate!, _roomsData);
    }

    final formData = _prepareFormData();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider(
          create: (_) => ManualCircuitProvider(),
          child: ManualDestinationSelectionScreen(
            formData: formData,
            duration: duration,
          ),
        ),
      ),
    );
  }

  /// Valider les données du formulaire
  String? _validateForm() {
    if (_startDate == null || _endDate == null) return 'Veuillez sélectionner les dates de voyage';
    if (_startCityId == null) return 'Veuillez sélectionner une ville de départ';
    if (_endCityId == null) return 'Veuillez sélectionner une ville d\'arrivée';
    if (_roomsData.fold(0, (sum, room) => sum + (room["adults"] as int)) < 1) return 'Au moins 1 adulte est requis';
    if (duration < 1) return 'La durée du voyage doit être d\'au moins 1 jour';
    if (_budgetController.text.isEmpty) return 'Veuillez saisir un budget';
    final budget = double.tryParse(_budgetController.text);
    if (budget == null || budget <= 0) return 'Veuillez saisir un budget valide';
    if (budget < 100) return 'Le budget minimum est de 100 TND';
    return null;
  }

  /// Préparer les données du formulaire pour l'étape suivante
  Map<String, dynamic> _prepareFormData() {
    final budget = double.tryParse(_budgetController.text) ?? 1000;
    int totalAdults = _roomsData.fold(0, (sum, room) => sum + (room["adults"] as int));
    int totalChildren = _roomsData.fold(0, (sum, room) => sum + (room["children"] as int));
    int totalRooms = _roomsData.length;

    return {
      'budget': budget < 100 ? 1000 : budget.toInt().toString(),
      'start': _startDate!.toIso8601String().split('T')[0],
      'end': _endDate!.toIso8601String().split('T')[0],
      'departCityId': _startCityId!,
      'arriveCityId': _endCityId!,
      'adults': totalAdults.toString(),
      'children': totalChildren.toString(),
      'room': totalRooms.toString(),
      'roomsData': _roomsData,
    };
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 4),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
              child: ScreenTitle(
                title: 'Circuit Manuel',
                icon: Icons.edit_location_alt_outlined,
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DateRangeCalendar(
                      onRangeSelected: (start, end) {
                        setState(() {
                          _startDate = start;
                          _endDate = end;
                        });
                        if (start != null && end != null) {
                          _saveDatesAndRooms(_startDate!, _endDate!, _roomsData);
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    if (_startDate != null && _endDate != null)
                      Container(
                        padding: const EdgeInsets.all(12),
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.blue.shade200),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.calendar_today, color: Colors.blue.shade600),
                            const SizedBox(width: 8),
                            Text(
                              'Durée du voyage: $duration jour${duration > 1 ? 's' : ''}',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: Colors.blue.shade700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    CityDropdown(
                      label: 'Ville de Départ',
                      selectedValue: _startCity,
                      selectedId: _startCityId,
                      onChanged: (name, id) {
                        setState(() {
                          _startCity = name;
                          _startCityId = id;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    CityDropdown(
                      label: 'Ville d\'Arrivée',
                      selectedValue: _endCity,
                      selectedId: _endCityId,
                      onChanged: (name, id) {
                        setState(() {
                          _endCity = name;
                          _endCityId = id;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    BudgetInput(controller: _budgetController),
                    const SizedBox(height: 16),
                    Card(
                      elevation: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: GuestSummary(
                          initialRoomsData: _roomsData,
                          onRoomsChanged: (updatedRooms) {
                            setState(() {
                              _roomsData = updatedRooms;
                              if (_startDate != null && _endDate != null) {
                                _saveDatesAndRooms(_startDate!, _endDate!, _roomsData);
                              }
                            });
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    ComposeButton(onPressed: _handleFormSubmit),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
