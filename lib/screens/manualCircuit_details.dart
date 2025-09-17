import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../theme/color.dart';
import '../theme/styletext.dart';
import '../widgets/circuits/DayCard.dart';

class ManualCircuitDayScreen extends StatelessWidget {
  final Map<String, dynamic> listparjours;
  const ManualCircuitDayScreen({super.key, required this.listparjours});

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
      body: ListView.builder(
        itemCount: days.length,
        itemBuilder: (context, index) {
          final dayKey = days[index];
          final dayData = listparjours[dayKey] ?? {};
          return DayCard(dayKey: dayKey, dayData: dayData);
        },
      ),
    );
  }
}
