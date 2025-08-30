import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../widgets/circuits/budget_input.dart';
import '../../widgets/circuits/compose_button.dart';
import '../../widgets/circuits/counter_row.dart';
import '../../widgets/circuits/date_picker_section.dart';
import '../../widgets/screen_title.dart';
import '../../widgets/circuits/city_dropdown.dart';
import '../../providers/manual_circuit_provider.dart';
import 'manual_circuit_selection_screen.dart';

class ManualCircuitScreen extends StatefulWidget {
  const ManualCircuitScreen({super.key});

  @override
  State<ManualCircuitScreen> createState() => _ManualCircuitScreenState();
}

class _ManualCircuitScreenState extends State<ManualCircuitScreen> {
  final _budgetController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  // Données du formulaire
  int _adults = 1;
  int _children = 0;
  int _rooms = 1;
  DateTime? _startDate;
  DateTime? _endDate;
  String? _startCity;
  String? _endCity;
  String? _startCityId;
  String? _endCityId;

  // Calculs
  int get duration => (_startDate != null && _endDate != null)
      ? _endDate!.difference(_startDate!).inDays + 1
      : 0;

  @override
  void dispose() {
    _budgetController.dispose();
    super.dispose();
  }

  /// Valider et soumettre le formulaire
  Future<void> _handleFormSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    final validationError = _validateForm();
    if (validationError != null) {
      _showErrorSnackBar(validationError);
      return;
    }

    // Préparer les données
    final formData = _prepareFormData();

    // Naviguer vers la sélection des destinations avec Provider
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
    if (_startDate == null || _endDate == null) {
      return 'Veuillez sélectionner les dates de voyage';
    }
    if (_startCityId == null) {
      return 'Veuillez sélectionner une ville de départ';
    }
    if (_endCityId == null) {
      return 'Veuillez sélectionner une ville d\'arrivée';
    }
    if (_adults < 1) {
      return 'Au moins 1 adulte est requis';
    }
    if (duration < 1) {
      return 'La durée du voyage doit être d\'au moins 1 jour';
    }
    if (_budgetController.text.isEmpty) {
      return 'Veuillez saisir un budget';
    }
    final budget = double.tryParse(_budgetController.text);
    if (budget == null || budget <= 0) {
      return 'Veuillez saisir un budget valide';
    }
    if (budget < 100) {
      return 'Le budget minimum est de 100 TND';
    }
    return null;
  }

  /// Préparer les données du formulaire pour l'étape suivante
  Map<String, dynamic> _prepareFormData() {
    final budget = double.tryParse(_budgetController.text) ?? 1000;
    return {
      'budget': budget < 100 ? 1000 : budget.toInt().toString(),
      'start': _startDate!.toIso8601String().split('T')[0],
      'end': _endDate!.toIso8601String().split('T')[0],
      'departCityId': _startCityId!,
      'arriveCityId': _endCityId!,
      'adults': _adults.toString(),
      'children': _children.toString(),
      'room': _rooms.toString(),
    };
  }

  /// Afficher une erreur dans une SnackBar
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
            // En-tête
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
              child: ScreenTitle(
                title: 'Circuit Manuel',
                icon: Icons.edit_location_alt_outlined,
              ),
            ),

            // Corps du formulaire
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Sélection des dates
                    DateRangeCalendar(
                      onRangeSelected: (start, end) {
                        setState(() {
                          _startDate = start;
                          _endDate = end;
                        });
                      },
                    ),

                    const SizedBox(height: 16),

                    // Affichage de la durée uniquement si _endDate est sélectionnée
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

                    // Ville de départ
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

                    // Ville d'arrivée
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

                    // Budget
                    BudgetInput(
                      controller: _budgetController,
                    ),

                    const SizedBox(height: 16),

                    // Section voyageurs
                    Card(
                      elevation: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Détails',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            CounterRow(
                              label: 'Adultes',
                              count: _adults,
                              onIncrement: () => setState(() => _adults++),
                              onDecrement: () {
                                if (_adults > 1) setState(() => _adults--);
                              },
                            ),
                            const SizedBox(height: 12),
                            CounterRow(
                              label: 'Enfants',
                              count: _children,
                              onIncrement: () => setState(() => _children++),
                              onDecrement: () {
                                if (_children > 0) setState(() => _children--);
                              },
                            ),
                            const SizedBox(height: 12),
                            CounterRow(
                              label: 'Chambres',
                              count: _rooms,
                              onIncrement: () => setState(() => _rooms++),
                              onDecrement: () {
                                if (_rooms > 0) setState(() => _rooms--);
                              },
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),
                    ComposeButton(
                      onPressed: _handleFormSubmit,
                    ),

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
