import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../utils/animation_utils.dart';

/// Enhanced animated card with parallax, tilt, and glow effects
class AnimatedCard extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final double elevation;
  final BorderRadius? borderRadius;
  final Color? shadowColor;
  final bool enableTilt;
  final bool enableGlow;
  final bool enableParallax;
  final Duration animationDuration;
  final double tiltIntensity;

  const AnimatedCard({
    super.key,
    required this.child,
    this.onTap,
    this.elevation = 4,
    this.borderRadius,
    this.shadowColor,
    this.enableTilt = true,
    this.enableGlow = true,
    this.enableParallax = true,
    this.animationDuration = const Duration(milliseconds: 300),
    this.tiltIntensity = 0.015,
  });

  @override
  State<AnimatedCard> createState() => _AnimatedCardState();
}

class _AnimatedCardState extends State<AnimatedCard>
    with TickerProviderStateMixin {
  late AnimationController _hoverController;
  late AnimationController _pressController;
  late Animation<double> _elevationAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _glowAnimation;

  double _tiltX = 0.0;
  double _tiltY = 0.0;
  bool _isHovered = false;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();

    _hoverController = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );

    _pressController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );

    _elevationAnimation = Tween<double>(
      begin: widget.elevation,
      end: widget.elevation * 2.5,
    ).animate(
      CurvedAnimation(parent: _hoverController, curve: Curves.easeOutCubic),
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.98).animate(
      CurvedAnimation(parent: _pressController, curve: Curves.easeInOut),
    );

    _glowAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _hoverController, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _hoverController.dispose();
    _pressController.dispose();
    super.dispose();
  }

  void _handleHover(PointerEvent details) {
    if (!widget.enableTilt) return;

    final RenderBox box = context.findRenderObject() as RenderBox;
    final localPosition = box.globalToLocal(details.position);
    final size = box.size;

    setState(() {
      _tiltX = (localPosition.dy - size.height / 2) / size.height;
      _tiltY = -(localPosition.dx - size.width / 2) / size.width;
    });
  }

  void _handleHoverEnter(PointerEnterEvent event) {
    setState(() => _isHovered = true);
    _hoverController.forward();
  }

  void _handleHoverExit(PointerExitEvent event) {
    setState(() {
      _isHovered = false;
      _tiltX = 0.0;
      _tiltY = 0.0;
    });
    _hoverController.reverse();
  }

  void _handleTapDown(TapDownDetails details) {
    setState(() => _isPressed = true);
    _pressController.forward();
    HapticUtils.lightImpact();
  }

  void _handleTapUp(TapUpDetails details) {
    setState(() => _isPressed = false);
    _pressController.reverse();
  }

  void _handleTapCancel() {
    setState(() => _isPressed = false);
    _pressController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final borderRadius = widget.borderRadius ?? BorderRadius.circular(16);

    return MouseRegion(
      onHover: _handleHover,
      onEnter: _handleHoverEnter,
      onExit: _handleHoverExit,
      child: GestureDetector(
        onTapDown: _handleTapDown,
        onTapUp: _handleTapUp,
        onTapCancel: _handleTapCancel,
        onTap: widget.onTap,
        child: AnimatedBuilder(
          animation: Listenable.merge([_hoverController, _pressController]),
          builder: (context, child) {
            return Transform(
              alignment: Alignment.center,
              transform:
                  Matrix4.identity()
                    ..setEntry(3, 2, 0.001) // Perspective
                    ..rotateX(_tiltX * widget.tiltIntensity)
                    ..rotateY(_tiltY * widget.tiltIntensity)
                    ..scale(_scaleAnimation.value),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: borderRadius,
                  boxShadow: [
                    // Main shadow
                    BoxShadow(
                      color: (widget.shadowColor ?? Colors.black).withOpacity(
                        0.1 + (0.1 * _hoverController.value),
                      ),
                      blurRadius: _elevationAnimation.value,
                      offset: Offset(0, _elevationAnimation.value / 2),
                      spreadRadius: 0,
                    ),
                    // Glow effect
                    if (widget.enableGlow && _isHovered)
                      BoxShadow(
                        color: colorScheme.primary.withOpacity(
                          0.3 * _glowAnimation.value,
                        ),
                        blurRadius: 20 * _glowAnimation.value,
                        spreadRadius: -5,
                      ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: borderRadius,
                  child: Material(
                    color: Colors.transparent,
                    child: widget.child,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

/// Skeleton loading card
class SkeletonCard extends StatefulWidget {
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;
  final EdgeInsets? margin;
  final bool showShimmer;

  const SkeletonCard({
    super.key,
    this.width,
    this.height,
    this.borderRadius,
    this.margin,
    this.showShimmer = true,
  });

  @override
  State<SkeletonCard> createState() => _SkeletonCardState();
}

class _SkeletonCardState extends State<SkeletonCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _shimmerController;
  late Animation<double> _shimmerAnimation;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();

    _shimmerAnimation = Tween<double>(begin: -1.0, end: 2.0).animate(
      CurvedAnimation(parent: _shimmerController, curve: Curves.linear),
    );
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final baseColor =
        isDark
            ? colorScheme.surface.withOpacity(0.3)
            : colorScheme.surfaceVariant.withOpacity(0.5);
    final highlightColor =
        isDark ? colorScheme.surface.withOpacity(0.5) : colorScheme.surface;

    return Container(
      width: widget.width,
      height: widget.height,
      margin: widget.margin,
      decoration: BoxDecoration(
        borderRadius: widget.borderRadius ?? BorderRadius.circular(16),
        color: baseColor,
      ),
      child:
          widget.showShimmer
              ? AnimatedBuilder(
                animation: _shimmerAnimation,
                builder: (context, child) {
                  return Container(
                    decoration: BoxDecoration(
                      borderRadius:
                          widget.borderRadius ?? BorderRadius.circular(16),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [baseColor, highlightColor, baseColor],
                        stops: [
                          _shimmerAnimation.value - 0.3,
                          _shimmerAnimation.value,
                          _shimmerAnimation.value + 0.3,
                        ],
                        transform: const GradientRotation(0.5),
                      ),
                    ),
                  );
                },
              )
              : null,
    );
  }
}

/// Skeleton loading list
class SkeletonList extends StatelessWidget {
  final int itemCount;
  final double itemHeight;
  final EdgeInsets padding;
  final double spacing;

  const SkeletonList({
    super.key,
    this.itemCount = 5,
    this.itemHeight = 200,
    this.padding = const EdgeInsets.all(16),
    this.spacing = 16,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Column(
        children: List.generate(
          itemCount,
          (index) => Padding(
            padding: EdgeInsets.only(
              bottom: index < itemCount - 1 ? spacing : 0,
            ),
            child: _buildSkeletonItem(context),
          ),
        ),
      ),
    );
  }

  Widget _buildSkeletonItem(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Image skeleton
        SkeletonCard(
          height: itemHeight * 0.6,
          borderRadius: BorderRadius.circular(12),
        ),
        const SizedBox(height: 12),
        // Title skeleton
        SkeletonCard(
          height: 20,
          width: double.infinity,
          borderRadius: BorderRadius.circular(4),
        ),
        const SizedBox(height: 8),
        // Subtitle skeleton
        SkeletonCard(
          height: 16,
          width: 200,
          borderRadius: BorderRadius.circular(4),
        ),
        const SizedBox(height: 12),
        // Price skeleton
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SkeletonCard(
              height: 24,
              width: 80,
              borderRadius: BorderRadius.circular(4),
            ),
            SkeletonCard(
              height: 36,
              width: 100,
              borderRadius: BorderRadius.circular(18),
            ),
          ],
        ),
      ],
    );
  }
}

/// Glassmorphism card effect
class GlassmorphicCard extends StatelessWidget {
  final Widget child;
  final double blur;
  final double opacity;
  final BorderRadius? borderRadius;
  final Border? border;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final List<BoxShadow>? boxShadow;

  const GlassmorphicCard({
    super.key,
    required this.child,
    this.blur = 10,
    this.opacity = 0.1,
    this.borderRadius,
    this.border,
    this.padding,
    this.margin,
    this.boxShadow,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final radius = borderRadius ?? BorderRadius.circular(16);

    return Container(
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: radius,
        boxShadow:
            boxShadow ??
            [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
      ),
      child: ClipRRect(
        borderRadius: radius,
        child: BackdropFilter(
          filter: ColorFilter.mode(
            colorScheme.surface.withOpacity(opacity),
            BlendMode.srcOver,
          ),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              borderRadius: radius,
              border:
                  border ??
                  Border.all(
                    color: colorScheme.outline.withOpacity(0.2),
                    width: 1,
                  ),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  colorScheme.surface.withOpacity(opacity),
                  colorScheme.surface.withOpacity(opacity * 0.5),
                ],
              ),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
