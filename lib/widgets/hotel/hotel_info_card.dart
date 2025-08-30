import 'package:flutter/material.dart';
import 'package:tunisiagotravel/theme/styletext.dart';
import '../../models/hotel_details.dart';
import '../base_card.dart';

class HotelInfoCard extends StatelessWidget {
  final HotelDetail hotel;

  const HotelInfoCard({super.key, required this.hotel});

  @override
  Widget build(BuildContext context) {
    return BaseCard(
      margin: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.hotel_class,
                  size: 18,
                  color: Colors.blue[600],
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Text(
                  hotel.name,
                  style: Appstylestatic.titreStyle1,
                  softWrap: true,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),


            ]
        ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.location_on,
                  size: 18,
                  color: Colors.blue[600],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  '${hotel.address}, ${hotel.ville}',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.grey[700],
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}