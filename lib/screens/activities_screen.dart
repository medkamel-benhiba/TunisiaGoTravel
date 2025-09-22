import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tunisiagotravel/providers/destination_provider.dart';
import '../providers/activity_provider.dart';
import '../widgets/activity/activity_card.dart';
import '../widgets/destinations_list.dart';
import '../widgets/screen_title.dart';

class ActivitiesScreenContent extends StatefulWidget {
  const ActivitiesScreenContent({super.key});

  @override
  State<ActivitiesScreenContent> createState() => _ActivitiesScreenState();
}

class _ActivitiesScreenState extends State<ActivitiesScreenContent> {
  String? selectedDestinationId;
  String? selectedDestinationTitle;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<ActivityProvider>(context, listen: false);
      provider.fetchActivities().then((_) {
        debugPrint("Fetched ${provider.activities.length} activities");
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ActivityProvider>(context);
    final locale = context.locale;

    // Filtrer les activités selon la destination sélectionnée
    final displayedActivities = selectedDestinationId == null
        ? []
        : provider.activities
        .where((a) => a.destinationId == selectedDestinationId)
        .toList();

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 5.0),
            child: Builder(builder: (context) {
              final destinationProvider =
              Provider.of<DestinationProvider>(context, listen: false);

              // Get the localized destination name if selected
              String displayDestination = '';
              if (selectedDestinationId != null) {
                displayDestination = destinationProvider
                    .getDestinationName(selectedDestinationId!, context.locale);
              }

              return ScreenTitle(
                icon: selectedDestinationId == null ? Icons.location_on : Icons.local_activity_outlined,
                title: selectedDestinationId == null
                    ? 'restaurantsScreen.destinations'.tr()
                    : 'activity_at'.tr(
                  args: [displayDestination],
                ),
              );
            }),
          ),

          Expanded(
            child: selectedDestinationId == null
                ? DestinationsList(
              onDestinationSelected: (destination) {
                debugPrint(
                    "Selected destination: ${destination.name} id: ${destination.id}");
                setState(() {
                  selectedDestinationId = destination.id.toString();
                  selectedDestinationTitle = destination.name;
                });
              },
            )
                : _buildActivities(
              displayedActivities,
              provider.isLoading,
              provider.errorMessage,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivities(
      List<dynamic> activities, bool isLoading, String? errorMessage) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (errorMessage != null) {
      return Center(child: Text(errorMessage));
    }

    if (activities.isEmpty) {
      return const Center(
          child: Text('Aucune activité disponible pour cette destination'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: activities.length,
      itemBuilder: (context, index) {
        return ActivityCard(activity: activities[index]);
      },
    );
  }
}
