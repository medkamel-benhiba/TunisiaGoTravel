import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../theme/color.dart';
import '../widgets/circuits/DayCard.dart';
import 'package:tunisiagotravel/widgets/circuits/CircuitReservationButton.dart';

class ManualCircuitDayScreen extends StatelessWidget {
  final Map<String, dynamic> listparjours;
  final Map<String, dynamic>? circuitData;
  final Map<String, dynamic>? formData;
  final List<Map<String, dynamic>>? selectedDestinations; // Add this parameter

  const ManualCircuitDayScreen({
    super.key,
    required this.listparjours,
    this.circuitData,
    this.formData,
    this.selectedDestinations, // Add this parameter
  });

  @override
  Widget build(BuildContext context) {
    final days = listparjours.keys.toList()..sort();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "your_circuit".tr(),
          style: const TextStyle(
            color: AppColorstatic.lightTextColor,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: AppColorstatic.primary,
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
      ),
      body: Column(
        children: [
          /// List of days
          Expanded(
            child: ListView.builder(
              itemCount: days.length,
              itemBuilder: (context, index) {
                final dayKey = days[index];
                final dayData = listparjours[dayKey] ?? {};
                return DayCard(dayKey: dayKey, dayData: dayData);
              },
            ),
          ),

          /// Reservation Button
          Container(
            padding: const EdgeInsets.all(16),
            child: Builder(
              builder: (context) {
                // Use passed destinations or fallback to formData
                final destinations = selectedDestinations ??
                    (formData?['alldestination'] as List<Map<String, dynamic>>?) ??
                    [];

                // Create updated formData with selected destinations
                final updatedFormData = Map<String, dynamic>.from(formData ?? {});
                updatedFormData['alldestination'] = destinations;

                print("Selected destinations: $destinations");

                return CircuitReservationButton(
                  circuitData: listparjours,
                  isManualCircuit: true,
                  formData: updatedFormData,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}