import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import '../../models/agil.dart';
import 'package:tunisiagotravel/theme/color.dart';

import '../screens/ItineraryScreen.dart';

class AgilCard extends StatefulWidget {
  final Agil agil;

  const AgilCard({super.key, required this.agil});

  @override
  State<AgilCard> createState() => _AgilCardState();
}

class _AgilCardState extends State<AgilCard> {
  bool _isTapped = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isTapped = true),
      onTapUp: (_) => setState(() => _isTapped = false),
      onTapCancel: () => setState(() => _isTapped = false),
      onTap: () {
        // Add navigation or action on card tap (e.g., open details screen)
        // Example: Navigator.push(context, MaterialPageRoute(builder: (_) => AgilDetailsScreen(agil: widget.agil)));
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        transform: Matrix4.identity()..scale(_isTapped ? 0.98 : 1.0),
        child: Card(
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 3,
          shadowColor: Colors.black12,
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.agil.ville,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.agil.adresse,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontSize: 14,
                          color: Colors.grey[700],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Gouvernorat: ${widget.agil.gouverneurat}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontSize: 12,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                InkWell(
                  onTap: () {
                    if (widget.agil.latitude != null && widget.agil.longitude != null) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ItineraryScreen(
                            destination: LatLng(widget.agil.latitude!, widget.agil.longitude!),
                          ),
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Coordonnées de la destination non disponibles'),
                          backgroundColor: Colors.orange,
                        ),
                      );
                    }
                  },
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColorstatic.darkerYellow.withOpacity(0.1),
                    ),
                    child: Icon(
                      Icons.map_outlined,
                      color: AppColorstatic.darkerYellow,
                      size: 24,
                      semanticLabel: 'View on Map',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}