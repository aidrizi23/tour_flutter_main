import 'package:flutter/material.dart';
import '../../../models/car_models.dart';

class CarImageGallery extends StatelessWidget {
  final List<CarImage> images;
  final PageController controller;
  final int currentIndex;
  final ValueChanged<int> onPageChanged;

  const CarImageGallery({
    super.key,
    required this.images,
    required this.controller,
    required this.currentIndex,
    required this.onPageChanged,
  });

  @override
  Widget build(BuildContext context) {
    final imgs = images.isEmpty
        ? [CarImage(id: 0, imageUrl: '', displayOrder: 0)]
        : images;

    return Stack(
      children: [
        PageView.builder(
          controller: controller,
          onPageChanged: onPageChanged,
          itemCount: imgs.length,
          itemBuilder: (context, index) {
            final image = imgs[index];
            return Container(
              decoration: BoxDecoration(
                image: image.imageUrl.isNotEmpty
                    ? DecorationImage(
                        image: NetworkImage(image.imageUrl),
                        fit: BoxFit.cover,
                        onError: (error, stackTrace) =>
                            _buildPlaceholder(context),
                      )
                    : null,
              ),
              child: image.imageUrl.isEmpty ? _buildPlaceholder(context) : null,
            );
          },
        ),
        if (imgs.length > 1)
          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(
                    imgs.length,
                    (index) => AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      width: currentIndex == index ? 24 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                        color: currentIndex == index
                            ? Colors.white
                            : Colors.white.withOpacity(0.5),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        if (imgs.length > 1)
          Positioned(
            top: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                '${currentIndex + 1}/${imgs.length}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildPlaceholder(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colorScheme.primary.withOpacity(0.3),
            colorScheme.secondary.withOpacity(0.3),
          ],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.directions_car,
              size: 80,
              color: colorScheme.onSurface.withOpacity(0.5),
            ),
            const SizedBox(height: 8),
            Text(
              'No Image Available',
              style: TextStyle(
                color: colorScheme.onSurface.withOpacity(0.5),
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
