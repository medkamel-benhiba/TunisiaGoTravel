import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
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
  final CulturesCategory? initialCategory;
  const CulturesScreen({super.key, this.initialCategory});

  @override
  State<CulturesScreen> createState() => _CulturesScreenState();
}

class _CulturesScreenState extends State<CulturesScreen> {
  late CulturesCategory _selectedCategory;

  @override
  void initState() {
    super.initState();

    _selectedCategory = widget.initialCategory ?? CulturesCategory.none;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<MuseeProvider>(context, listen: false).fetchMusees();
      Provider.of<MonumentProvider>(context, listen: false).fetchMonuments();
      Provider.of<FestivalProvider>(context, listen: false).fetchFestivals();
      Provider.of<ArtisanatProvider>(context, listen: false).fetchArtisanats();
    });
  }

  int _getCrossAxisCount(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth < 600) {
      return 2; // Mobile
    } else if (screenWidth < 900) {
      return 2; // Small tablet
    } else if (screenWidth < 1200) {
      return 3; // Large tablet
    } else {
      return 4; // Desktop
    }
  }

  @override
  Widget build(BuildContext context) {
    final locale = context.locale;
    final menuItems = [
      {
        'title': tr('museums'),
        'image': 'assets/images/card/musees.png',
        'color': AppColorstatic.primary,
        'category': CulturesCategory.musee,
      },
      {
        'title': tr('monuments'),
        'image': 'assets/images/card/monument.png',
        'color': AppColorstatic.primary,
        'category': CulturesCategory.monument,
      },
      {
        'title': tr('festivals'),
        'image': 'assets/images/card/festival.png',
        'color': AppColorstatic.secondary,
        'category': CulturesCategory.festival,
      },
      {
        'title': tr('crafts'),
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
                ? tr('culture')
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
              return Center(child: Text(tr("no_museum_available")));
            }

            final ScrollController scrollController = ScrollController();
            scrollController.addListener(() {
              if (scrollController.position.pixels >=
                  scrollController.position.maxScrollExtent - 200 &&
                  !provider.isLoading) {
                provider.fetchMusees();
              }
            });

            return GridView.builder(
              controller: scrollController,
              padding: const EdgeInsets.all(8.0),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: _getCrossAxisCount(context),
                mainAxisSpacing: 0,
                crossAxisSpacing: 12,
                childAspectRatio: 0.8,
              ),
              itemCount: provider.musees.length,
              itemBuilder: (context, index) {
                final item = provider.musees[index];
                return ItemTile(
                  title: item.getName(Localizations.localeOf(context)),
                  subtitle: item.getSituation(Localizations.localeOf(context)).toString(),
                  imageUrl: item.cover,
                  description: item.getDescription(Localizations.localeOf(context)),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => MuseeDetailsScreen(museeSlug: item.slug),
                      ),
                    );
                  },
                );
              },
            );
          },
        );

      case CulturesCategory.monument:
        return Consumer<MonumentProvider>(
          builder: (context, provider, child) {
            if (provider.monuments.isEmpty) {
              return Center(child: Text(tr("no_monument_available")));
            }

            return GridView.builder(
              padding: const EdgeInsets.all(8.0),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: _getCrossAxisCount(context),
                mainAxisSpacing: 0,
                crossAxisSpacing: 12,
                childAspectRatio: 0.8,
              ),
              itemCount: provider.monuments.length,
              itemBuilder: (context, index) {
                final item = provider.monuments[index];
                return ItemTile(
                  title: item.getName(Localizations.localeOf(context)),
                  subtitle: item.destination.getName(Localizations.localeOf(context)),
                  imageUrl: item.images.first,
                  description: item.getDescription(Localizations.localeOf(context)),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            MonumentDetailsScreen(monumentSlug: item.slug),
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
              return Center(child: Text(tr("no_festival_available")));
            }

            final ScrollController scrollController = ScrollController();
            scrollController.addListener(() {
              if (scrollController.position.pixels >=
                  scrollController.position.maxScrollExtent - 200 &&
                  provider.hasMore &&
                  !provider.isLoading) {
                provider.fetchFestivals();
              }
            });

            return GridView.builder(
              controller: scrollController,
              padding: const EdgeInsets.all(8.0),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: _getCrossAxisCount(context),
                mainAxisSpacing: 0,
                crossAxisSpacing: 12,
                childAspectRatio: 0.8,
              ),
              itemCount: provider.festivals.length + (provider.hasMore ? 1 : 0),
              itemBuilder: (context, index) {
                if (index < provider.festivals.length) {
                  final item = provider.festivals[index];
                  return ItemTile(
                    title: item.getName(Localizations.localeOf(context)),
                    subtitle: item.getDestinationName(Localizations.localeOf(context)),
                    imageUrl: item.images.first ?? item.cover ?? "",
                    description: item.getDescription(Localizations.localeOf(context)),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              FestivalDetailsScreen(festivalSlug: item.slug),
                        ),
                      );
                    },
                  );
                } else {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }
              },
            );
          },
        );

      case CulturesCategory.artisanat:
        return Consumer<ArtisanatProvider>(
          builder: (context, provider, child) {
            if (provider.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (provider.error != null) {
              return Center(child: Text(provider.error!));
            }
            if (provider.artisanats.isEmpty) {
              return Center(child: Text(tr("no_craft_available")));
            }

            return GridView.builder(
              padding: const EdgeInsets.all(8.0),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: _getCrossAxisCount(context),
                mainAxisSpacing: 0,
                crossAxisSpacing: 12,
                childAspectRatio: 0.8,
              ),
              itemCount: provider.artisanats.length,
              itemBuilder: (context, index) {
                final item = provider.artisanats[index];
                return ItemTile(
                  title: item.getName(Localizations.localeOf(context)),
                  subtitle: "",
                  descriptionHtml: item.getDescription(Localizations.localeOf(context)),
                  imageUrl: item.cover,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            ArtisanatDetailsScreen(artisanatSlug: item.slug),
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