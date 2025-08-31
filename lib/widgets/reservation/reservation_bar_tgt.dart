import 'package:flutter/material.dart';
import '../../theme/color.dart';

class ReservationBottomBarTgt extends StatelessWidget {
  final double total;
  final String currency;
  final int nights;
  final int totalRooms;
  final VoidCallback onReserve;

  const ReservationBottomBarTgt({
    super.key,
    required this.total,
    required this.currency,
    required this.nights,
    required this.totalRooms,
    required this.onReserve,
  });

  @override
  Widget build(BuildContext context) {
    final isEnabled = total > 0 && totalRooms > 0;
    final averagePricePerNight = nights > 0 ? (total / nights).toDouble() : 0.0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Price summary row
            if (isEnabled) ...[
              _buildPriceSummary(averagePricePerNight),
              const SizedBox(height: 12),
            ],
            // Main action row
            Row(
              children: [
                // Price display
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (isEnabled) ...[
                        Text(
                          "${total.toStringAsFixed(2)} $currency",
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppColorstatic.primary,
                          ),
                        ),
                        Text(
                          "pour $nights nuit${nights > 1 ? 's' : ''} • $totalRooms chambre${totalRooms > 1 ? 's' : ''}",
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ] else ...[
                        Text(
                          "Sélectionnez vos chambres",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey[600],
                          ),
                        ),
                        Text(
                          "Prix affiché après sélection",
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                // Reserve button
                SizedBox(
                  width: 140,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: isEnabled ? onReserve : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isEnabled
                          ? AppColorstatic.primary
                          : Colors.grey[300],
                      foregroundColor: Colors.white,
                      elevation: isEnabled ? 4 : 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    child: Text(
                      isEnabled ? "Réserver" : "Sélectionner",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceSummary(double averagePricePerNight) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColorstatic.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppColorstatic.primary.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  size: 16,
                  color: AppColorstatic.primary,
                ),
                const SizedBox(width: 6),
                Text(
                  "Prix moyen par nuit:",
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColorstatic.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Text(
            "${averagePricePerNight.toStringAsFixed(2)} $currency",
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: AppColorstatic.primary,
            ),
          ),
        ],
      ),
    );
  }
}