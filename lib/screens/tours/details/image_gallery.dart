import 'package:flutter/material.dart';
import '../../../models/tour_models.dart';

class TourImageGallery extends StatefulWidget {
  final List<TourImage> images;
  const TourImageGallery({super.key, required this.images});

  @override
  State<TourImageGallery> createState() => _TourImageGalleryState();
}

class _TourImageGalleryState extends State<TourImageGallery> {
  late final PageController _controller;
  int _index = 0;

  @override
  void initState() {
    super.initState();
    _controller = PageController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        SizedBox(
          height: 300,
          child: PageView.builder(
            controller: _controller,
            itemCount: widget.images.isEmpty ? 1 : widget.images.length,
            onPageChanged: (i) => setState(() => _index = i),
            itemBuilder: (context, i) {
              if (widget.images.isEmpty) {
                return Container(
                  color: colorScheme.surfaceVariant,
                  child: const Center(child: Icon(Icons.photo, size: 80)),
                );
              }
              final img = widget.images[i];
              return Image.network(img.imageUrl, fit: BoxFit.cover);
            },
          ),
        ),
        if (widget.images.length > 1)
          Positioned(
            bottom: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${_index + 1}/${widget.images.length}',
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ),
      ],
    );
  }
}
