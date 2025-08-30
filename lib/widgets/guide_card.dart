import 'package:flutter/material.dart';
import 'package:tunisiagotravel/theme/color.dart';
import '../models/guide.dart';
import '../screens/guide_details_screen.dart';

class GuideCard extends StatelessWidget {
  final Guide guide;
  final bool isGrid; // 👈 ajouté

  const GuideCard({
    super.key,
    required this.guide,
    required this.isGrid,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey[200]!),
      ),
      elevation: 4,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => GuideDetailsScreen(guide: guide),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: isGrid ? _buildGridContent() : _buildListContent(),
        ),
      ),
    );
  }

  Widget _buildListContent() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildPhoto(80),
        const SizedBox(width: 16),
        Expanded(child: _buildInfo()),
      ],
    );
  }

  Widget _buildGridContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _buildPhoto(100),
        const SizedBox(height: 12),
        _buildInfo(center: true),
      ],
    );
  }

  Widget _buildPhoto(double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: guide.photo == null ? Colors.grey[300] : null,
        image: guide.photo != null
            ? DecorationImage(
          image: NetworkImage(guide.photo),
          fit: BoxFit.cover,
        )
            : null,
      ),
      child: guide.photo == null
          ? const Icon(Icons.person, size: 40, color: Colors.grey)
          : null,
    );
  }

  Widget _buildInfo({bool center = false}) {
    final textAlign = center ? TextAlign.center : TextAlign.start;
    final crossAlign =
    center ? CrossAxisAlignment.center : CrossAxisAlignment.start;
    final mainAlign =
    center ? MainAxisAlignment.center : MainAxisAlignment.start;

    final List<Widget> contactChildren = [];

    if (guide.email != null && guide.email!.isNotEmpty) {
      if (contactChildren.isNotEmpty) contactChildren.add(const SizedBox(height: 4));
      contactChildren.add(
        Row(
          mainAxisAlignment: mainAlign,
          children: [
            const Icon(Icons.email, size: 14, color: AppColorstatic.primary),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                guide.email!,
                style: const TextStyle(fontSize: 12, color: AppColorstatic.darker),
                overflow: TextOverflow.ellipsis,
                textAlign: textAlign,
              ),
            ),
          ],
        ),
      );
    }

    if (guide.phone != null && guide.phone!.isNotEmpty) {
      if (contactChildren.isNotEmpty) contactChildren.add(const SizedBox(height: 4));
      contactChildren.add(
        Row(
          mainAxisAlignment: mainAlign,
          children: [
            const Icon(Icons.phone, size: 14, color: AppColorstatic.primary),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                guide.phone!,
                style: const TextStyle(fontSize: 12, color: AppColorstatic.darker),
                overflow: TextOverflow.ellipsis,
                textAlign: textAlign,
              ),
            ),
          ],
        ),
      );
    }

    if (guide.address != null && guide.address!.isNotEmpty) {
      if (contactChildren.isNotEmpty) contactChildren.add(const SizedBox(height: 4));
      contactChildren.add(
        Row(
          mainAxisAlignment: mainAlign,
          children: [
            const Icon(Icons.location_on, size: 14, color: AppColorstatic.primary),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                guide.address!,
                style: const TextStyle(fontSize: 12, color: AppColorstatic.darker),
                overflow: TextOverflow.ellipsis,
                textAlign: textAlign,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: crossAlign,
      children: [
        Text(
          "${guide.name} ${guide.lastName}",
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
          textAlign: textAlign,
        ),
        if (contactChildren.isNotEmpty) const SizedBox(height: 8),
        ...contactChildren,
      ],
    );
  }
}
