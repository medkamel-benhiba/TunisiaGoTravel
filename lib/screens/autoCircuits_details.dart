import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:tunisiagotravel/widgets/circuits/CircuitReservationButton.dart';
import '../theme/color.dart';
import '../theme/styletext.dart';
import '../widgets/circuits/DayCard.dart';

class AutoCircuitDayScreen extends StatelessWidget {
  final Map<String, dynamic> listparjours;
  final Map<String, dynamic>? circuitData;
  final Map<String, dynamic>? formData;


  const AutoCircuitDayScreen({
    super.key,
    required this.listparjours,
    this.circuitData,
    this.formData,
  });

  @override
  Widget build(BuildContext context) {
    final locale = context.locale;
    final days = listparjours.keys.toList()..sort();
    print("********formData: $formData");

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'your_circuit'.tr(),
          style: Appstylestatic.appBarTitle1.copyWith(color: Colors.white),
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
            child: CircuitReservationButton(
              circuitData: listparjours,
              isManualCircuit: false,
              formData: formData??{},
            ),
          ),
        ],
      ),
    );
  }
}
