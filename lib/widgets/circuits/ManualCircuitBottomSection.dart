import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../providers/manual_circuit_provider.dart';
import '../../theme/color.dart';
import 'ManualCircuitSelections.dart'; // Pour CircuitSummaryCard

class CircuitBottomSection extends StatelessWidget {
  final ManualCircuitProvider provider;
  final int maxDuration;
  final VoidCallback onConfirm;

  const CircuitBottomSection({
    super.key,
    required this.provider,
    required this.maxDuration,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    final hasSelection = provider.destinations.any((d) => d.days > 0);
    if (!hasSelection) return const SizedBox.shrink();

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, -2),
          )
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircuitSummaryCard(
            summary: provider.getCircuitSummary(),
            maxDuration: maxDuration,
          ),
          Container(
            padding: const EdgeInsets.all(16),
            width: double.infinity,
            child: ElevatedButton(
              onPressed: provider.isCreatingCircuit ? null : onConfirm,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColorstatic.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 2,
              ),
              child: provider.isCreatingCircuit
                  ?  Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                  SizedBox(width: 12),
                  Text("creating_circuit".tr()),
                ],
              )
                  : Text(
                "create_circuit".tr(),
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
