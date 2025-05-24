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
  late Animation<double> _scaleAnimation;
  late Animation<double> _shadowAnimation;

  @override
  void initState() {
    super.initState();
    _hoverController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.02).animate(
      CurvedAnimation(parent: _hoverController, curve: Curves.easeInOut),
    );
    _shadowAnimation = Tween<double>(begin: 4.0, end: 12.0).animate(
      CurvedAnimation(parent: _hoverController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _hoverController.dispose();
    super.dispose();
  }

  void _onHover(bool isHovered) {
    setState(() => _isHovered = isHovered);
    if (isHovered) {
      _hoverController.forward();
    } else {
      _hoverController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isDesktop) {
      return _buildDesktopCard();
    } else if (widget.isTablet) {
      return _buildTabletCard();
    } else {
      return _buildMobileCard();
    }
  }

  Widget _buildDesktopCard() {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return AnimatedBuilder(
      animation: _hoverController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: MouseRegion(
            onEnter: (_) => _onHover(true),
            onExit: (_) => _onHover(false),
            child: Container(
              margin: const EdgeInsets.only(bottom: 24),
              child: Card(
                clipBehavior: Clip.antiAlias,
                elevation: _shadowAnimation.value,
                shadowColor: Colors.black.withOpacity(0.1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: InkWell(
                  onTap: _navigateToDetails,
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    height: 280,
                    child: Row(
                      children: [
                        // Image section - 40% width
                        Expanded(
                          flex: 4,
                          child: _buildImageSection(
                            height: 280,
                            isDesktop: true,
                          ),
                        ),

                        // Content section - 60% width
                        Expanded(
                          flex: 6,
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Header with title and favorite
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          // Category chip
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 12,
                                              vertical: 6,
                                            ),
                                            decoration: BoxDecoration(
                                              color:
                                                  colorScheme.primaryContainer,
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                            ),
                                            child: Text(
                                              widget.tour.category,
                                              style: textTheme.labelSmall
                                                  ?.copyWith(
                                                    color:
                                                        colorScheme
                                                            .onPrimaryContainer,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                            ),
                                          ),
                                          const SizedBox(height: 12),

                                          // Title
                                          Text(
                                            widget.tour.name,
                                            style: textTheme.headlineSmall
                                                ?.copyWith(
                                                  fontWeight: FontWeight.bold,
                                                  height: 1.2,
                                                ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ),
                                    ),

                                    // Favorite button
                                    IconButton(
                                      onPressed: () {
                                        HapticFeedback.lightImpact();
                                        widget.onFavoriteToggle?.call();
                                      },
                                      icon: AnimatedSwitcher(
                                        duration: const Duration(
                                          milliseconds: 200,
                                        ),
                                        child: Icon(
                                          widget.isFavorite
                                              ? Icons.favorite
                                              : Icons.favorite_border,
                                          key: ValueKey(widget.isFavorite),
                                          color:
                                              widget.isFavorite
                                                  ? Colors.red
                                                  : colorScheme.outline,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 8),

                                // Location
                                Row(
                                  children: [
                                    Icon(
                                      Icons.location_on_rounded,
                                      size: 18,
                                      color: colorScheme.primary,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      widget.tour.location,
                                      style: textTheme.bodyMedium?.copyWith(
                                        color: colorScheme.onSurface
                                            .withOpacity(0.7),
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 16),

                                // Description
                                Text(
                                  widget.tour.description,
                                  style: textTheme.bodyMedium?.copyWith(
                                    height: 1.5,
                                  ),
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                ),

                                const Spacer(),

                                // Features and details
                                Row(
                                  children: [
                                    Expanded(
                                      child: Wrap(
                                        spacing: 12,
                                        runSpacing: 8,
                                        children: [
                                          _buildFeatureChip(
                                            Icons.schedule_rounded,
                                            widget.tour.durationText,
                                            colorScheme.primaryContainer,
                                            colorScheme.onPrimaryContainer,
                                          ),
                                          _buildFeatureChip(
                                            widget.tour.activityIcon,
                                            widget.tour.activityType,
                                            colorScheme.secondaryContainer,
                                            colorScheme.onSecondaryContainer,
                                          ),
                                          _buildFeatureChip(
                                            Icons.speed_rounded,
                                            widget.tour.difficultyLevel,
                                            widget.tour.difficultyColor
                                                .withOpacity(0.2),
                                            widget.tour.difficultyColor,
                                          ),
                                          if (widget.tour.averageRating != null)
                                            _buildFeatureChip(
                                              Icons.star_rounded,
                                              '${widget.tour.averageRating!.toStringAsFixed(1)} (${widget.tour.reviewCount})',
                                              Colors.amber.withOpacity(0.2),
                                              Colors.orange.shade800,
                                            ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 20),

                                // Price and book button
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        if (widget.tour.hasDiscount)
                                          Text(
                                            widget.tour.originalPrice,
                                            style: textTheme.bodyMedium
                                                ?.copyWith(
                                                  decoration:
                                                      TextDecoration
                                                          .lineThrough,
                                                  color: colorScheme.onSurface
                                                      .withOpacity(0.6),
                                                ),
                                          ),
                                        Row(
                                          children: [
                                            Text(
                                              widget.tour.displayPrice,
                                              style: textTheme.headlineMedium
                                                  ?.copyWith(
                                                    color: colorScheme.primary,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              '/ person',
                                              style: textTheme.bodySmall
                                                  ?.copyWith(
                                                    color: colorScheme.onSurface
                                                        .withOpacity(0.6),
                                                  ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),

                                    ElevatedButton(
                                      onPressed: _navigateToDetails,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: colorScheme.primary,
                                        foregroundColor: colorScheme.onPrimary,
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 32,
                                          vertical: 16,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        elevation: _isHovered ? 4 : 2,
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Text(
                                            'View Details',
                                            style: TextStyle(
                                              fontWeight: FontWeight.w600,
                                              fontSize: 16,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Icon(
                                            Icons.arrow_forward_rounded,
                                            size: 18,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTabletCard() {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Card(
        clipBehavior: Clip.antiAlias,
        elevation: 3,
        shadowColor: Colors.black.withOpacity(0.1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: InkWell(
          onTap: _navigateToDetails,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            height: 200,
            child: Row(
              children: [
                // Image section
                Expanded(flex: 3, child: _buildImageSection(height: 200)),

                // Content section
                Expanded(
                  flex: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title and favorite
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                widget.tour.name,
                                style: textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            IconButton(
                              onPressed: () {
                                HapticFeedback.lightImpact();
                                widget.onFavoriteToggle?.call();
                              },
                              icon: Icon(
                                widget.isFavorite
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                color:
                                    widget.isFavorite
                                        ? Colors.red
                                        : colorScheme.outline,
                              ),
                            ),
                          ],
                        ),

                        // Location
                        Row(
                          children: [
                            Icon(
                              Icons.location_on_rounded,
                              size: 16,
                              color: colorScheme.primary,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                widget.tour.location,
                                style: textTheme.bodyMedium?.copyWith(
                                  color: colorScheme.onSurface.withOpacity(0.7),
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
                          spacing: 8,
                          runSpacing: 6,
                          children: [
                            _buildFeatureChip(
                              Icons.schedule_rounded,
                              widget.tour.durationText,
                              colorScheme.primaryContainer,
                              colorScheme.onPrimaryContainer,
                              isSmall: true,
                            ),
                            _buildFeatureChip(
                              widget.tour.activityIcon,
                              widget.tour.activityType,
                              colorScheme.secondaryContainer,
                              colorScheme.onSecondaryContainer,
                              isSmall: true,
                            ),
                          ],
                        ),

                        const Spacer(),

                        // Price and rating
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (widget.tour.hasDiscount)
                                  Text(
                                    widget.tour.originalPrice,
                                    style: textTheme.bodySmall?.copyWith(
                                      decoration: TextDecoration.lineThrough,
                                      color: colorScheme.onSurface.withOpacity(
                                        0.6,
                                      ),
                                    ),
                                  ),
                                Text(
                                  widget.tour.displayPrice,
                                  style: textTheme.titleLarge?.copyWith(
                                    color: colorScheme.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),

                            if (widget.tour.averageRating != null)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.amber.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.star_rounded,
                                      color: Colors.amber,
                                      size: 16,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      widget.tour.averageRating!
                                          .toStringAsFixed(1),
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMobileCard() {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Card(
        clipBehavior: Clip.antiAlias,
        elevation: 2,
        shadowColor: Colors.black.withOpacity(0.1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: InkWell(
          onTap: _navigateToDetails,
          borderRadius: BorderRadius.circular(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image section
              _buildImageSection(height: 200),

              // Content section
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title and favorite
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            widget.tour.name,
                            style: textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              height: 1.2,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            HapticFeedback.lightImpact();
                            widget.onFavoriteToggle?.call();
                          },
                          icon: Icon(
                            widget.isFavorite
                                ? Icons.favorite
                                : Icons.favorite_border,
                            color:
                                widget.isFavorite
                                    ? Colors.red
                                    : colorScheme.outline,
                          ),
                        ),
                      ],
                    ),

                    // Location
                    Row(
                      children: [
                        Icon(
                          Icons.location_on_rounded,
                          size: 16,
                          color: colorScheme.primary,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            widget.tour.location,
                            style: textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onSurface.withOpacity(0.7),
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
                      spacing: 8,
                      runSpacing: 6,
                      children: [
                        _buildFeatureChip(
                          Icons.schedule_rounded,
                          widget.tour.durationText,
                          colorScheme.primaryContainer,
                          colorScheme.onPrimaryContainer,
                          isSmall: true,
                        ),
                        _buildFeatureChip(
                          widget.tour.activityIcon,
                          widget.tour.activityType,
                          colorScheme.secondaryContainer,
                          colorScheme.onSecondaryContainer,
                          isSmall: true,
                        ),
                        _buildFeatureChip(
                          Icons.speed_rounded,
                          widget.tour.difficultyLevel,
                          widget.tour.difficultyColor.withOpacity(0.2),
                          widget.tour.difficultyColor,
                          isSmall: true,
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Price and rating
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (widget.tour.hasDiscount)
                              Text(
                                widget.tour.originalPrice,
                                style: textTheme.bodySmall?.copyWith(
                                  decoration: TextDecoration.lineThrough,
                                  color: colorScheme.onSurface.withOpacity(0.6),
                                ),
                              ),
                            Text(
                              widget.tour.displayPrice,
                              style: textTheme.headlineSmall?.copyWith(
                                color: colorScheme.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),

                        if (widget.tour.averageRating != null)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.amber.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.star_rounded,
                                  color: Colors.amber,
                                  size: 16,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  widget.tour.averageRating!.toStringAsFixed(1),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                                Text(
                                  ' (${widget.tour.reviewCount})',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: colorScheme.onSurface.withOpacity(
                                      0.7,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageSection({required double height, bool isDesktop = false}) {
    final colorScheme = Theme.of(context).colorScheme;

    return Stack(
      children: [
        Container(
          height: height,
          width: double.infinity,
          decoration: BoxDecoration(color: colorScheme.surfaceContainer),
          child:
              widget.tour.mainImageUrl != null &&
                      widget.tour.mainImageUrl!.isNotEmpty
                  ? Hero(
                    tag: 'tour_${widget.tour.id}',
                    child: Image.network(
                      widget.tour.mainImageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder:
                          (context, error, stackTrace) =>
                              _buildImagePlaceholder(),
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                colorScheme.surfaceContainer,
                                colorScheme.surfaceContainer.withOpacity(0.7),
                              ],
                            ),
                          ),
                          child: Center(
                            child: CircularProgressIndicator(
                              value:
                                  loadingProgress.expectedTotalBytes != null
                                      ? loadingProgress.cumulativeBytesLoaded /
                                          loadingProgress.expectedTotalBytes!
                                      : null,
                              strokeWidth: 2,
                              color: colorScheme.primary,
                            ),
                          ),
                        );
                      },
                    ),
                  )
                  : _buildImagePlaceholder(),
        ),

        // Gradient overlay
        if (!isDesktop)
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black.withOpacity(0.1)],
                  stops: const [0.7, 1.0],
                ),
              ),
            ),
          ),

        // Discount badge
        if (widget.tour.hasDiscount)
          Positioned(
            top: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                '${widget.tour.discountPercentage}% OFF',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
      ],
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
            colorScheme.primary.withOpacity(0.2),
            colorScheme.secondary.withOpacity(0.2),
          ],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.landscape_rounded,
              size: widget.isDesktop ? 64 : 48,
              color: colorScheme.outline,
            ),
            const SizedBox(height: 8),
            Text(
              'Image not available',
              style: TextStyle(
                color: colorScheme.outline,
                fontSize: widget.isDesktop ? 16 : 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureChip(
    IconData icon,
    String label,
    Color backgroundColor,
    Color textColor, {
    bool isSmall = false,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isSmall ? 8 : 10,
        vertical: isSmall ? 4 : 6,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(isSmall ? 8 : 10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: isSmall ? 12 : 14, color: textColor),
          SizedBox(width: isSmall ? 4 : 6),
          Text(
            label,
            style: TextStyle(
              fontSize: isSmall ? 11 : 12,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToDetails() {
    HapticFeedback.lightImpact();
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder:
            (context, animation, secondaryAnimation) =>
                TourDetailsScreen(tourId: widget.tour.id),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: animation.drive(
                Tween(
                  begin: const Offset(0.03, 0.03),
                  end: Offset.zero,
                ).chain(CurveTween(curve: Curves.easeOut)),
              ),
              child: child,
            ),
          );
        },
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
  }
}
