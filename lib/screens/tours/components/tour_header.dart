import 'package:flutter/material.dart';
import '../../../models/tour_models.dart';

class TourHeader extends StatelessWidget {
  final Tour tour;
  const TourHeader({super.key, required this.tour});

  @override
  Widget build(BuildContext context) {
    final images = tour.images.isNotEmpty
        ? tour.images
        : [TourImage(id: 0, imageUrl: '', displayOrder: 0)];
    return SliverAppBar(
      expandedHeight: 300,
      pinned: true,
      stretch: true,
      flexibleSpace: FlexibleSpaceBar(
        background: PageView.builder(
          itemCount: images.length,
          itemBuilder: (context, index) {
            final img = images[index];
            if (img.imageUrl.isEmpty) {
              return Container(color: Colors.grey[300]);
            }
            return Image.network(img.imageUrl, fit: BoxFit.cover);
          },
        ),
      ),
    );
  }
}
