import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tunisiagotravel/providers/destination_provider.dart';
import '../providers/event_provider.dart';
import '../widgets/event_card.dart';
import '../widgets/destinations_list.dart';
import '../widgets/screen_title.dart';

class EventScreenContent extends StatefulWidget {
  const EventScreenContent({super.key});

  @override
  State<EventScreenContent> createState() => _EventScreenState();
}

class _EventScreenState extends State<EventScreenContent> {
  String? selectedDestinationId;
  String? selectedDestinationTitle;

  @override
  void initState() {
    super.initState();
    // Fetch events on init
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<EventProvider>(context, listen: false);
      provider.fetchEvents().then((_) {
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<EventProvider>(context);

    // Filter events by selected destination
    final filteredEvents = selectedDestinationId != null
        ? provider.getEventsByDestination(selectedDestinationId!)
        : <dynamic>[];

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Screen title
          Padding(
            padding: const EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 0.0),
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
                icon: selectedDestinationId == null ? Icons.location_on : Icons.event,
                title: selectedDestinationId == null
                    ? 'restaurantsScreen.destinations'.tr()
                    : 'events_at'.tr(
                  args: [displayDestination],
                ),
              );
            }),
          ),

          if (selectedDestinationId != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 1.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton.icon(
                    onPressed: () {
                      setState(() {
                        selectedDestinationId = null;
                        selectedDestinationTitle = null;
                      });
                    },
                    icon: const Icon(Icons.arrow_back, size: 16),
                    label: Text('restaurantsScreen.destinations'.tr()),
                  ),
                ],
              ),
            ),

          // Main content: Destinations or filtered events
          Expanded(
            child: selectedDestinationId == null
                ? DestinationsList(
              onDestinationSelected: (destination) {
                setState(() {
                  selectedDestinationId = destination.id;
                  selectedDestinationTitle = destination.name;
                });
                provider.setEventsByDestination(destination.id);
              },
            )
                : _buildEvents(filteredEvents, provider.isLoading, provider.errorMessage),
          ),
        ],
      ),
    );
  }

  Widget _buildEvents(List<dynamic> events, bool isLoading, String? errorMessage) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (errorMessage != null) {
      return Center(child: Text(errorMessage));
    }

    if (events.isEmpty) {
      return const Center(child: Text('Aucun événement disponible pour cette destination'));
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 2.0, horizontal: 12.0),
      itemCount: events.length,
      itemBuilder: (context, index) {
        return EventCard(event: events[index]);
      },
    );
  }
}