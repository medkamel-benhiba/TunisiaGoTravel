/*import 'package:flutter/material.dart';
import '../models/destination.dart';
import '../services/api_service.dart'; // Your API methods here
import '../widgets/screen_title.dart';
import 'hotels_screen.dart';

class DestinationsScreen extends StatelessWidget {
  const DestinationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const ScreenTitle(
            icon: Icons.location_on,
            title: 'Destinations',
          ),
          Expanded(
            child: FutureBuilder<List<Destination>>(
              future: ApiService().getDestinations(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Erreur: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('Aucune destination disponible'));
                }

                final destinations = snapshot.data!;

                return ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: destinations.length,
                  itemBuilder: (context, index) {
                    final destination = destinations[index];
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => HotelsScreenContent(),
                          ),
                        );
                      },
                      child: Card(
                        margin: const EdgeInsets.only(bottom: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        clipBehavior: Clip.antiAlias,
                        elevation: 3,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (destination.cover.isNotEmpty)
                              Image.network(
                                destination.cover,
                                height: 180,
                                width: double.infinity,
                                fit: BoxFit.cover,
                              ),
                            Padding(
                              padding: const EdgeInsets.all(12),
                              child: Text(
                                destination.name,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(fontWeight: FontWeight.w600),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
*/