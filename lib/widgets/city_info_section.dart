import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:tunisiagotravel/models/state.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:tunisiagotravel/providers/state_provider.dart';
import 'package:tunisiagotravel/screens/StateScreenDetails.dart';
import 'package:tunisiagotravel/theme/color.dart';

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

    _slideAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.3, 1.0, curve: Curves.easeOut),
    ));

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
              style: TextStyle(
                color: Colors.red.shade800,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCityInfo(StateApp stateApp) {
    final locale = context.locale;
    final screenWidth = MediaQuery.of(context).size.width;

    return Container(
      margin: const EdgeInsets.all(16),
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
          _buildImageGallery(stateApp, screenWidth),
          _buildDescription(stateApp, locale),
        ],
      ),
    );
  }

  Widget _buildHeader(StateApp stateApp, Locale locale) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 1.0, horizontal: 12.0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFFB9504), Color(0xFFFFCB66)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.location_city,
            color: Colors.white,
            size: 24,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  stateApp.getName(locale),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          if (widget.onClose != null)
            IconButton(
              onPressed: widget.onClose,
              icon: const Icon(Icons.close),
              style: IconButton.styleFrom(
                foregroundColor: Colors.white,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildImageGallery(StateApp stateApp, double screenWidth) {
    if (stateApp.images.isEmpty) {
      return _buildNoImagesPlaceholder();
    }

    final displayImages = stateApp.images.take(4).toList();
    final isTablet = screenWidth > 600;

    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                tr('images'),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2C3E50),
                ),
              ),
              TextButton(
                onPressed: () {
                  // Close the dialog
                  Navigator.pop(context);
                  // Navigate to StateScreenDetails
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => StateScreenDetails(
                        selectedCityId: widget.selectedCityId!,
                        locationType: LocationType.state, // Specify as state since CityInfoDisplay uses StateProvider
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
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildResponsiveGallery(displayImages, isTablet),
        ],
      ),
    );
  }

  Widget _buildResponsiveGallery(List<String> images, bool isTablet) {
    if (isTablet) {
      return _buildTabletGallery(images);
    } else {
      return _buildMobileGallery(images);
    }
  }

  Widget _buildTabletGallery(List<String> images) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.5,
      ),
      itemCount: images.length,
      itemBuilder: (context, index) {
        return _buildGalleryImage(images[index], index);
      },
    );
  }

  Widget _buildMobileGallery(List<String> images) {
    return SizedBox(
      height: 120,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: images.length,
        itemBuilder: (context, index) {
          return Container(
            width: 130,
            margin: EdgeInsets.only(
              right: index < images.length - 1 ? 12 : 0,
            ),
            child: _buildGalleryImage(images[index], index),
          );
        },
      ),
    );
  }

  Widget _buildGalleryImage(String imageUrl, int index) {
    return Hero(
      tag: 'gallery_image_$index',
      child: GestureDetector(
        onTap: () => _showImageFullscreen(imageUrl, index),
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
              placeholder: (context, url) => Container(
                color: Colors.grey.shade200,
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              ),
              errorWidget: (context, url, error) => Container(
                color: Colors.grey.shade200,
                child: Icon(
                  Icons.image_not_supported,
                  color: Colors.grey.shade400,
                  size: 40,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNoImagesPlaceholder() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Container(
        height: 120,
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.photo_library_outlined,
                size: 40,
                color: Colors.grey.shade400,
              ),
              const SizedBox(height: 8),
              Text(
                tr('noImagesAvailable'),
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDescription(StateApp stateApp, Locale locale) {
    final description = stateApp.getDescription(locale);

    if (description == null || description.isEmpty) {
      return _buildNoDescriptionPlaceholder();
    }

    const int previewLength = 214;
    final String previewText = description.length > previewLength
        ? '${description.substring(0, previewLength)}...'
        : description;

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
                    'body': Style(
                      fontSize: FontSize(16),
                      color: const Color(0xFF34495E),
                    ),
                  },
                ),
                if (description.length > previewLength)
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _isExpanded = !_isExpanded;
                      });
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(top: 8.0),
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
            Icon(
              Icons.description_outlined,
              color: Colors.grey.shade400,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                tr('noDescriptionAvailable'),
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showImageFullscreen(String imageUrl, int index) {
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        pageBuilder: (context, animation, secondaryAnimation) {
          return FadeTransition(
            opacity: animation,
            child: ImageFullscreenViewer(
              imageUrl: imageUrl,
              heroTag: 'gallery_image_$index',
            ),
          );
        },
      ),
    );
  }
}

class ImageFullscreenViewer extends StatelessWidget {
  final String imageUrl;
  final String heroTag;

  const ImageFullscreenViewer({
    super.key,
    required this.imageUrl,
    required this.heroTag,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black87,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Center(
        child: Hero(
          tag: heroTag,
          child: InteractiveViewer(
            child: CachedNetworkImage(
              imageUrl: imageUrl,
              fit: BoxFit.contain,
              placeholder: (context, url) => const Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
              errorWidget: (context, url, error) => const Icon(
                Icons.error,
                color: Colors.white,
                size: 60,
              ),
            ),
          ),
        ),
      ),
    );
  }
}