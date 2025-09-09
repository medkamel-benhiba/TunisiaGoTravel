import 'package:flutter/material.dart';
import '../../models/artisanat.dart';
import 'package:url_launcher/url_launcher.dart';

class ArtisanatInfoCard extends StatelessWidget {
  final Artisanat artisanat;

  const ArtisanatInfoCard({super.key, required this.artisanat});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white,
            Colors.grey.shade50,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.15),
            spreadRadius: 0,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              // Optional: Handle card tap
            },
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header section with icon and title
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.purple.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.handyman,
                          color: Colors.purple,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          artisanat.name,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Type of artisanat
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.amber.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.amber.shade100,
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.category,
                          color: Colors.amber.shade700,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Type d\'artisanat',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.amber.shade700,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Artisanat traditionnel tunisien',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.amber.shade800,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                 /* // Action buttons row
                  Row(
                    children: [
                      if (artisanat.videoLink.isNotEmpty)
                        Expanded(
                          child: TextButton.icon(
                            onPressed: () async {
                              final videoUrl = artisanat.videoLink;
                              if (videoUrl.isNotEmpty) {
                                final uri = Uri.parse(videoUrl);
                                // Check if the URL can be launched
                                if (await canLaunchUrl(uri)) {
                                  // Launch the URL, a browser will handle the video playback.
                                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                                } else {
                                  // Display an error message if the URL cannot be launched.
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text("Impossible d'ouvrir la vidéo")),
                                  );
                                }
                              }
                            },
                            icon: const Icon(Icons.play_circle_outline, size: 18),
                            label: const Text('Voir la vidéo'),
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.red[600],
                              padding: const EdgeInsets.symmetric(vertical: 8),
                            ),
                          ),
                        ),
                    ],
                  ),*/
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
