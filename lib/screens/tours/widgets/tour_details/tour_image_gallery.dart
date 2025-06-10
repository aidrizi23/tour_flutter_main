import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../models/tour_models.dart';

class TourImageGallery extends StatefulWidget {
  final Tour tour;
  final bool isDesktop;
  final bool isInteractive;
  final double? height;

  const TourImageGallery({
    super.key,
    required this.tour,
    this.isDesktop = false,
    this.isInteractive = true,
    this.height,
  });

  @override
  State<TourImageGallery> createState() => _TourImageGalleryState();
}

class _TourImageGalleryState extends State<TourImageGallery> {
  final PageController _pageController = PageController();
  int _currentImageIndex = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onImageTap() {
    if (!widget.isInteractive) return;
    HapticFeedback.lightImpact();
    _showFullScreenGallery();
  }

  void _showFullScreenGallery() {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, _) => _FullScreenGallery(
          tour: widget.tour,
          initialIndex: _currentImageIndex,
        ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 300),
        barrierColor: Colors.black87,
        opaque: false,
      ),
    );
  }

  bool _isValidUrl(String url) {
    if (url.isEmpty || url == 'string') return false;
    try {
      final uri = Uri.parse(url);
      return uri.hasScheme && (uri.scheme == 'http' || uri.scheme == 'https');
    } catch (e) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    // Validate and filter image URLs
    final validImages = <String>[];
    
    // Add images from tour.images if available
    if (widget.tour.images.isNotEmpty) {
      for (var img in widget.tour.images) {
        if (_isValidUrl(img.imageUrl)) {
          validImages.add(img.imageUrl);
        }
      }
    }
    
    // Add main image URL if valid and not already added
    if (widget.tour.mainImageUrl != null && 
        _isValidUrl(widget.tour.mainImageUrl!) && 
        !validImages.contains(widget.tour.mainImageUrl)) {
      validImages.add(widget.tour.mainImageUrl!);
    }

    if (validImages.isEmpty) {
      return _buildImagePlaceholder(colorScheme);
    }
    
    final images = validImages;

    return SizedBox(
      height: widget.height,
      child: Stack(
        children: [
          // Image PageView
          PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentImageIndex = index;
              });
            },
            itemCount: images.length,
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: _onImageTap,
                child: Hero(
                  tag: 'tour_image_${widget.tour.id}_$index',
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: widget.isDesktop
                          ? const BorderRadius.only(
                              topLeft: Radius.circular(24),
                              topRight: Radius.circular(24),
                            )
                          : null,
                    ),
                    child: ClipRRect(
                      borderRadius: widget.isDesktop
                          ? const BorderRadius.only(
                              topLeft: Radius.circular(24),
                              topRight: Radius.circular(24),
                            )
                          : BorderRadius.zero,
                      child: Image.network(
                        images[index],
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                        errorBuilder: (context, error, stackTrace) =>
                            _buildImagePlaceholder(colorScheme),
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Container(
                            color: colorScheme.surfaceContainer,
                            child: Center(
                              child: CircularProgressIndicator(
                                value: loadingProgress.expectedTotalBytes != null
                                    ? loadingProgress.cumulativeBytesLoaded /
                                        loadingProgress.expectedTotalBytes!
                                    : null,
                                color: colorScheme.primary,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              );
            },
          ),

          // Gradient overlay for better contrast
          if (!widget.isDesktop)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.3),
                    ],
                    stops: const [0.6, 1.0],
                  ),
                ),
              ),
            ),

          // Image indicators
          if (images.length > 1)
            Positioned(
              bottom: 16,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(
                      images.length,
                      (index) => Container(
                        margin: const EdgeInsets.symmetric(horizontal: 3),
                        width: _currentImageIndex == index ? 12 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: _currentImageIndex == index
                              ? Colors.white
                              : Colors.white54,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),

          // Navigation arrows for desktop
          if (widget.isDesktop && images.length > 1) ...[
            if (_currentImageIndex > 0)
              Positioned(
                left: 16,
                top: 0,
                bottom: 0,
                child: Center(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: IconButton(
                      onPressed: () {
                        _pageController.previousPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      },
                      icon: const Icon(
                        Icons.chevron_left_rounded,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            if (_currentImageIndex < images.length - 1)
              Positioned(
                right: 16,
                top: 0,
                bottom: 0,
                child: Center(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: IconButton(
                      onPressed: () {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      },
                      icon: const Icon(
                        Icons.chevron_right_rounded,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
          ],

          // Expand button
          if (widget.isInteractive)
            Positioned(
              top: 16,
              right: 16,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  onPressed: _showFullScreenGallery,
                  icon: const Icon(
                    Icons.fullscreen_rounded,
                    color: Colors.white,
                  ),
                  tooltip: 'View fullscreen',
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildImagePlaceholder(ColorScheme colorScheme) {
    return Container(
      color: colorScheme.surfaceContainer,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.image_not_supported_rounded,
              size: 64,
              color: colorScheme.outline,
            ),
            const SizedBox(height: 16),
            Text(
              'No image available',
              style: TextStyle(
                color: colorScheme.onSurface.withValues(alpha: 0.6),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FullScreenGallery extends StatefulWidget {
  final Tour tour;
  final int initialIndex;

  const _FullScreenGallery({
    required this.tour,
    required this.initialIndex,
  });

  @override
  State<_FullScreenGallery> createState() => _FullScreenGalleryState();
}

class _FullScreenGalleryState extends State<_FullScreenGallery> {
  late PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final images = widget.tour.images.isNotEmpty
        ? widget.tour.images.map((img) => img.imageUrl).toList()
        : [widget.tour.mainImageUrl].where((url) => url != null && url.isNotEmpty).cast<String>().toList();

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.close_rounded),
        ),
        title: Text(
          '${_currentIndex + 1} of ${images.length}',
          style: const TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: PageView.builder(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        itemCount: images.length,
        itemBuilder: (context, index) {
          return Hero(
            tag: 'tour_image_${widget.tour.id}_$index',
            child: InteractiveViewer(
              child: Center(
                child: Image.network(
                  images[index],
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) => const Center(
                    child: Icon(
                      Icons.error_outline_rounded,
                      color: Colors.white54,
                      size: 64,
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}