/*import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class NetworkListener {
  static StreamSubscription<List<ConnectivityResult>>? _subscription;

  static void startListening(BuildContext context) {
    _subscription = Connectivity().onConnectivityChanged.listen((results) {
      final result = results.isNotEmpty ? results.first : ConnectivityResult.none;

      if (result == ConnectivityResult.none) {
        _showNoConnectionDialog(context);
      }
    });
  }

  static void stopListening() {
    _subscription?.cancel();
  }

  static void _showNoConnectionDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text("Connexion perdue"),
        content: const Text(
          "Vous avez perdu la connexion Internet.\n\nVeuillez réouvrir l'application.",
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Future.delayed(const Duration(milliseconds: 300), () {
                SystemNavigator.pop();
              });
            },
            child: const Text("Fermer"),
          ),
        ],
      ),
    );
  }
}*/
