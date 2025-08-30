import 'package:flutter/material.dart';
import '../../theme/color.dart';

class ReservationBottomBar extends StatelessWidget {
  final double total;
  final String currency;
  final VoidCallback? onReserve;

  const ReservationBottomBar({
    super.key,
    required this.total,
    required this.currency,
    this.onReserve,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Prix Total:",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              Text("${total.toStringAsFixed(2)} $currency",
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColorstatic.primary)),
            ],
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: total > 0 ? onReserve : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColorstatic.primary,
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text("Réserver",
                style: TextStyle(fontSize: 18, color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
