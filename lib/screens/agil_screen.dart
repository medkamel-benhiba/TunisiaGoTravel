import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/agil.dart';
import '../services/api_service.dart';
import '../widgets/agilCard.dart';

class AgilScreen extends StatefulWidget {
  const AgilScreen({super.key});

  @override
  State<AgilScreen> createState() => _AgilScreenState();
}

class _AgilScreenState extends State<AgilScreen> {
  late Future<List<Agil>> _agilFuture;

  @override
  void initState() {
    super.initState();
    _agilFuture = ApiService().getagil(); // 🔹 API call
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: FutureBuilder<List<Agil>>(
        future: _agilFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Erreur: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Aucun agil disponible.'));
          }

          final agilList = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: agilList.length,
            itemBuilder: (_, index) => AgilCard(agil: agilList[index]),
          );
        },
      ),
    );
  }
}
