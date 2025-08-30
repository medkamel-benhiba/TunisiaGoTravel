import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/manual_circuit_provider.dart';
import '../../theme/color.dart';
import '../widgets/circuits/ManualCircuitBottomSection.dart';
import '../widgets/circuits/ManualCircuitSelections.dart';
import 'manualCircuit_details.dart';

class ManualDestinationSelectionScreen extends StatefulWidget {
  final Map<String, dynamic> formData;
  final int duration;

  const ManualDestinationSelectionScreen({
    super.key,
    required this.formData,
    required this.duration,
  });

  @override
  State<ManualDestinationSelectionScreen> createState() =>
      _ManualDestinationSelectionScreenState();
}

class _ManualDestinationSelectionScreenState
    extends State<ManualDestinationSelectionScreen> {

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchDestinations();
    });
  }

  Future<void> _fetchDestinations() async {
    final provider = Provider.of<ManualCircuitProvider>(context, listen: false);

    await provider.fetchDestinations(
      budget: widget.formData['budget'],
      start: widget.formData['start'],
      end: widget.formData['end'],
      depart: widget.formData['departCityId'],
      arrive: widget.formData['arriveCityId'],
      adults: widget.formData['adults'],
      children: widget.formData['children'],
      room: widget.formData['room'],
      duration: widget.duration,
    );
  }

  Future<void> _confirmSelection() async {
    final provider = Provider.of<ManualCircuitProvider>(context, listen: false);

    final validationError = provider.validateDestinationSelection(widget.duration);
    if (validationError != null) {
      _showErrorSnackBar(validationError);
      return;
    }

    final success = await provider.createCircuit(
      budget: widget.formData['budget'],
      start: widget.formData['start'],
      end: widget.formData['end'],
      adults: widget.formData['adults'],
      children: widget.formData['children'],
      room: widget.formData['room'],
      maxDuration: widget.duration,
    );

    if (success && provider.circuit != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ManualCircuitDayScreen(
            listparjours: provider.circuit!.listparjours,
          ),
        ),
      );
    }

  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Sélection des Destinations"),
        backgroundColor: AppColorstatic.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Consumer<ManualCircuitProvider>(
        builder: (context, provider, _) {
          return Column(
            children: [
              CircuitProgressIndicator(
                currentStep: 2,
                totalSteps: 3,
                labels: const ['Formulaire', 'Destinations', 'Circuit'],
              ),
              Expanded(child: _buildMainContent(provider)),
              if (provider.destinations.isNotEmpty && !provider.isLoading)
                CircuitBottomSection(
                  provider: provider,
                  maxDuration: widget.duration,
                  onConfirm: _confirmSelection,
                ),            ],
          );
        },
      ),
    );
  }

  Widget _buildMainContent(ManualCircuitProvider provider) {
    if (provider.isFetchingDestinations) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text("Recherche des destinations disponibles..."),
          ],
        ),
      );
    }

    if (provider.error != null && provider.destinations.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              provider.error!,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _fetchDestinations,
              icon: const Icon(Icons.refresh),
              label: const Text("Réessayer"),
            ),
          ],
        ),
      );
    }

    if (provider.destinations.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.location_off, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text("Aucune destination disponible"),
          ],
        ),
      );
    }

    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          margin: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.blue.shade200),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.blue.shade700),
                  const SizedBox(width: 8),
                  Text(
                    "Instructions",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                "• Sélectionnez le nombre de jours pour chaque destination\n"
                    "• Choisissez une ville de départ\n"
                    "• Total maximum: ${widget.duration} jours",
                style: TextStyle(color: Colors.blue.shade600),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: provider.destinations.length,
            itemBuilder: (context, index) {
              final destination = provider.destinations[index];
              return DestinationSelectionCard(
                destination: destination,
                onDaysChanged: (days) => provider.updateDestinationDays(destination.id, days),
                onStartChanged: (isStart) {
                  if (isStart) provider.setStartDestination(destination.id);
                },
                maxDays: widget.duration,
                remainingDays: widget.duration - provider.totalSelectedDays + destination.days,
              );
            },
          ),
        ),
      ],
    );
  }

}
