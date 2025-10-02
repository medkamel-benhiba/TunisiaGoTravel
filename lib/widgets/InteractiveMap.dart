import 'dart:ui' as ui;
import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_drawing/path_drawing.dart';
import 'package:provider/provider.dart';
import 'package:tunisiagotravel/providers/destination_provider.dart';
import 'package:tunisiagotravel/theme/color.dart';
import 'package:xml/xml.dart';
import 'package:tunisiagotravel/widgets/city_info_section.dart';

class SimplifiedInteractiveMapDialog extends StatefulWidget {
  final Function(String) onCitySelected;

  const SimplifiedInteractiveMapDialog({super.key, required this.onCitySelected});

  @override
  State<SimplifiedInteractiveMapDialog> createState() =>
      _SimplifiedInteractiveMapDialogState();
}

class _SimplifiedInteractiveMapDialogState
    extends State<SimplifiedInteractiveMapDialog>
    with SingleTickerProviderStateMixin {
  String? _selectedCity;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  final GlobalKey<_ResponsiveInteractiveMapState> _mapKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            constraints: BoxConstraints(
              maxHeight: screenSize.height * 0.85,
              maxWidth: screenSize.width * 0.95,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  spreadRadius: 5,
                  blurRadius: 15,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF11A2DC), Color(0xFF2B5CA1)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.map, color: Colors.white, size: 24),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              tr('interactive_map'),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (_selectedCity != null)
                              Consumer<DestinationProvider>(
                                builder: (context, provider, child) {
                                  final destination = provider.getDestinationByName(_selectedCity!);
                                  final localizedCityName = destination?.getName(context.locale) ?? _selectedCity!;

                                  return Text(
                                    tr('selected_city', args: [localizedCityName]),
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.9),
                                      fontSize: 14,
                                    ),
                                  );
                                },
                              )
                            else
                              Text(
                                tr('select_city'),
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.8),
                                  fontSize: 14,
                                ),
                              ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.close, color: Colors.white),
                        iconSize: 28,
                      ),
                    ],
                  ),
                ),

                // Map
                Flexible(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    height: screenSize.height * 0.5,
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        return Center(
                          child: AspectRatio(
                            aspectRatio: 0.5,
                            child: Directionality(
                              textDirection: ui.TextDirection.ltr,
                              child: Container(
                                width: double.infinity,
                                child: ResponsiveInteractiveMap(
                                  key: _mapKey,
                                  onRegionTap: (region) {
                                    setState(() {
                                      _selectedCity = region.id;
                                    });
                                  },
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),

                // City Info Section
                if (_selectedCity != null)
                  Flexible(
                    child: SingleChildScrollView(
                      child: CityInfoDisplay(
                        selectedCityId: _selectedCity,
                        onClose: () {
                          setState(() {
                            _selectedCity = null;
                          });
                          _mapKey.currentState?.clearSelection();
                        },
                      ),
                    ),
                  ),

                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(20),
                      bottomRight: Radius.circular(20),
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

class ResponsiveInteractiveMap extends StatefulWidget {
  final Function(Region) onRegionTap;

  const ResponsiveInteractiveMap({super.key, required this.onRegionTap});

  @override
  State<ResponsiveInteractiveMap> createState() => _ResponsiveInteractiveMapState();
}

class _ResponsiveInteractiveMapState extends State<ResponsiveInteractiveMap> {
  List<Region> regions = [];
  Region? selectedRegion;
  double? mapWidth;
  double? mapHeight;

  @override
  void initState() {
    super.initState();
    loadRegions().then((data) {
      regions = data;
      setState(() {});
    });
  }

  Future<List<Region>> loadRegions() async {
    final content = await rootBundle.loadString('assets/images/map.svg');
    final document = XmlDocument.parse(content);
    final paths = document.findAllElements('path');
    final regions = <Region>[];

    final svg = document.findAllElements('svg').first;
    final viewBoxStr = svg.getAttribute('viewBox');
    if (viewBoxStr != null) {
      final vb = viewBoxStr.split(RegExp(r'\s+'));
      mapWidth = double.parse(vb[2]);
      mapHeight = double.parse(vb[3]);
    } else {
      mapWidth = double.tryParse(svg.getAttribute('width') ?? '');
      mapHeight = double.tryParse(svg.getAttribute('height') ?? '');
    }

    for (var element in paths) {
      final partId = element.getAttribute('id') ?? "";
      if (partId.isEmpty) continue;
      final partPath = element.getAttribute('d') ?? "";
      regions.add(Region(id: partId, path: partPath));
    }
    return regions;
  }

  void clearSelection() {
    setState(() {
      selectedRegion = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (regions.isEmpty || mapWidth == null || mapHeight == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        return FittedBox(
          fit: BoxFit.contain,
          child: SizedBox(
            width: mapWidth,
            height: mapHeight,
            child: Stack(
              children: [
                for (final region in regions) ...[
                  _getRegionBorder(region),
                  _getRegionImage(
                    region,
                    selectedRegion?.id == region.id
                        ? AppColorstatic.primary2
                        : Colors.white70,
                  ),
                ]
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _getRegionImage(Region region, Color color) {
    return ClipPath(
      clipper: RegionClipper(svgPath: region.path),
      child: GestureDetector(
        onTap: () {
          setState(() {
            selectedRegion = region;
          });
          widget.onRegionTap(region);
        },
        child: Container(color: color),
      ),
    );
  }

  Widget _getRegionBorder(Region region) {
    return CustomPaint(
      painter: RegionBorderPainter(path: parseSvgPathData(region.path)),
    );
  }
}

class RegionClipper extends CustomClipper<Path> {
  final String svgPath;

  RegionClipper({required this.svgPath});

  @override
  Path getClip(Size size) {
    return parseSvgPathData(svgPath);
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

class RegionBorderPainter extends CustomPainter {
  final Path path;
  final Paint borderPaint;

  RegionBorderPainter({required this.path})
      : borderPaint = Paint()
    ..color = AppColorstatic.secondary
    ..strokeWidth = 1.7
    ..style = PaintingStyle.stroke;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawPath(path, borderPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class Region {
  final String id;
  final String path;

  Region({required this.id, required this.path});
}
