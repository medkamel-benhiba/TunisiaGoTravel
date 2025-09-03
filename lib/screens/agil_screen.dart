import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tunisiagotravel/widgets/screen_title.dart';
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
    _agilFuture = ApiService().getagil();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
            child: ScreenTitle(
              title: 'Agil Energy ',
              imagePath: 'assets/images/logo_agil.png',
            ),
          ),

          Expanded(
            child: FutureBuilder<List<Agil>>(
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
          ),
        ],
      ),
    );
  }
}