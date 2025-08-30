import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/hotel_details.dart';
import '../../providers/hotel_provider.dart';
import '../../theme/color.dart';
import '../widgets/gallery.dart';
import '../widgets/hotel/contact_card.dart';
import '../widgets/hotel/description_card.dart';
import '../widgets/hotel/hotel_info_card.dart';

class HotelDetailsScreen extends StatefulWidget {
  final String hotelSlug;

  const HotelDetailsScreen({super.key, required this.hotelSlug});

  @override
  State<HotelDetailsScreen> createState() => _HotelDetailsScreenState();
}

class _HotelDetailsScreenState extends State<HotelDetailsScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final provider = Provider.of<HotelProvider>(context, listen: false);
      provider.fetchHotelDetail(widget.hotelSlug);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<HotelProvider>(
      builder: (context, provider, child) {
        final HotelDetail? hotel = provider.selectedHotel;

        return Scaffold(
          appBar: AppBar(
            title: Text(
              hotel?.name ?? 'Hotel Details',
              style: const TextStyle(
                color: AppColorstatic.lightTextColor,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            backgroundColor: AppColorstatic.primary,
            iconTheme: const IconThemeData(color: Colors.white),
          ),
          body: provider.isLoading && hotel == null
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Images gallery
                if (hotel?.images != null && hotel!.images!.isNotEmpty)
                  ImageGridPreview(images: hotel.images!),

                const SizedBox(height: 12),

                // Info card (name, address, category)
                if (hotel != null &&
                    (hotel.name != null ||
                        hotel.address != null ||
                        hotel.categoryCode != null))
                  HotelInfoCard(hotel: hotel),

                // Description
                if (hotel != null &&
                    (hotel.description ?? '').isNotEmpty)
                  HotelDescriptionCard(hotel: hotel),

                // Contact info
                if (hotel != null &&
                    ((hotel.phone ?? '').isNotEmpty ||
                        (hotel.email ?? '').isNotEmpty))
                  HotelContactCard(hotel: hotel),

                // Fallback if nothing exists
                if (hotel == null)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text(
                        'No details available for this hotel.',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
