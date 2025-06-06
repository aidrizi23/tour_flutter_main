import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/tour_models.dart';
import '../screens/tours/tour_details_screen.dart';

class ResponsiveTourCard extends StatefulWidget {
  final Tour tour;
  final bool isDesktop;
  final bool isTablet;
  final VoidCallback? onFavoriteToggle;
  final bool isFavorite;

  const ResponsiveTourCard({
    super.key,
    required this.tour,
    this.isDesktop = false,
    this.isTablet = false,
    this.onFavoriteToggle,
    this.isFavorite = false,
  });

  @override
  State<ResponsiveTourCard> createState() => _ResponsiveTourCardState();
}

class _ResponsiveTourCardState extends State<ResponsiveTourCard>
    with SingleTickerProviderStateMixin {
  bool _isHovered = false;
  late AnimationController _hoverController;
  late Animation<double> _elevationAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _hoverController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _elevationAnimation = Tween<double>(begin: 2.0, end: 12.0).animate(
      CurvedAnimation(parent: _hoverController, curve: Curves.easeOutCubic),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.02).animate(
      CurvedAnimation(parent: _hoverController, curve: Curves.easeOutCubic),
    );
  }

  @override
  void dispose() {
    _hoverController.dispose();
    super.dispose();
  }

  void _onHover(bool isHovered) {
    if (mounted) {
      setState(() => _isHovered = isHovered);
      if (isHovered) {
        _hoverController.forward();
      } else {
        _hoverController.reverse();
      }
    }
  }

  void _navigateToDetails() {
    HapticFeedback.lightImpact();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => TourDetailsScreen(tourId: widget.tour.id),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _hoverController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: MouseRegion(
            onEnter: (_) => _onHover(true),
            onExit: (_) => _onHover(false),
            child: Card(
              elevation: _elevationAnimation.value,
              shadowColor: Colors.black.withValues(alpha: 0.1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              clipBehavior: Clip.antiAlias,
              child: Semantics(
                label:
                    'Tour: ${widget.tour.name}, Location: ${widget.tour.location}, Price: ${widget.tour.displayPrice}',
                button: true,
                child: InkWell(
                  onTap: _navigateToDetails,
                  borderRadius: BorderRadius.circular(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildImageSection(),
                      Expanded(child: _buildContentSection()),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildImageSection() {
    final colorScheme = Theme.of(context).colorScheme;

    return Stack(
      children: [
        AspectRatio(
          aspectRatio: 16 / 10,
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainer,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child:
                widget.tour.mainImageUrl != null &&
                        widget.tour.mainImageUrl!.isNotEmpty
                    ? ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(12),
                        topRight: Radius.circular(12),
                      ),
                      child: Image.network(
                        widget.tour.mainImageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder:
                            (context, error, stackTrace) =>
                                _buildImagePlaceholder(),
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return _buildShimmerPlaceholder();
                        },
                      ),
                    )
                    : _buildImagePlaceholder(),
          ),
        ),

        // Favorite Button
        Positioned(
          top: 12,
          right: 12,
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(
                context,
              ).colorScheme.surface.withValues(alpha: 0.9),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Semantics(
              label:
                  widget.isFavorite
                      ? 'Remove from favorites'
                      : 'Add to favorites',
              button: true,
              child: IconButton(
                onPressed: () {
                  HapticFeedback.lightImpact();
                  widget.onFavoriteToggle?.call();
                },
                icon: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: Icon(
                    widget.isFavorite ? Icons.favorite : Icons.favorite_border,
                    key: ValueKey(widget.isFavorite),
                    color:
                        widget.isFavorite
                            ? Colors.red.shade600
                            : Theme.of(
                              context,
                            ).colorScheme.onSurface.withValues(alpha: 0.6),
                    size: 20,
                  ),
                ),
                constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                padding: const EdgeInsets.all(8),
                tooltip:
                    widget.isFavorite
                        ? 'Remove from favorites'
                        : 'Add to favorites',
              ),
            ),
          ),
        ),

        // Discount Badge
        if (widget.tour.hasDiscount)
          Positioned(
            top: 12,
            left: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.red.shade600, Colors.red.shade700],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.red.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Text(
                '${widget.tour.discountPercentage}% OFF',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildShimmerPlaceholder() {
    final colorScheme = Theme.of(context).colorScheme;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 1000),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colorScheme.surfaceContainerLow,
            colorScheme.surfaceContainer,
            colorScheme.surfaceContainerLow,
          ],
          stops: const [0.0, 0.5, 1.0],
        ),
      ),
      child: Center(
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: colorScheme.primary,
          ),
        ),
      ),
    );
  }

  Widget _buildImagePlaceholder() {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colorScheme.primary.withValues(alpha: 0.1),
            colorScheme.secondary.withValues(alpha: 0.1),
          ],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.landscape_outlined,
              size: 32,
              color: colorScheme.outline,
            ),
            const SizedBox(height: 4),
            Text(
              'No Image',
              style: TextStyle(color: colorScheme.outline, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContentSection() {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Category
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              widget.tour.category,
              style: textTheme.labelSmall?.copyWith(
                color: colorScheme.onPrimaryContainer,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Title
          Text(
            widget.tour.name,
            style: textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              height: 1.2,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),

          const SizedBox(height: 8),

          // Location
          Row(
            children: [
              Icon(
                Icons.location_on_outlined,
                size: 16,
                color: colorScheme.primary,
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  widget.tour.location,
                  style: textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Features
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              _buildFeatureChip(
                Icons.schedule_outlined,
                widget.tour.durationText,
                colorScheme.surfaceContainer,
                colorScheme.onSurface,
              ),
              _buildFeatureChip(
                widget.tour.activityIcon,
                widget.tour.activityType,
                colorScheme.secondaryContainer.withValues(alpha: 0.5),
                colorScheme.onSecondaryContainer,
              ),
              _buildFeatureChip(
                Icons.trending_up_outlined,
                widget.tour.difficultyLevel,
                widget.tour.difficultyColor.withValues(alpha: 0.2),
                widget.tour.difficultyColor,
              ),
            ],
          ),

          const Spacer(),

          // Rating and Price
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Rating
              if (widget.tour.averageRating != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.amber.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 14),
                      const SizedBox(width: 4),
                      Text(
                        widget.tour.averageRating!.toStringAsFixed(1),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        ' (${widget.tour.reviewCount})',
                        style: TextStyle(
                          fontSize: 11,
                          color: colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
                )
              else
                const SizedBox.shrink(),

              // Price
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (widget.tour.hasDiscount)
                    Text(
                      widget.tour.originalPrice,
                      style: textTheme.bodySmall?.copyWith(
                        decoration: TextDecoration.lineThrough,
                        color: colorScheme.onSurface.withValues(alpha: 0.5),
                      ),
                    ),
                  Row(
                    children: [
                      Text(
                        widget.tour.displayPrice,
                        style: textTheme.titleMedium?.copyWith(
                          color: colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '/person',
                        style: textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Book Now Button
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _navigateToDetails,
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.visibility_rounded, size: 18),
                  const SizedBox(width: 8),
                  const Text(
                    'View Details',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureChip(
    IconData icon,
    String label,
    Color backgroundColor,
    Color textColor,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: textColor),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}
