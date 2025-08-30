import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/restaurant.dart';
import '../providers/restaurant_provider.dart';
import '../widgets/screen_title.dart';
import '../widgets/restaurant_card.dart';
import '../widgets/destinations_list.dart';

enum RestaurantsViewType { list, grid }

class RestaurantsScreenContent extends StatefulWidget {
  const RestaurantsScreenContent({super.key});

  @override
  State<RestaurantsScreenContent> createState() =>
      _RestaurantsScreenState();
}

class _RestaurantsScreenState extends State<RestaurantsScreenContent> {
  String? selectedDestinationId;
  String? selectedDestinationTitle;
  RestaurantsViewType _viewType = RestaurantsViewType.list;

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<RestaurantProvider>(context);

    // Filter restaurants by selected destination from cache
    final filteredRestaurants = selectedDestinationId != null
        ? provider.getRestaurantsByDestination(selectedDestinationId!)
        : <Restaurant>[];

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Screen title
          Padding(
            padding:
            const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
            child: ScreenTitle(
              icon: selectedDestinationId == null
                  ? Icons.location_on
                  : Icons.restaurant,
              title: selectedDestinationId == null
                  ? 'Destinations'
                  : 'Restaurants à $selectedDestinationTitle',
            ),
          ),

          if (selectedDestinationId != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ToggleButton(
                    icon: Icons.list,
                    isSelected: _viewType == RestaurantsViewType.list,
                    onTap: () =>
                        setState(() => _viewType = RestaurantsViewType.list),
                  ),
                  const SizedBox(width: 8),
                  ToggleButton(
                    icon: Icons.grid_view,
                    isSelected: _viewType == RestaurantsViewType.grid,
                    onTap: () =>
                        setState(() => _viewType = RestaurantsViewType.grid),
                  ),
                ],
              ),
            ),

          // Main content: Destinations list or filtered restaurants
          Expanded(
            child: selectedDestinationId == null
                ? DestinationsList(
              onDestinationSelected: (destination) {
                setState(() {
                  selectedDestinationId = destination.id;
                  selectedDestinationTitle = destination.name;
                });
                // Optional: update provider's current restaurants list
                provider.setRestaurantsByDestination(destination.id);
              },
            )
                : _buildRestaurants(filteredRestaurants, provider.isLoading),
          ),
        ],
      ),
    );
  }

  Widget _buildRestaurants(
      List<Restaurant> restaurants, bool isLoading) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (restaurants.isEmpty) {
      return const Center(
          child: Text('Aucun restaurant disponible pour cette destination'));
    }

    return _viewType == RestaurantsViewType.list
        ? ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: restaurants.length,
      itemBuilder: (context, index) {
        return RestaurantCard(restaurant: restaurants[index]);
      },
    )
        : GridView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: restaurants.length,
      gridDelegate:
      const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.68,
      ),
      itemBuilder: (context, index) {
        return RestaurantCard(restaurant: restaurants[index]);
      },
    );
  }
}

// Simple Toggle Button Widget
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
