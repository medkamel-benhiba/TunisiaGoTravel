import 'package:flutter/material.dart';
import '../../models/hotel.dart';
import '../../theme/color.dart';

class BottomAction extends StatelessWidget {
  final Map<String, dynamic> selectedRoom;
  final Map<String, dynamic> selectedBoarding;
  final int quantity;
  final Hotel hotel;
  final Map<String, dynamic> searchCriteria;
  final VoidCallback onReservationComplete;

  const BottomAction({
    super.key,
    required this.selectedRoom,
    required this.selectedBoarding,
    required this.quantity,
    required this.hotel,
    required this.searchCriteria,
    required this.onReservationComplete,
  });

  @override
  Widget build(BuildContext context) {
    final totalPrice = _calculateTotalPrice();

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Prix Total:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              Text('$totalPrice TND', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColorstatic.primary)),
            ],
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => _handleFinalReservation(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColorstatic.primary,
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Réserver', style: TextStyle(fontSize: 18, color: Colors.white)),
          ),
        ],
      ),
    );
  }

  double _calculateTotalPrice() {
    final roomPrice = double.tryParse(selectedRoom['Price']?.toString().replaceAll(',', '.') ?? '0') ?? 0;
    final boardingPrice = double.tryParse(selectedBoarding['price']?.toString().replaceAll(',', '.') ?? '0') ?? 0;
    return (roomPrice + boardingPrice) * quantity;
  }

  void _handleFinalReservation(BuildContext context) {
    final reservationData = {
      'hotel': hotel.toJson(),
      'room': selectedRoom,
      'boarding': selectedBoarding,
      'quantity': quantity,
      'totalPrice': _calculateTotalPrice(),
      'searchCriteria': searchCriteria,
    };

    print('Reservation Data: $reservationData');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Réservation confirmée'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Votre réservation a été enregistrée avec succès!'),
            const SizedBox(height: 16),
            Text('Hôtel: ${hotel.name}'),
            Text('Chambre: ${selectedRoom['Title'] ?? 'Standard'}'),
            Text('Pension: ${selectedBoarding['Title'] ?? 'Standard'}'),
            Text('Quantité: $quantity chambre(s)'),
            Text('Prix total: ${_calculateTotalPrice()} TND'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              onReservationComplete();
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}