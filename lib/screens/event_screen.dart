import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tunisiagotravel/providers/destination_provider.dart';
import '../providers/event_provider.dart';
import '../widgets/event_card.dart';
import '../widgets/destinations_list.dart';
import '../widgets/screen_title.dart';

enum EventsViewType { list, grid }

class EventScreenContent extends StatefulWidget {
  const EventScreenContent({super.key});

  @override
  State<EventScreenContent> createState() => _EventScreenState();
}

class _EventScreenState extends State<EventScreenContent> {
  String? selectedDestinationId;
  String? selectedDestinationTitle;
  EventsViewType _viewType = EventsViewType.list;

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
                icon: selectedDestinationId == null ? Icons.location_on : Icons.event,
                title: selectedDestinationId == null
                    ? 'restaurantsScreen.destinations'.tr()
                    : 'events_at'.tr(
                  args: [displayDestination],
                ),
              );
            }),
          ),

          // Toggle list / grid view
          if (selectedDestinationId != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ToggleButton(
                    icon: Icons.list,
                    isSelected: _viewType == EventsViewType.list,
                    onTap: () => setState(() => _viewType = EventsViewType.list),
                  ),
                  const SizedBox(width: 8),
                  ToggleButton(
                    icon: Icons.grid_view,
                    isSelected: _viewType == EventsViewType.grid,
                    onTap: () => setState(() => _viewType = EventsViewType.grid),
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

    return _viewType == EventsViewType.list
        ? ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: events.length,
      itemBuilder: (context, index) {
        return EventCard(event: events[index]);
      },
    )
        : GridView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: events.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.6,
      ),
      itemBuilder: (context, index) {
        return EventCard(event: events[index]);
      },
    );
  }
}

// ToggleButton widget
class ToggleButton extends StatelessWidget {
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const ToggleButton({
    super.key,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue : Colors.grey[200],
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.all(8),
        child: Icon(icon, color: isSelected ? Colors.white : Colors.black),
      ),
    );
  }
}
