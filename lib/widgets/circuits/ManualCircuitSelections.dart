import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../models/destination.dart';
import '../../theme/color.dart';

/// Widget pour afficher l'indicateur de progression du circuit
class CircuitProgressIndicator extends StatelessWidget {
  final int currentStep;
  final int totalSteps;
  final List<String> labels;

  const CircuitProgressIndicator({
    super.key,
    required this.currentStep,
    required this.totalSteps,
    this.labels = const [],
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Barre de progression
          LinearProgressIndicator(
            value: currentStep / totalSteps,
            backgroundColor: Colors.grey[300],
            valueColor: AlwaysStoppedAnimation<Color>(AppColorstatic.primary),
            minHeight: 6,
          ),

          const SizedBox(height: 12),

          // Labels si fournis
          if (labels.isNotEmpty)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: labels.asMap().entries.map((entry) {
                final index = entry.key + 1;
                final label = entry.value;
                final isActive = index <= currentStep;
                final isCurrent = index == currentStep;

                return Expanded(
                  child: Text(
                    label,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                      color: isActive ? AppColorstatic.primary : Colors.grey,
                    ),
                  ),
                );
              }).toList(),
            ),

          // Texte de progression
          if (labels.isEmpty)
            Text(
              'Étape $currentStep sur $totalSteps',
              style: TextStyle(
                fontSize: 12,
                color: AppColorstatic.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
        ],
      ),
    );
  }
}

/// Widget pour afficher une carte de sélection de destination
class DestinationSelectionCard extends StatelessWidget {
  final DestinationSelection destination;
  final Function(int) onDaysChanged;
  final Function(bool) onStartChanged;
  final int maxDays;
  final int remainingDays;

  const DestinationSelectionCard({
    super.key,
    required this.destination,
    required this.onDaysChanged,
    required this.onStartChanged,
    required this.maxDays,
    required this.remainingDays,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: destination.days > 0
              ? AppColorstatic.primary.withOpacity(0.3)
              : Colors.transparent,
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Nom de la destination (multilingue)
            Text(
              destination.getName(context.locale), // Use multilingual name
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: destination.days > 0 ? AppColorstatic.primary : null,
              ),
            ),

            const SizedBox(height: 12),

            // Contrôles
            Row(
              children: [
                // Checkbox ville de départ
                Expanded(
                  flex: 2,
                  child: Row(
                    children: [
                      Checkbox(
                        value: destination.isStart,
                        onChanged: (value) => onStartChanged(value ?? false),
                        activeColor: AppColorstatic.primary,
                      ),
                      Expanded(
                        child: Text(
                          "start_city".tr(),
                          style: TextStyle(fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ),

                // Contrôles de jours
                Expanded(
                  flex: 3,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text("days".tr()),

                      // Bouton diminuer
                      IconButton(
                        icon: Icon(
                          Icons.remove_circle_outline,
                          color: destination.days > 0 ? AppColorstatic.primary : Colors.grey,
                        ),
                        onPressed: destination.days > 0
                            ? () => onDaysChanged(destination.days - 1)
                            : null,
                      ),

                      // Affichage du nombre
                      Container(
                        width: 40,
                        height: 30,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(4),
                          color: destination.days > 0
                              ? AppColorstatic.primary.withOpacity(0.1)
                              : null,
                        ),
                        child: Center(
                          child: Text(
                            destination.days.toString(),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: destination.days > 0
                                  ? AppColorstatic.primary
                                  : null,
                            ),
                          ),
                        ),
                      ),

                      // Bouton augmenter
                      IconButton(
                        icon: Icon(
                          Icons.add_circle_outline,
                          color: remainingDays > 0 ? AppColorstatic.primary : Colors.grey,
                        ),
                        onPressed: remainingDays > 0
                            ? () => onDaysChanged(destination.days + 1)
                            : null,
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // Indicateur de jours restants si nécessaire
            /*if (remainingDays <= 2 && remainingDays > 0)
              Container(
                margin: const EdgeInsets.only(top: 8),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.orange.shade100,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  "$remainingDays jour${remainingDays > 1 ? 's' : ''} disponible${remainingDays > 1 ? 's' : ''}",
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.orange.shade800,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),*/
          ],
        ),
      ),
    );
  }
}

/// Widget pour afficher le résumé du circuit
class CircuitSummaryCard extends StatelessWidget {
  final Map<String, dynamic> summary;
  final int maxDuration;

  const CircuitSummaryCard({
    super.key,
    required this.summary,
    required this.maxDuration,
  });

  @override
  Widget build(BuildContext context) {
    final totalDays = summary['totalDays'] as int;
    final destinationsCount = summary['destinationsCount'] as int;
    final startCity = summary['startCity'] as String;
    final destinations = summary['destinations'] as List<dynamic>;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColorstatic.primary.withOpacity(0.05),
        border: Border.all(color: AppColorstatic.primary.withOpacity(0.2)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // En-tête
          Row(
            children: [
              Icon(
                Icons.summarize,
                color: AppColorstatic.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                "circuit_summary".tr(),
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColorstatic.primary,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Statistiques
          Row(
            children: [
              Expanded(
                child: _buildStat(
                  context,
                  Icons.location_on,
                  "$destinationsCount",
                  "destinations.title".tr(),
                ),
              ),
              Expanded(
                child: _buildStat(
                  context,
                  Icons.calendar_today,
                  "$totalDays/$maxDuration",
                  "days".tr(),
                ),
              ),
              Expanded(
                child: _buildStat(
                  context,
                  Icons.flag,
                  startCity,
                  "start_city".tr(),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Liste des destinations sélectionnées
          if (destinations.isNotEmpty) ...[
            Text(
              "selected_destinations".tr(),
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColorstatic.primary,
              ),
            ),
            const SizedBox(height: 6),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: destinations.map((dest) {
                final name = dest['name'] as String;
                final days = dest['days'] as int;
                final isStart = dest['isStart'] as bool;

                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: isStart ? AppColorstatic.primary : Colors.grey.shade600,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    "$name ($days)${isStart ? ' 🚩' : ''}",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStat(BuildContext context, IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, size: 16, color: AppColorstatic.primary),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColorstatic.primary,
            fontSize: 12,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }
}