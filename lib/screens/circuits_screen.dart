import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/color.dart';
import '../widgets/menu_card.dart';
import '../providers/global_provider.dart';

class CircuitsScreenContent extends StatelessWidget {
  const CircuitsScreenContent({super.key});

  @override
  Widget build(BuildContext context) {
    final circuitsItems = [
      {
        'title': 'Circuits Manuel',
        'image': 'assets/images/card/circuits.png',
        'color': AppColorstatic.secondary,
        'page': AppPage.circuitsManuel,
      },
      {
        'title': 'Circuit Prédéfini',
        'image': 'assets/images/card/circuits.png',
        'color': AppColorstatic.secondary,
        'page': AppPage.circuitsPredefini,
      },
      {
        'title': 'Circuits Automatique',
        'image': 'assets/images/card/circuits.png',
        'color': AppColorstatic.primary,
        'page': AppPage.circuitsAuto,
      },
    ];

    return ListView(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              childAspectRatio: 1.1,
            ),
            itemCount: circuitsItems.length,
            itemBuilder: (context, index) {
              final item = circuitsItems[index];
              return MenuCard(
                title: item['title'] as String,
                imagePath: item['image'] as String,
                backgroundColor: item['color'] as Color,
                onTap: () {
                  final globalProvider = Provider.of<GlobalProvider>(context, listen: false);
                  globalProvider.setPage(item['page'] as AppPage);
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
