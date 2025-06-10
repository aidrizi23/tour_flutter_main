import 'package:flutter/material.dart';
import '../../../models/car_models.dart';

class CarImageGallery extends StatelessWidget {
  final List<CarImage> images;
  final PageController controller;
  final int currentIndex;
  final Function(int) onPageChanged;

  const CarImageGallery({
    super.key,
    required this.images,
    required this.controller,
    required this.currentIndex,
    required this.onPageChanged,
  });

  @override
  Widget build(BuildContext context) {
    final displayImages = images.isEmpty 
        ? [CarImage(id: 0, imageUrl: '', displayOrder: 0)]
        : images;

    return Stack(
      children: [
        PageView.builder(
          controller: controller,
          onPageChanged: onPageChanged,
          itemCount: displayImages.length,
          itemBuilder: (context, index) {
            final image = displayImages[index];
            return Container(
              decoration: BoxDecoration(
                image: image.imageUrl.isNotEmpty
                    ? DecorationImage(
                        image: NetworkImage(image.imageUrl),
                        fit: BoxFit.cover,
                        onError: (error, stackTrace) => _buildImagePlaceholder(context),
                      )
                    : null,
              ),
              child: image.imageUrl.isEmpty ? _buildImagePlaceholder(context) : null,
            );
          },
        ),

        // Image indicators
        if (displayImages.length > 1)
          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(
                    displayImages.length,
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

        // Image counter
        if (displayImages.length > 1)
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
                '${currentIndex + 1}/${displayImages.length}',
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

  Widget _buildImagePlaceholder(BuildContext context) {
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