import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:easy_localization/easy_localization.dart';

import '../../widgets/circuits/budget_input.dart';
import '../../widgets/circuits/compose_button.dart';
import '../../widgets/circuits/date_picker_section.dart';
import '../../widgets/screen_title.dart';
import '../../widgets/circuits/city_dropdown.dart';
import '../../providers/auto_circuit_provider.dart';
import '../widgets/reservation/guest_summary.dart';
import 'autoCircuits_details.dart';

class AutoCircuitScreen extends StatefulWidget {
  const AutoCircuitScreen({super.key});

  @override
  State<AutoCircuitScreen> createState() => _AutoCircuitScreenState();
}

class _AutoCircuitScreenState extends State<AutoCircuitScreen> {
  final _budgetController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  List<Map<String, dynamic>> _roomsData = [
    {"adults": 2, "children": 0, "childAges": []},
  ];

  DateTime? _startDate;
  DateTime? _endDate;

  String? _startCity;
  String? _endCity;
  String? _startCityId;
  String? _endCityId;

  int get adults => _roomsData.fold(0, (sum, room) => sum + (room["adults"] as int));
  int get children => _roomsData.fold(0, (sum, room) => sum + (room["children"] as int));
  int get rooms => _roomsData.length;

  int get duration => (_startDate != null && _endDate != null)
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

  // ---- SAVE & LOAD DATES + ROOMS ----
  Future<void> _saveDatesAndRooms(DateTime start, DateTime end, List<Map<String, dynamic>> rooms) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auto_start_date', start.toIso8601String());
    await prefs.setString('auto_end_date', end.toIso8601String());
    await prefs.setString('auto_rooms_data', jsonEncode(rooms));
  }

  Future<void> _loadDatesAndRooms() async {
    final prefs = await SharedPreferences.getInstance();
    final start = prefs.getString('auto_start_date');
    final end = prefs.getString('auto_end_date');
    final roomsJson = prefs.getString('auto_rooms_data');

    setState(() {
      _startDate = start != null ? DateTime.tryParse(start) : null;
      _endDate = end != null ? DateTime.tryParse(end) : null;
      _roomsData = roomsJson != null
          ? (jsonDecode(roomsJson) as List<dynamic>)
          .map((e) => Map<String, dynamic>.from(e))
          .toList()
          : [
        {"adults": 2, "children": 0, "childAges": []},
      ];
    });
  }

  @override
  void initState() {
    super.initState();
    _loadDatesAndRooms();
  }

  void _handleComposeButtonPress(AutoCircuitProvider provider) async {
    if (!_formKey.currentState!.validate()) return;

    if (!_isFormValid) {
      _showValidationError();
      return;
    }

    if (_startCityId == _endCityId) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('departure_arrival_same'.tr()),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Save dates + rooms
    if (_startDate != null && _endDate != null) {
      await _saveDatesAndRooms(_startDate!, _endDate!, _roomsData);
    }

    final adultsCount = adults < 1 ? 1 : adults;
    final roomsCount = rooms < 1 ? 1 : rooms;
    final budgetValue =
    (_budgetController.text.isEmpty || double.tryParse(_budgetController.text) == null)
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
    String message = 'validation_check_fields'.tr() + '\n';
    List<String> errors = [];

    if (_startDate == null || _endDate == null) errors.add('• ' + 'travel_dates'.tr());
    if (_startCityId == null || _endCityId == null) errors.add('• ' + 'departure_arrival_cities'.tr());
    if (adults == 0) errors.add('• ' + 'at_least_one_adult'.tr());
    if (_budgetController.text.isEmpty || double.tryParse(_budgetController.text) == null) {
      errors.add('• ' + 'valid_budget'.tr());
    }

    message += errors.join('\n');

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 4),
      ),
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
      _roomsData = [
        {"adults": 2, "children": 0, "childAges": []},
      ];
      _budgetController.clear();
    });
  }

  Widget _buildResultsSection(AutoCircuitProvider provider) {
    if (provider.isLoading) {
      return Center(
        child: Column(
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text('generating_circuit'.tr()),
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
            Text(
              'circuit_generation_error'.tr(),
              style: const TextStyle(
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
              Text(
                'your_circuit'.tr(),
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              TextButton(
                onPressed: _resetForm,
                child: Text('new_circuit'.tr()),
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

              final name = jour['name'] ?? '${'days'.tr()} ${index + 1}';
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
                  title: Text(
                    name,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: description != null ? Text(description) : null,
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                ),
              );
            },
          ),
        ],
      );
    }

    return Center(
      child: Text(
        'no_circuit_generated'.tr(),
        style: const TextStyle(fontSize: 16, color: Colors.grey),
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
    final locale=context.locale;

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
                    child: ScreenTitle(
                      title: 'auto_circuit'.tr(),
                      icon: Icons.account_tree_outlined,
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
                                _saveDatesAndRooms(start, end, _roomsData);
                              }
                            },
                          ),
                          const SizedBox(height: 16),
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
                                    tr('trip_duration', args: [duration.toString(), duration > 1 ? 's' : '']),
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
                            label: 'departure_city'.tr(),
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
                            label: 'arrival_city'.tr(),
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
                          const SizedBox(height: 24),
                          ComposeButton(
                            onPressed: provider.isLoading
                                ? null
                                : () => _handleComposeButtonPress(provider),
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
