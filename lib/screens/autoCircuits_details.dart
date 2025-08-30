import 'package:flutter/material.dart';
import '../theme/color.dart';
import '../theme/styletext.dart';
import '../widgets/circuits/DayCard.dart';

class CircuitDayScreen extends StatelessWidget {
  final Map<String, dynamic> listparjours;
  const CircuitDayScreen({super.key, required this.listparjours});

  @override
  Widget build(BuildContext context) {
    final days = listparjours.keys.toList()..sort();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Votre Circuit",
          style: Appstylestatic.appBarTitle1.copyWith(color: Colors.white),
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
