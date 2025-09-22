import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:tunisiagotravel/screens/CircuitReservationFormScreen.dart';
import 'package:tunisiagotravel/theme/color.dart';

class CircuitReservationButton extends StatelessWidget {
  final Map<String, dynamic> circuitData;
  final bool isManualCircuit;
  final Map<String, dynamic> formData;

  const CircuitReservationButton({
    super.key,
    required this.circuitData,
    required this.isManualCircuit,
    this.formData = const {},
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(16),
      child: ElevatedButton(
        onPressed: () => _navigateToReservationForm(context),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColorstatic.secondary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 4,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.book_online),
            const SizedBox(width: 8),
            Text(
              'reserve_circuit'.tr(),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToReservationForm(BuildContext context) {
    print("Navigating to reservation form with formData: $formData");

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CircuitReservationFormScreen(
          circuitData: circuitData,
          isManualCircuit: isManualCircuit,
          formData: formData,
        ),
      ),
    );
  }
}