import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:tunisiagotravel/models/state.dart';
import 'package:tunisiagotravel/providers/state_provider.dart';
import 'package:tunisiagotravel/screens/StateScreenDetails.dart';
import 'package:tunisiagotravel/theme/color.dart';

/// A widget that displays information about a selected city with an animated image slider.
class CityInfoDisplay extends StatefulWidget {
  final String? selectedCityId;
  final VoidCallback? onClose;

  const CityInfoDisplay({
    super.key,
    this.selectedCityId,
    this.onClose,
  });

  @override
  State<CityInfoDisplay> createState() => _CityInfoDisplayState();
}

class _CityInfoDisplayState extends State<CityInfoDisplay>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _slideAnimation;
  late Animation<double> _fadeAnimation;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _slideAnimation = Tween<double>(begin: 0.5, end: 0.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.3, 0.5, curve: Curves.easeOut),
      ),
    );

    if (widget.selectedCityId != null) {
      _animationController.forward();
    }
  }

  @override
  void didUpdateWidget(CityInfoDisplay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedCityId != oldWidget.selectedCityId) {
      if (widget.selectedCityId != null) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.selectedCityId == null) {
      return const SizedBox.shrink();
    }

    return Consumer<StateProvider>(
      builder: (context, provider, child) {
        final stateApp = provider.getStateByName(widget.selectedCityId!);
        if (stateApp == null) {
          return _buildErrorState();
        }
        return AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(0, 140 * _slideAnimation.value),
              child: Opacity(
                opacity: _fadeAnimation.value,
                child: _buildCityInfo(stateApp),
              ),
            );
          },
        );
      },
    );
  }

  /// Builds an error state widget when the city is not found.
  Widget _buildErrorState() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: Colors.red.shade600),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              tr('cityNotFound'),
              style: TextStyle(color: Colors.red.shade800, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the main city info container with header, image slider, and description.
  Widget _buildCityInfo(StateApp stateApp) {
    final locale = context.locale;
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(stateApp, locale),
          _buildImageSlider(stateApp),
          _buildDescription(stateApp, locale),
        ],
      ),
    );
  }

  /// Builds the header with city name and close button.
  Widget _buildHeader(StateApp stateApp, Locale locale) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 1, horizontal: 16),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFFB9504), Color(0xFFFFCB66)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Row(
        children: [
          const Icon(Icons.location_city, color: Colors.white, size: 24),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              stateApp.getName(locale),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          if (widget.onClose != null)
            IconButton(
              onPressed: widget.onClose,
              icon: const Icon(Icons.close, color: Colors.white),
            ),
        ],
      ),
    );
  }

  /// Builds the image slider or a placeholder if no images are available.
  Widget _buildImageSlider(StateApp stateApp) {
    if (stateApp.images.isEmpty) {
      return _buildNoImagesPlaceholder();
    }
    return _ImageSlider(
      images: stateApp.images.take(4).toList(),
      selectedCityId: widget.selectedCityId!,
    );
  }

  /// Builds a placeholder for when no images are available.
  Widget _buildNoImagesPlaceholder() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Container(
        height: 100,
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.photo_library_outlined, size: 40, color: Colors.grey.shade400),
              const SizedBox(height: 8),
              Text(
                tr('noImagesAvailable'),
                style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds the description section with expandable text.
  Widget _buildDescription(StateApp stateApp, Locale locale) {
    final description = stateApp.getDescription(locale);
    if (description == null || description.isEmpty) {
      return _buildNoDescriptionPlaceholder();
    }

    const previewLength = 214;
    final previewText =
    description.length > previewLength ? '${description.substring(0, previewLength)}...' : description;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            tr('description'),
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2C3E50),
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Html(
                  data: _isExpanded ? description : previewText,
                  style: {
                    'body': Style(fontSize: FontSize(16), color: const Color(0xFF34495E)),
                  },
                ),
                if (description.length > previewLength)
                  GestureDetector(
                    onTap: () => setState(() => _isExpanded = !_isExpanded),
                    child: Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        _isExpanded ? tr('see_less') : tr('see_more'),
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Builds a placeholder for when no description is available.
  Widget _buildNoDescriptionPlaceholder() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          children: [
            Icon(Icons.description_outlined, color: Colors.grey.shade400),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                tr('noDescriptionAvailable'),
                style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A widget that displays an auto-scrolling image slider with fade transitions and navigation dots.
class _ImageSlider extends StatefulWidget {
  final List<String> images;
  final String selectedCityId;

  const _ImageSlider({
    required this.images,
    required this.selectedCityId,
  });

  @override
  State<_ImageSlider> createState() => _ImageSliderState();
}

class _ImageSliderState extends State<_ImageSlider>
    with SingleTickerProviderStateMixin {
  late AnimationController _fadeController;
  late Timer _autoScrollTimer;
  int _currentPage = 0;
  double _dragStartX = 0.0;
  bool _isDragging = false;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _startAutoScroll();
  }

  /// Starts the auto-scroll timer if there are multiple images.
  void _startAutoScroll() {
    if (widget.images.length > 1) {
      _autoScrollTimer = Timer.periodic(const Duration(seconds: 3), (_) {
        if (!_isDragging) {
          _nextPage();
        }
      });
    }
  }

  /// Advances to the next page with a fade animation.
  void _nextPage({bool animate = true}) {
    if (!mounted) return;
    setState(() {
      _currentPage = (_currentPage + 1) % widget.images.length;
    });
    if (animate) {
      _fadeController.forward().then((_) => _fadeController.reverse());
    }
  }

  /// Goes to the previous page with a fade animation.
  void _previousPage({bool animate = true}) {
    if (!mounted) return;
    setState(() {
      _currentPage =
          (_currentPage - 1 + widget.images.length) % widget.images.length;
    });
    if (animate) {
      _fadeController.forward().then((_) => _fadeController.reverse());
    }
  }

  /// Handles horizontal drag for manual navigation.
  void _onHorizontalDragStart(DragStartDetails details) {
    _isDragging = true;
    _autoScrollTimer.cancel();
    _dragStartX = details.globalPosition.dx;
  }

  void _onHorizontalDragUpdate(DragUpdateDetails details) {
    // Optional: Add drag preview if needed
  }

  void _onHorizontalDragEnd(DragEndDetails details) {
    _isDragging = false;
    final dx = details.primaryVelocity ?? 0;
    final distance = details.globalPosition.dx - _dragStartX;
    if (dx > 0 || distance > 50) {
      _previousPage();
    } else if (dx < 0 || distance < -50) {
      _nextPage();
    }
    _startAutoScroll();
  }

  @override
  void dispose() {
    _autoScrollTimer.cancel();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                tr('media'),
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2C3E50),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          StateScreenDetails(
                            selectedCityId: widget.selectedCityId,
                            locationType: LocationType.state,
                          ),
                    ),
                  );
                },
                style: TextButton.styleFrom(
                  backgroundColor: AppColorstatic.primary2,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                ),
                child: Text(
                  tr('explore'),
                  style: const TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          SizedBox(
            height: 200,
            child: GestureDetector(
              onHorizontalDragStart: _onHorizontalDragStart,
              onHorizontalDragUpdate: _onHorizontalDragUpdate,
              onHorizontalDragEnd: _onHorizontalDragEnd,
              onTap: (){},
              child: Stack(
                fit: StackFit.expand,
                children: List.generate(widget.images.length, (index) {
                  final isCurrent = index == _currentPage;
                  return Positioned.fill(
                    child: AnimatedOpacity(
                      opacity: isCurrent ? 1.0 : 0.0,
                      duration: const Duration(milliseconds: 500),
                      child: IgnorePointer(
                        ignoring: !isCurrent,
                        child: _buildGalleryImage(
                            widget.images[index], index, isCurrent),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(widget.images.length, (index) {
                return GestureDetector(
                  onTap: () => setState(() => _currentPage = index),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: _currentPage == index ? 12 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: _currentPage == index
                          ? const Color(0xFFFB9504)
                          : Colors.grey.shade400,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  /// Builds an individual gallery image with Hero animation for fullscreen view.
  Widget _buildGalleryImage(String imageUrl, int index, bool isCurrent) {
    return Hero(
      tag: 'gallery_image_$index',
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: CachedNetworkImage(
            imageUrl: imageUrl,
            fit: BoxFit.cover,
            placeholder: (context, url) =>
                Container(
                  color: Colors.grey.shade200,
                  child: const Center(child: CircularProgressIndicator()),
                ),
            errorWidget: (context, url, error) =>
                Container(
                  color: Colors.grey.shade200,
                  child: Icon(
                      Icons.image_not_supported, color: Colors.grey.shade400,
                      size: 40),
                ),
          ),
        ),
      ),
    );
  }
}