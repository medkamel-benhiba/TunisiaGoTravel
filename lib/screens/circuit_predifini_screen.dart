import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/voyage_provider.dart';
import '../widgets/circuits/circuitpre_card.dart';
import '../widgets/screen_title.dart';

class CircuitPreScreen extends StatefulWidget {
  const CircuitPreScreen({super.key});

  @override
  State<CircuitPreScreen> createState() => _CircuitPreScreenState();
}

class _CircuitPreScreenState extends State<CircuitPreScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() =>
        Provider.of<VoyageProvider>(context, listen: false).fetchVoyages());
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<VoyageProvider>(context);
    final voyages = provider.voyages;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            child: ScreenTitle(
              icon: Icons.account_tree_rounded,
              title: 'Circuit Prédéfini',
            ),
          ),
          Expanded(
            child: provider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : provider.error != null
                ? Center(child: Text(provider.error!))
                : voyages.isEmpty
                ? const Center(child: Text('Aucun voyage disponible'))
                : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: voyages.length,
              itemBuilder: (_, index) =>
                  CircuitPreCard(voyage: voyages[index]),
            ),
          ),
        ],
      ),
    );
  }
}
