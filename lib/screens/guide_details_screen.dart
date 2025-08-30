import 'package:flutter/material.dart';
import 'package:tunisiagotravel/theme/styletext.dart';
import '../models/guide.dart';
import 'package:tunisiagotravel/theme/color.dart';

class GuideDetailsScreen extends StatelessWidget {
  final Guide guide;

  const GuideDetailsScreen({super.key, required this.guide});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("${guide.name} ${guide.lastName}",
            style: Appstylestatic.textStyle22),
        backgroundColor: AppColorstatic.primary,
        elevation: 0,
        centerTitle: true, // Center the title for a professional look
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero Image
            Stack(
              children: [
                Container(
                  width: double.infinity,
                  height: 280, // Slightly taller for better visual impact
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.15),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    child: guide.photo != null
                        ? Image.network(
                      guide.photo!,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return const Center(child: CircularProgressIndicator(color: AppColorstatic.primary));
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(Icons.error_outline, size: 120, color: Colors.grey);
                      },
                    )
                        : const Center(
                      child: Icon(Icons.person_outline, size: 120, color: Colors.grey),
                    ),
                  ),
                ),
                // Subtle gradient overlay at the bottom for creativity
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    height: 80,
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24)),
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, Colors.black.withOpacity(0.3)],
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // Infos in a clean, padded container with rounded corners
            Padding(
              padding: const EdgeInsets.fromLTRB(16.0, 24.0, 16.0, 16.0), // Added top padding for breathing room
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0), // Increased padding for professionalism
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Full Name as prominent header
                      Text(
                        "${guide.name} ${guide.lastName}",
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: AppColorstatic.primary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Guide Professionel",
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                          fontStyle: FontStyle.italic, // Creative touch
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Contact Information Section with ListTiles for better UX
                      if (guide.email != null ||
                          guide.phone != null ||
                          guide.address != null) ...[
                        Text(
                          "Contact Information",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppColorstatic.darker,
                          ),
                        ),
                        const SizedBox(height: 12),
                        if (guide.email != null && guide.email!.isNotEmpty)
                          _buildInfoTile(Icons.email_outlined, "Email", guide.email!),
                        if (guide.phone != null && guide.phone!.isNotEmpty)
                          _buildInfoTile(Icons.phone_outlined, "Phone", guide.phone!),
                        if (guide.address != null && guide.address!.isNotEmpty)
                          _buildInfoTile(Icons.location_on_outlined, "Address", guide.address!),
                        const SizedBox(height: 32),
                      ],

                      // Description Section
                      if (guide.description != null &&
                          guide.description!.isNotEmpty) ...[
                        Text(
                          "À Propos",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppColorstatic.darker,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          guide.description!,
                          style: TextStyle(
                            fontSize: 15,
                            height: 1.6,
                            color: Colors.grey[800],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoTile(IconData icon, String label, String text) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, size: 24, color: AppColorstatic.primary),
      title: Text(
        label,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppColorstatic.darker,
        ),
      ),
      subtitle: Text(
        text,
        style: TextStyle(
          fontSize: 14,
          color: Colors.grey[700],
        ),
      ),
      dense: true,
    );
  }
}