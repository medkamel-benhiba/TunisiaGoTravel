import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../widgets/circuits/budget_input.dart';
import '../../widgets/circuits/compose_button.dart';
import '../../widgets/circuits/counter_row.dart';
import '../../widgets/circuits/date_picker_section.dart';
import '../../widgets/screen_title.dart';
import '../../widgets/circuits/city_dropdown.dart';
import '../../providers/auto_circuit_provider.dart';
import 'autoCircuits_details.dart';

class AutoCircuitScreen extends StatefulWidget {
  const AutoCircuitScreen({super.key});

  @override
  State<AutoCircuitScreen> createState() => _AutoCircuitScreenState();
}

class _AutoCircuitScreenState extends State<AutoCircuitScreen> {
  final _budgetController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  int adults = 1;
  int children = 0;
  int rooms = 1;

  DateTime? _startDate;
  DateTime? _endDate;

  String? _startCity;
  String? _endCity;
  String? _startCityId;
  String? _endCityId;

  int get duration =>
      (_startDate != null && _endDate != null)
          ? _endDate!.difference(_startDate!).inDays + 1
          : 0;

  bool get _isFormValid {
    return _startDate != null &&
        _endDate != null &&
        _startCityId != null &&
        _endCityId != null &&
        adults > 0 &&
        duration >= 1 &&
        _budgetController.text.isNotEmpty &&
        double.tryParse(_budgetController.text) != null &&
        double.parse(_budgetController.text) > 0;
  }

  void _handleComposeButtonPress(AutoCircuitProvider provider) async {
    if (!_formKey.currentState!.validate()) return;

    if (!_isFormValid) {
      _showValidationError();
      return;
    }

    if (_startCityId == _endCityId) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('La ville de départ et d\'arrivée doivent être différentes'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final adultsCount = adults < 1 ? 1 : adults;
    final roomsCount = rooms < 1 ? 1 : rooms;
    final budgetValue = (_budgetController.text.isEmpty || double.tryParse(_budgetController.text) == null)
        ? 1000
        : double.parse(_budgetController.text) < 1000
        ? 1000
        : double.parse(_budgetController.text).toInt();

    await provider.fetchCircuit(
      budget: budgetValue.toString(),
      start: _startDate!.toIso8601String().split('T')[0],
      end: _endDate!.toIso8601String().split('T')[0],
      departCityId: _startCityId!,
      arriveCityId: _endCityId!,
      adults: adultsCount.toString(),
      children: children.toString(),
      room: roomsCount.toString(),
      duration: duration,
    );

    // Navigate automatically if no error and circuit exists
    if (provider.error == null && provider.circuit != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => CircuitDayScreen(
            listparjours: provider.circuit!.listparjours,
          ),
        ),
      );
    }
  }


  void _showValidationError() {
    String message = 'Veuillez vérifier les champs suivants:\n';
    List<String> errors = [];

    if (_startDate == null || _endDate == null) errors.add('• Dates de voyage');
    if (_startCityId == null || _endCityId == null) errors.add('• Villes de départ et d\'arrivée');
    if (adults == 0) errors.add('• Au moins 1 adulte requis');
    if (_budgetController.text.isEmpty || double.tryParse(_budgetController.text) == null)
      errors.add('• Budget valide');

    message += errors.join('\n');

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red, duration: const Duration(seconds: 4)),
    );
  }

  void _resetForm() {
    setState(() {
      _startDate = null;
      _endDate = null;
      _startCity = null;
      _endCity = null;
      _startCityId = null;
      _endCityId = null;
      adults = 1;
      children = 0;
      rooms = 1;
      _budgetController.clear();
    });
  }

  Widget _buildResultsSection(AutoCircuitProvider provider) {
    if (provider.isLoading) {
      return const Center(
        child: Column(
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Génération de votre circuit...'),
          ],
        ),
      );
    }

    if (provider.error != null) {
      return Center(
        child: Column(
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            const Text(
              'Erreur lors de la génération du circuit',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              provider.error!,
              style: const TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
          ],
        ),
      );
    }

    if (provider.circuit != null && provider.circuit!.listparjours.isNotEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Divider(),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Votre Circuit',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              TextButton(
                onPressed: _resetForm,
                child: const Text('Nouveau Circuit'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: provider.circuit!.listparjours.length,
            itemBuilder: (context, index) {
              final jour = provider.circuit!.listparjours[index];
              if (jour == null) return const SizedBox.shrink();

              final name = jour['name'] ?? 'Jour ${index + 1}';
              final description = jour['description'];

              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                elevation: 2,
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Theme.of(context).primaryColor,
                    child: Text(
                      '${index + 1}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  title: Text(name, style: const TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: description != null ? Text(description) : null,
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                ),
              );
            },
          ),
        ],
      );
    }

    return const Center(
      child: Text(
        'Aucun circuit généré pour le moment.',
        style: TextStyle(fontSize: 16, color: Colors.grey),
      ),
    );
  }

  @override
  void dispose() {
    _budgetController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AutoCircuitProvider(),
      child: Consumer<AutoCircuitProvider>(
        builder: (context, provider, child) {
          return Scaffold(
            body: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
                    child: const ScreenTitle(title: 'Circuit Automatique', icon: Icons.account_tree_outlined),
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
                            },
                          ),
                          const SizedBox(height: 16),
                          // Affichage de la durée calculée
                          if (duration > 0)
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
                          const SizedBox(height: 16),
                          CityDropdown(
                            label: 'Ville De Départ',
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
                            label: 'Ville D\'arrivée',
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
                          CounterRow(
                            label: 'Adultes',
                            count: adults,
                            onIncrement: () => setState(() => adults++),
                            onDecrement: () {
                              if (adults > 1) setState(() => adults--);
                            },
                          ),
                          const SizedBox(height: 12),
                          CounterRow(
                            label: 'Enfants',
                            count: children,
                            onIncrement: () => setState(() => children++),
                            onDecrement: () {
                              if (children > 0) setState(() => children--);
                            },
                          ),
                          const SizedBox(height: 12),
                          CounterRow(
                            label: 'Chambres',
                            count: rooms,
                            onIncrement: () => setState(() => rooms++),
                            onDecrement: () {
                              if (rooms > 0) setState(() => rooms--);
                            },
                          ),
                          const SizedBox(height: 24),
                          ComposeButton(
                            onPressed: provider.isLoading ? null : () => _handleComposeButtonPress(provider),
                          ),
                          const SizedBox(height: 20),
                          _buildResultsSection(provider),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
