import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tunisiagotravel/screens/festival_details_screen.dart';
import 'package:tunisiagotravel/screens/monument_details_screen.dart';
import '../theme/color.dart';
import '../widgets/menu_card.dart';
import '../widgets/screen_title.dart';
import '../widgets/cultures/cultures_item_tile.dart';
import '../providers/musee_provider.dart';
import '../providers/monument_provider.dart';
import '../providers/festival_provider.dart';
import '../providers/artisanat_provider.dart';
import 'artisanat_details_screen.dart';
import 'musee_details_screen.dart';

enum CulturesCategory { none, musee, monument, festival, artisanat }

class CulturesScreen extends StatefulWidget {
  final CulturesCategory? initialCategory; // <-- add this
  const CulturesScreen({super.key, this.initialCategory});

  @override
  State<CulturesScreen> createState() => _CulturesScreenState();
}

class _CulturesScreenState extends State<CulturesScreen> {
  late CulturesCategory _selectedCategory;

  @override
  void initState() {
    super.initState();

    // Use the initialCategory if provided, otherwise default to none
    _selectedCategory = widget.initialCategory ?? CulturesCategory.none;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<MuseeProvider>(context, listen: false).fetchMusees();
      Provider.of<MonumentProvider>(context, listen: false).fetchMonuments();
      Provider.of<FestivalProvider>(context, listen: false).fetchFestivals();
      Provider.of<ArtisanatProvider>(context, listen: false).fetchArtisanats();
    });
  }



  @override
  Widget build(BuildContext context) {
    final menuItems = [
      {
        'title': 'Musées',
        'image': 'assets/images/card/musees.png',
        'color': AppColorstatic.primary,
        'category': CulturesCategory.musee,
      },
      {
        'title': 'Monuments',
        'image': 'assets/images/card/monument.png',
        'color': AppColorstatic.primary,
        'category': CulturesCategory.monument,
      },
      {
        'title': 'Festivals',
        'image': 'assets/images/card/festival.png',
        'color': AppColorstatic.secondary,
        'category': CulturesCategory.festival,
      },
      {
        'title': 'Artisanat',
        'image': 'assets/images/card/artisanat.png',
        'color': AppColorstatic.secondary,
        'category': CulturesCategory.artisanat,
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 12),
          child: ScreenTitle(
            title: _selectedCategory == CulturesCategory.none
                ? 'Culture'
                : menuItems
                .firstWhere((item) =>
            item['category'] == _selectedCategory)['title']
            as String,
            icon: _selectedCategory == CulturesCategory.none
                ? Icons.museum
                : _getCategoryIcon(_selectedCategory),
          ),
        ),
        Expanded(
          child: _selectedCategory == CulturesCategory.none
              ? _buildMenuGrid(menuItems)
              : _buildCategoryContent(_selectedCategory),
        ),
      ],
    );
  }

  IconData _getCategoryIcon(CulturesCategory category) {
    switch (category) {
      case CulturesCategory.musee:
        return Icons.museum;
      case CulturesCategory.monument:
        return Icons.account_balance;
      case CulturesCategory.festival:
        return Icons.celebration;
      case CulturesCategory.artisanat:
        return Icons.handshake;
      default:
        return Icons.museum;
    }
  }

  Widget _buildMenuGrid(List<Map<String, dynamic>> menuItems) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const BouncingScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 15,
          crossAxisSpacing: 8,
          childAspectRatio: 0.8,
        ),
        itemCount: menuItems.length,
        itemBuilder: (context, index) {
          final item = menuItems[index];
          return MenuCard(
            title: item['title'] as String,
            imagePath: item['image'] as String,
            backgroundColor: item['color'] as Color,
            onTap: () {
              setState(() {
                _selectedCategory = item['category'] as CulturesCategory;
              });
            },
          );
        },
      ),
    );
  }

  Widget _buildCategoryContent(CulturesCategory category) {
    switch (category) {

      case CulturesCategory.musee:
        return Consumer<MuseeProvider>(
          builder: (context, provider, child) {
            if (provider.isLoading && provider.musees.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }

            if (provider.musees.isEmpty) {
              return const Center(child: Text("Aucun festival disponible"));
            }

            final ScrollController _scrollController = ScrollController();

            _scrollController.addListener(() {
              if (_scrollController.position.pixels >=
                  _scrollController.position.maxScrollExtent - 200 &&
                  !provider.isLoading) {
                provider.fetchMusees();
              }
            });

            return ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(8.0),
              itemCount: provider.musees.length ,
              itemBuilder: (context, index) {
                if (index < provider.musees.length) {
                  final item = provider.musees[index];
                  return ItemTile(
                    title: item.name,
                    subtitle: item.situation.toString(),
                    imageUrl: item.cover,
                    description: item.description,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => MuseeDetailsScreen(museeSlug: item.slug),
                        ),
                      );
                    },
                  );
                } else {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16.0),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
              },
            );
          },
        );

      case CulturesCategory.monument:
        return Consumer<MonumentProvider>(
          builder: (context, provider, child) {
            if (provider.isLoading) return const Center(child: CircularProgressIndicator());
            if (provider.error != null) return Center(child: Text(provider.error!));
            if (provider.monuments.isEmpty) return const Center(child: Text("Aucun monument disponible"));
            return ListView.builder(
              padding: const EdgeInsets.all(8.0),
              itemCount: provider.monuments.length,
              itemBuilder: (context, index) {
                final item = provider.monuments[index];
                return ItemTile(
                  title: item.name,
                  subtitle: item.destination.name.toString(),
                  imageUrl: item.cover,
                  description: item.description,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => MonumentDetailsScreen(monumentSlug: item.slug),
                      ),
                    );
                  },
                );
              },
            );
          },
        );

      case CulturesCategory.festival:
        return Consumer<FestivalProvider>(
          builder: (context, provider, child) {
            if (provider.isLoading && provider.festivals.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }

            if (provider.festivals.isEmpty) {
              return const Center(child: Text("Aucun festival disponible"));
            }

            final ScrollController _scrollController = ScrollController();

            _scrollController.addListener(() {
              if (_scrollController.position.pixels >=
                  _scrollController.position.maxScrollExtent - 200 &&
                  provider.hasMore &&
                  !provider.isLoading) {
                provider.fetchFestivals();
              }
            });

            return ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(8.0),
              itemCount: provider.festivals.length + (provider.hasMore ? 1 : 0),
              itemBuilder: (context, index) {
                if (index < provider.festivals.length) {
                  final item = provider.festivals[index];
                  return ItemTile(
                    title: item.name,
                    subtitle: item.destination!.name,
                    imageUrl: item.cover,
                    description: item.description,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => FestivalDetailsScreen(festivalSlug: item.slug),
                        ),
                      );
                    },
                  );
                } else {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16.0),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
              },
            );
          },
        );



      case CulturesCategory.artisanat:
        return Consumer<ArtisanatProvider>(
          builder: (context, provider, child) {
            if (provider.isLoading) return const Center(child: CircularProgressIndicator());
            if (provider.error != null) return Center(child: Text(provider.error!));
            if (provider.artisanats.isEmpty) return const Center(child: Text("Aucun artisanat disponible"));
            return ListView.builder(
              padding: const EdgeInsets.all(8.0),
              itemCount: provider.artisanats.length,
              itemBuilder: (context, index) {
                final item = provider.artisanats[index];
                return ItemTile(
                  title: item.name,
                  subtitle: "",
                  imageUrl: item.cover,
                  description: item.description,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ArtisanatDetailsScreen(artisanatSlug: item.slug),
                      ),
                    );
                  },
                );
              },
            );
          },
        );

      default:
        return const SizedBox.shrink();
    }
  }
}
