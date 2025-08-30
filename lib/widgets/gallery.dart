import 'package:flutter/material.dart';

/// Full-screen swipeable gallery
class FullScreenGallery extends StatefulWidget {
  final List<String> images;
  final int initialIndex;

  const FullScreenGallery({
    super.key,
    required this.images,
    this.initialIndex = 0,
  });

  @override
  State<FullScreenGallery> createState() => _FullScreenGalleryState();
}

class _FullScreenGalleryState extends State<FullScreenGallery> {
  late PageController _pageController;
  late int currentIndex;

  @override
  void initState() {
    super.initState();
    currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: currentIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text('${currentIndex + 1}/${widget.images.length}'),
      ),
      body: PageView.builder(
        controller: _pageController,
        itemCount: widget.images.length,
        onPageChanged: (index) => setState(() => currentIndex = index),
        itemBuilder: (context, index) {
          return InteractiveViewer(
            child: Center(
              child: Image.network(
                widget.images[index],
                fit: BoxFit.contain,
                loadingBuilder: (context, child, progress) {
                  if (progress == null) return child;
                  return const Center(child: CircularProgressIndicator());
                },
                errorBuilder: (context, error, stackTrace) => const Icon(
                  Icons.broken_image,
                  color: Colors.white,
                  size: 100,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Grid preview of images
class ImageGridPreview extends StatelessWidget {
  final List<String> images;
  final int maxVisible;

  const ImageGridPreview({
    super.key,
    required this.images,
    this.maxVisible = 4,
  });

  @override
  Widget build(BuildContext context) {
    int remaining = images.length - maxVisible;
    List<String> gridImages =
    remaining > 0 ? images.take(maxVisible).toList() : images;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 4,
        crossAxisSpacing: 4,
        childAspectRatio: 1,
      ),
      itemCount: gridImages.length,
      itemBuilder: (context, index) {
        bool showOverlay = remaining > 0 && index == maxVisible - 1;
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => FullScreenGallery(
                  images: images,
                  initialIndex: index,
                ),
              ),
            );
          },
          child: Stack(
            fit: StackFit.expand,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  gridImages[index],
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: Colors.grey[300],
                    child: const Icon(Icons.broken_image, size: 50),
                  ),
                ),
              ),
              if (showOverlay)
                Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      '+$remaining',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
