import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/guide_provider.dart';
import '../widgets/guide_card.dart';
import '../widgets/screen_title.dart';

enum GuideViewType { list, grid }

class GuideScreen extends StatefulWidget {
  const GuideScreen({super.key});

  @override
  State<GuideScreen> createState() => _GuideScreenState();
}

class _GuideScreenState extends State<GuideScreen> {
  GuideViewType _viewType = GuideViewType.list;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<GuideProvider>(context, listen: false);
      if (!provider.isLoading && provider.guides.isEmpty) {
        provider.fetchGuides();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<GuideProvider>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Screen title
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 12),
            child: ScreenTitle(title: "Guides", icon: Icons.person),
          ),

          // Toggle buttons list/grid
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ToggleButton(
                  icon: Icons.list,
                  isSelected: _viewType == GuideViewType.list,
                  onTap: () => setState(() => _viewType = GuideViewType.list),
                ),
                const SizedBox(width: 8),
                ToggleButton(
                  icon: Icons.grid_view,
                  isSelected: _viewType == GuideViewType.grid,
                  onTap: () => setState(() => _viewType = GuideViewType.grid),
                ),
              ],
            ),
          ),

          // Main content
          Expanded(
            child: provider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : provider.guides.isEmpty
                ? const Center(child: Text("Aucun guide disponible"))
                : _viewType == GuideViewType.list
                ? ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: provider.guides.length,
              itemBuilder: (context, index) {
                return GuideCard(
                  guide: provider.guides[index],
                  isGrid: false,
                );
              },
            )
                : GridView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: provider.guides.length,
              gridDelegate:
              const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 0.6,
              ),
              itemBuilder: (context, index) {
                return GuideCard(
                  guide: provider.guides[index],
                  isGrid: true,
                );
              },
            ),
          ),
        ],
      ),
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
