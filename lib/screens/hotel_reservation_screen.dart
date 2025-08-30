/*import 'package:flutter/material.dart';
import '../models/hotel.dart';
import '../widgets/reservation/boarding_selection.dart';
import '../widgets/reservation/room_selection.dart';

class ReservationScreen extends StatefulWidget {
  final Hotel hotel;
  final Map<String, dynamic> searchCriteria;

  const ReservationScreen({
    Key? key,
    required this.hotel,
    required this.searchCriteria,
  }) : super(key: key);

  @override
  State<ReservationScreen> createState() => _ReservationScreenState();
}

class _ReservationScreenState extends State<ReservationScreen> {
  int selectedBoardingIndex = 0;

  @override
  Widget build(BuildContext context) {
    final hasBoardings = widget.hotel.boardings.isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.hotel.name),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 🔹 Header + critères de recherche
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.hotel.name,
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold)),
                Text(widget.hotel.cityName),
                const SizedBox(height: 10),
                Text("Critères : ${widget.searchCriteria.toString()}"),
              ],
            ),
          ),

          const Divider(),

          // 🔹 Affichage boarding si dispo
          if (hasBoardings)
            BoardingSelection(
              boardings: widget.hotel.boardings,
              selectedIndex: selectedBoardingIndex,
              onChanged: (index) {
                setState(() {
                  selectedBoardingIndex = index;
                });
              },
            ),

          const Divider(),

          // 🔹 Affichage des chambres
          Expanded(
            child: hasBoardings
                ? RoomSelection(
              rooms: widget
                  .hotel.boardings[selectedBoardingIndex].rooms,
              currency: widget.hotel.currency,
            )
                : Center(
              child: Text(
                "Aucune pension disponible pour cet hôtel.\nVeuillez contacter l’agence.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              ),
            ),
          ),

          // 🔹 Footer avec prix total + bouton suivant
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              border: const Border(top: BorderSide(color: Colors.grey)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Prix total: -- ${widget.hotel.currency}", // tu pourras remplacer avec ton calcul
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
                ElevatedButton(
                  onPressed: () {
                    // action suivant
                  },
                  child: const Text("Suivant"),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}*/
