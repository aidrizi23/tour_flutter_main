import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tour_flutter_main/models/models.dart';

// Modern elevated card with consistent design
class ModernCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final double? elevation;
  final Color? backgroundColor;
  final BorderRadius? borderRadius;
  final Border? border;

  const ModernCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding,
    this.margin,
    this.elevation,
    this.backgroundColor,
    this.borderRadius,
    this.border,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    Widget cardChild = Container(
      padding: padding ?? const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: backgroundColor ?? colorScheme.surface,
        borderRadius: borderRadius ?? BorderRadius.circular(20),
        border:
            border ?? Border.all(color: colorScheme.outline.withOpacity(0.1)),
        boxShadow:
            elevation != null
                ? [
                  BoxShadow(
                    color: colorScheme.shadow.withOpacity(0.05),
                    blurRadius: elevation! * 2,
                    offset: Offset(0, elevation! / 2),
                  ),
                ]
                : null,
      ),
      child: child,
    );

    if (onTap != null) {
      return Container(
        margin: margin,
        child: Material(
          color: Colors.transparent,
          borderRadius: borderRadius ?? BorderRadius.circular(20),
          child: InkWell(
            onTap: onTap,
            borderRadius: borderRadius ?? BorderRadius.circular(20),
            child: cardChild,
          ),
        ),
      );
    }

    return Container(margin: margin, child: cardChild);
  }
}

// Modern search field with consistent design
class ModernSearchField extends StatelessWidget {
  final TextEditingController? controller;
  final String? hintText;
  final String? labelText;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onTap;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final bool enabled;
  final bool readOnly;
  final TextInputType keyboardType;
  final TextInputAction textInputAction;
  final FocusNode? focusNode;

  const ModernSearchField({
    super.key,
    this.controller,
    this.hintText,
    this.labelText,
    this.onChanged,
    this.onSubmitted,
    this.onTap,
    this.prefixIcon,
    this.suffixIcon,
    this.enabled = true,
    this.readOnly = false,
    this.keyboardType = TextInputType.text,
    this.textInputAction = TextInputAction.search,
    this.focusNode,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outline.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        enabled: enabled,
        readOnly: readOnly,
        keyboardType: keyboardType,
        textInputAction: textInputAction,
        onChanged: onChanged,
        onSubmitted: onSubmitted,
        onTap: onTap,
        decoration: InputDecoration(
          hintText: hintText,
          labelText: labelText,
          prefixIcon:
              prefixIcon ?? Icon(Icons.search, color: colorScheme.primary),
          suffixIcon: suffixIcon,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 16,
          ),
          hintStyle: TextStyle(color: colorScheme.onSurface.withOpacity(0.6)),
        ),
      ),
    );
  }
}

// Modern chip with consistent design
class ModernChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback? onTap;
  final IconData? icon;
  final Color? selectedColor;
  final Color? backgroundColor;
  final Color? textColor;
  final EdgeInsets? padding;

  const ModernChip({
    super.key,
    required this.label,
    this.selected = false,
    this.onTap,
    this.icon,
    this.selectedColor,
    this.backgroundColor,
    this.textColor,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding:
              padding ??
              const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color:
                selected
                    ? selectedColor ?? colorScheme.primary.withOpacity(0.15)
                    : backgroundColor ?? colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color:
                  selected
                      ? colorScheme.primary
                      : colorScheme.outline.withOpacity(0.3),
              width: selected ? 2 : 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(
                  icon,
                  size: 16,
                  color:
                      selected
                          ? colorScheme.primary
                          : textColor ?? colorScheme.onSurface.withOpacity(0.7),
                ),
                const SizedBox(width: 6),
              ],
              Text(
                label,
                style: TextStyle(
                  color:
                      selected
                          ? colorScheme.primary
                          : textColor ?? colorScheme.onSurface,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Modern filter button
class ModernFilterButton extends StatelessWidget {
  final VoidCallback onPressed;
  final bool hasActiveFilters;
  final int? filterCount;

  const ModernFilterButton({
    super.key,
    required this.onPressed,
    this.hasActiveFilters = false,
    this.filterCount,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            color:
                hasActiveFilters
                    ? colorScheme.primary.withOpacity(0.1)
                    : colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color:
                  hasActiveFilters
                      ? colorScheme.primary
                      : colorScheme.outline.withOpacity(0.3),
              width: hasActiveFilters ? 2 : 1,
            ),
          ),
          child: IconButton(
            onPressed: onPressed,
            icon: Icon(
              Icons.tune_rounded,
              color:
                  hasActiveFilters
                      ? colorScheme.primary
                      : colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
        ),
        if (filterCount != null && filterCount! > 0)
          Positioned(
            right: 2,
            top: 2,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: colorScheme.error,
                shape: BoxShape.circle,
              ),
              constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
              child: Text(
                filterCount.toString(),
                style: TextStyle(
                  color: colorScheme.onError,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );
  }
}

// Modern empty state widget
class ModernEmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final String? actionText;
  final VoidCallback? onAction;

  const ModernEmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    this.actionText,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: colorScheme.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 64,
                color: colorScheme.primary.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
            if (actionText != null && onAction != null) ...[
              const SizedBox(height: 24),
              FilledButton(onPressed: onAction, child: Text(actionText!)),
            ],
          ],
        ),
      ),
    );
  }
}

// Modern loading state widget
class ModernLoadingState extends StatelessWidget {
  final String? message;
  final bool showLogo;

  const ModernLoadingState({super.key, this.message, this.showLogo = false});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (showLogo) ...[
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: colorScheme.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.explore, size: 48, color: colorScheme.primary),
            ),
            const SizedBox(height: 24),
          ],
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: colorScheme.shadow.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 32,
                  height: 32,
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    color: colorScheme.primary,
                  ),
                ),
                if (message != null) ...[
                  const SizedBox(height: 16),
                  Text(
                    message!,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurface.withOpacity(0.7),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Modern error state widget
class ModernErrorState extends StatelessWidget {
  final String title;
  final String message;
  final String? actionText;
  final VoidCallback? onRetry;

  const ModernErrorState({
    super.key,
    required this.title,
    required this.message,
    this.actionText,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: ModernCard(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: colorScheme.error.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.error_outline,
                  size: 48,
                  color: colorScheme.error,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.error,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                message,
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              if (actionText != null && onRetry != null) ...[
                const SizedBox(height: 24),
                FilledButton.icon(
                  onPressed: onRetry,
                  icon: const Icon(Icons.refresh_rounded),
                  label: Text(actionText!),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// Modern rating stars
class ModernRatingStars extends StatelessWidget {
  final double rating;
  final int maxRating;
  final double size;
  final Color? activeColor;
  final Color? inactiveColor;
  final Function(int)? onRatingChanged;

  const ModernRatingStars({
    super.key,
    required this.rating,
    this.maxRating = 5,
    this.size = 20,
    this.activeColor,
    this.inactiveColor,
    this.onRatingChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final activeStarColor = activeColor ?? const Color(0xFFFFA726);
    final inactiveStarColor =
        inactiveColor ?? colorScheme.outline.withOpacity(0.3);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(maxRating, (index) {
        final isFilled = index < rating.floor();
        final isHalfFilled = index < rating && index >= rating.floor();

        return GestureDetector(
          onTap:
              onRatingChanged != null
                  ? () => onRatingChanged!(index + 1)
                  : null,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 1),
            child: Stack(
              children: [
                Icon(Icons.star_rounded, size: size, color: inactiveStarColor),
                if (isFilled || isHalfFilled)
                  ClipPath(
                    clipper: isHalfFilled ? _HalfStarClipper() : null,
                    child: Icon(
                      Icons.star_rounded,
                      size: size,
                      color: activeStarColor,
                    ),
                  ),
              ],
            ),
          ),
        );
      }),
    );
  }
}

class _HalfStarClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.addRect(Rect.fromLTWH(0, 0, size.width / 2, size.height));
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

// Modern animated counter
class ModernAnimatedCounter extends StatefulWidget {
  final int count;
  final Duration duration;
  final TextStyle? textStyle;
  final String? suffix;

  const ModernAnimatedCounter({
    super.key,
    required this.count,
    this.duration = const Duration(milliseconds: 500),
    this.textStyle,
    this.suffix,
  });

  @override
  State<ModernAnimatedCounter> createState() => _ModernAnimatedCounterState();
}

class _ModernAnimatedCounterState extends State<ModernAnimatedCounter>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  int _currentCount = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: widget.duration, vsync: this);
    _animation = Tween<double>(
      begin: 0,
      end: widget.count.toDouble(),
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCirc));

    _controller.forward();
    _controller.addListener(() {
      setState(() {
        _currentCount = _animation.value.round();
      });
    });
  }

  @override
  void didUpdateWidget(ModernAnimatedCounter oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.count != oldWidget.count) {
      _animation = Tween<double>(
        begin: _currentCount.toDouble(),
        end: widget.count.toDouble(),
      ).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeOutCirc),
      );
      _controller.reset();
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      '$_currentCount${widget.suffix ?? ''}',
      style: widget.textStyle ?? Theme.of(context).textTheme.headlineMedium,
    );
  }
}

// Modern price display
class ModernPriceDisplay extends StatelessWidget {
  final double price;
  final double? originalPrice;
  final String? currency;
  final bool showFree;
  final TextStyle? priceStyle;
  final TextStyle? originalPriceStyle;
  final MainAxisAlignment alignment;

  const ModernPriceDisplay({
    super.key,
    required this.price,
    this.originalPrice,
    this.currency = '\$',
    this.showFree = true,
    this.priceStyle,
    this.originalPriceStyle,
    this.alignment = MainAxisAlignment.start,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final hasDiscount = originalPrice != null && originalPrice! > price;

    if (price == 0 && showFree) {
      return Text(
        'Free',
        style:
            priceStyle ??
            Theme.of(context).textTheme.titleLarge?.copyWith(
              color: colorScheme.secondary,
              fontWeight: FontWeight.bold,
            ),
      );
    }

    return Row(
      mainAxisAlignment: alignment,
      children: [
        Text(
          '$currency${price.toStringAsFixed(2)}',
          style:
              priceStyle ??
              Theme.of(context).textTheme.titleLarge?.copyWith(
                color: colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
        ),
        if (hasDiscount) ...[
          const SizedBox(width: 8),
          Text(
            '$currency${originalPrice!.toStringAsFixed(2)}',
            style:
                originalPriceStyle ??
                Theme.of(context).textTheme.bodyMedium?.copyWith(
                  decoration: TextDecoration.lineThrough,
                  color: colorScheme.onSurface.withOpacity(0.6),
                ),
          ),
        ],
      ],
    );
  }
}

// Modern tag/badge
class ModernTag extends StatelessWidget {
  final String label;
  final Color? backgroundColor;
  final Color? textColor;
  final IconData? icon;
  final bool isSmall;

  const ModernTag({
    super.key,
    required this.label,
    this.backgroundColor,
    this.textColor,
    this.icon,
    this.isSmall = false,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isSmall ? 8 : 12,
        vertical: isSmall ? 4 : 6,
      ),
      decoration: BoxDecoration(
        color: backgroundColor ?? colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(isSmall ? 8 : 12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              size: isSmall ? 12 : 16,
              color: textColor ?? colorScheme.onPrimaryContainer,
            ),
            SizedBox(width: isSmall ? 4 : 6),
          ],
          Text(
            label,
            style: TextStyle(
              color: textColor ?? colorScheme.onPrimaryContainer,
              fontSize: isSmall ? 11 : 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// Modern progress indicator
class ModernProgressIndicator extends StatelessWidget {
  final double progress;
  final String? label;
  final Color? progressColor;
  final Color? backgroundColor;
  final double height;

  const ModernProgressIndicator({
    super.key,
    required this.progress,
    this.label,
    this.progressColor,
    this.backgroundColor,
    this.height = 8,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text(label!, style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 4),
        ],
        Container(
          height: height,
          decoration: BoxDecoration(
            color: backgroundColor ?? colorScheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(height / 2),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(height / 2),
            child: LinearProgressIndicator(
              value: progress.clamp(0.0, 1.0),
              backgroundColor: Colors.transparent,
              valueColor: AlwaysStoppedAnimation<Color>(
                progressColor ?? colorScheme.primary,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// Modern snackbar helper
class ModernSnackBar {
  static void show(
    BuildContext context, {
    required String message,
    SnackBarType type = SnackBarType.info,
    Duration duration = const Duration(seconds: 4),
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    Color backgroundColor;
    Color textColor;
    IconData icon;

    switch (type) {
      case SnackBarType.success:
        backgroundColor = const Color(0xFF10B981);
        textColor = Colors.white;
        icon = Icons.check_circle_outline;
        break;
      case SnackBarType.error:
        backgroundColor = const Color(0xFFEF4444);
        textColor = Colors.white;
        icon = Icons.error_outline;
        break;
      case SnackBarType.warning:
        backgroundColor = const Color(0xFFF59E0B);
        textColor = Colors.white;
        icon = Icons.warning_outlined;
        break;
      case SnackBarType.info:
      default:
        backgroundColor = colorScheme.inverseSurface;
        textColor = colorScheme.onInverseSurface;
        icon = Icons.info_outline;
        break;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: textColor, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: TextStyle(color: textColor, fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
        backgroundColor: backgroundColor,
        duration: duration,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        action:
            actionLabel != null && onAction != null
                ? SnackBarAction(
                  label: actionLabel,
                  textColor: textColor,
                  onPressed: onAction,
                )
                : null,
      ),
    );
  }
}

enum SnackBarType { success, error, warning, info }

// Haptic feedback utility
class ModernHaptics {
  static void light() => HapticFeedback.lightImpact();
  static void medium() => HapticFeedback.mediumImpact();
  static void heavy() => HapticFeedback.heavyImpact();
  static void selection() => HapticFeedback.selectionClick();
  static void vibrate() => HapticFeedback.vibrate();
}

/// Modern loading indicator with customizable text and animations
class ModernLoadingIndicator extends StatefulWidget {
  final String text;
  final Color? primaryColor;
  final double size;
  final bool showText;

  const ModernLoadingIndicator({
    super.key,
    this.text = 'Loading...',
    this.primaryColor,
    this.size = 48.0,
    this.showText = true,
  });

  @override
  State<ModernLoadingIndicator> createState() => _ModernLoadingIndicatorState();
}

class _ModernLoadingIndicatorState extends State<ModernLoadingIndicator>
    with TickerProviderStateMixin {
  late AnimationController _rotationController;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = widget.primaryColor ?? theme.colorScheme.primary;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedBuilder(
          animation: _rotationController,
          builder: (context, child) {
            return Transform.rotate(
              angle: _rotationController.value * 2.0 * math.pi,
              child: AnimatedBuilder(
                animation: _pulseAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _pulseAnimation.value,
                    child: Container(
                      width: widget.size,
                      height: widget.size,
                      decoration: BoxDecoration(
                        gradient: SweepGradient(
                          colors: [
                            primaryColor.withOpacity(0.1),
                            primaryColor,
                            primaryColor.withOpacity(0.1),
                          ],
                          stops: const [0.0, 0.5, 1.0],
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: Container(
                        margin: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surface,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.explore_rounded,
                          color: primaryColor,
                          size: widget.size * 0.4,
                        ),
                      ),
                    ),
                  );
                },
              ),
            );
          },
        ),
        if (widget.showText) ...[
          const SizedBox(height: 16),
          Text(
            widget.text,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ],
    );
  }
}

/// Modern error widget with retry functionality
class ModernErrorWidget extends StatelessWidget {
  final String title;
  final String message;
  final VoidCallback? onRetry;
  final IconData icon;
  final bool showRetryButton;

  const ModernErrorWidget({
    super.key,
    this.title = 'Something went wrong',
    this.message =
        'Please try again or contact support if the problem persists.',
    this.onRetry,
    this.icon = Icons.error_outline_rounded,
    this.showRetryButton = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.colorScheme.errorContainer.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.error.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.error.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 48, color: theme.colorScheme.error),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.error,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          if (showRetryButton && onRetry != null) ...[
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Try Again'),
              style: FilledButton.styleFrom(
                backgroundColor: theme.colorScheme.error,
                foregroundColor: theme.colorScheme.onError,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Modern user insights card with animated statistics
class ModernInsightsCard extends StatefulWidget {
  final UserInsights insights;
  final VoidCallback? onTap;

  const ModernInsightsCard({super.key, required this.insights, this.onTap});

  @override
  State<ModernInsightsCard> createState() => _ModernInsightsCardState();
}

class _ModernInsightsCardState extends State<ModernInsightsCard>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.7, curve: Curves.easeOut),
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.2, 1.0, curve: Curves.easeOutCubic),
      ),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: Card(
              elevation: 0,
              color: theme.colorScheme.surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: theme.colorScheme.outline.withOpacity(0.2),
                ),
              ),
              child: InkWell(
                onTap: widget.onTap,
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        theme.colorScheme.primaryContainer.withOpacity(0.3),
                        theme.colorScheme.surface,
                      ],
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.insights_rounded,
                              color: theme.colorScheme.primary,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Your Travel Insights',
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  'Personalized statistics',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      _buildInsightGrid(context),
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

  Widget _buildInsightGrid(BuildContext context) {
    final theme = Theme.of(context);
    final insights = widget.insights;

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.2,
      children: [
        _buildStatCard(
          context,
          'Total Trips',
          insights.totalTrips.toString(),
          Icons.card_travel_rounded,
          theme.colorScheme.primary,
        ),
        _buildStatCard(
          context,
          'Total Spent',
          '\$${insights.totalSpent.toStringAsFixed(0)}',
          Icons.payments_rounded,
          Colors.green,
        ),
        _buildStatCard(
          context,
          'Avg Duration',
          '${insights.averageTripDuration} days',
          Icons.schedule_rounded,
          Colors.orange,
        ),
        _buildStatCard(
          context,
          'Total Savings',
          '\$${insights.totalSavings.toStringAsFixed(0)}',
          Icons.savings_rounded,
          Colors.purple,
        ),
      ],
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2), width: 1),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

/// Modern flash deal card with countdown timer
class ModernFlashDealCard extends StatefulWidget {
  final FlashDeal deal;
  final VoidCallback? onTap;

  const ModernFlashDealCard({super.key, required this.deal, this.onTap});

  @override
  State<ModernFlashDealCard> createState() => _ModernFlashDealCardState();
}

class _ModernFlashDealCardState extends State<ModernFlashDealCard> {
  late Timer _timer;
  Duration _timeRemaining = Duration.zero;

  @override
  void initState() {
    super.initState();
    _updateTimeRemaining();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      _updateTimeRemaining();
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _updateTimeRemaining() {
    final now = DateTime.now();
    final difference = widget.deal.endsAt.difference(now);

    if (mounted) {
      setState(() {
        _timeRemaining = difference.isNegative ? Duration.zero : difference;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isExpired = _timeRemaining == Duration.zero;

    return Card(
      elevation: 0,
      color: theme.colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: widget.deal.getTypeColor().withOpacity(0.3),
          width: 2,
        ),
      ),
      child: InkWell(
        onTap: isExpired ? null : widget.onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                widget.deal.getTypeColor().withOpacity(0.1),
                theme.colorScheme.surface,
              ],
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.flash_on_rounded,
                          color: Colors.white,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'FLASH DEAL',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: widget.deal.getTypeColor().withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      widget.deal.type.toUpperCase(),
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: widget.deal.getTypeColor(),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                widget.deal.name,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                widget.deal.location,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Text(
                    widget.deal.displayDiscountedPrice,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: widget.deal.getTypeColor(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    widget.deal.displayOriginalPrice,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      decoration: TextDecoration.lineThrough,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${widget.deal.discountPercentage}% OFF',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: Colors.green,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              _buildCountdown(context, isExpired),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCountdown(BuildContext context, bool isExpired) {
    final theme = Theme.of(context);

    if (isExpired) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: theme.colorScheme.errorContainer.withOpacity(0.3),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(
              Icons.timer_off_rounded,
              color: theme.colorScheme.error,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              'Deal Expired',
              style: theme.textTheme.labelMedium?.copyWith(
                color: theme.colorScheme.error,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
    }

    final hours = _timeRemaining.inHours;
    final minutes = _timeRemaining.inMinutes % 60;
    final seconds = _timeRemaining.inSeconds % 60;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const Icon(Icons.timer_rounded, color: Colors.red, size: 20),
          const SizedBox(width: 8),
          Text(
            'Ends in: ',
            style: theme.textTheme.labelMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          Text(
            '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}',
            style: theme.textTheme.labelMedium?.copyWith(
              color: Colors.red,
              fontWeight: FontWeight.w700,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }
}

/// Modern recommendation card with reason display
class ModernRecommendationCard extends StatefulWidget {
  final RecommendedTour recommendation;
  final VoidCallback? onTap;

  const ModernRecommendationCard({
    super.key,
    required this.recommendation,
    this.onTap,
  });

  @override
  State<ModernRecommendationCard> createState() =>
      _ModernRecommendationCardState();
}

class _ModernRecommendationCardState extends State<ModernRecommendationCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tour = widget.recommendation.tour;

    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Card(
            elevation: 0,
            color: theme.colorScheme.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(
                color: theme.colorScheme.outline.withOpacity(0.2),
              ),
            ),
            child: InkWell(
              onTap: widget.onTap,
              onTapDown: (_) {
                setState(() => _isPressed = true);
                _animationController.forward();
              },
              onTapUp: (_) {
                setState(() => _isPressed = false);
                _animationController.reverse();
              },
              onTapCancel: () {
                setState(() => _isPressed = false);
                _animationController.reverse();
              },
              borderRadius: BorderRadius.circular(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Image Section
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                    child: Stack(
                      children: [
                        Container(
                          height: 200,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                theme.colorScheme.primaryContainer.withOpacity(
                                  0.3,
                                ),
                                theme.colorScheme.secondaryContainer
                                    .withOpacity(0.3),
                              ],
                            ),
                          ),
                          child:
                              tour.mainImageUrl != null
                                  ? Image.network(
                                    tour.mainImageUrl!,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return _buildImagePlaceholder(context);
                                    },
                                  )
                                  : _buildImagePlaceholder(context),
                        ),
                        Positioned(
                          top: 12,
                          left: 12,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.star_rounded,
                                  color: theme.colorScheme.onPrimary,
                                  size: 16,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'RECOMMENDED',
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: theme.colorScheme.onPrimary,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        if (tour.hasDiscount)
                          Positioned(
                            top: 12,
                            right: 12,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.red,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                '${tour.discountPercentage}% OFF',
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  // Content Section
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Recommendation reason
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.secondaryContainer
                                .withOpacity(0.5),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.lightbulb_outline_rounded,
                                color: theme.colorScheme.secondary,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  widget.recommendation.reasonForRecommendation,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color:
                                        theme.colorScheme.onSecondaryContainer,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        // Tour name and location
                        Text(
                          tour.name,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.location_on_outlined,
                              size: 16,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                tour.location,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        // Tour details
                        Row(
                          children: [
                            _buildDetailChip(
                              context,
                              tour.durationText,
                              Icons.schedule_rounded,
                            ),
                            const SizedBox(width: 8),
                            _buildDetailChip(
                              context,
                              tour.difficultyLevel,
                              Icons.signal_cellular_alt_rounded,
                              color: tour.difficultyColor,
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        // Price
                        Row(
                          children: [
                            if (tour.hasDiscount) ...[
                              Text(
                                tour.displayPrice,
                                style: theme.textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                tour.originalPrice,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  decoration: TextDecoration.lineThrough,
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ] else
                              Text(
                                tour.displayPrice,
                                style: theme.textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: theme.colorScheme.primary,
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
      },
    );
  }

  Widget _buildImagePlaceholder(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      color: theme.colorScheme.surfaceContainerHighest,
      child: Center(
        child: Icon(
          Icons.image_rounded,
          size: 64,
          color: theme.colorScheme.onSurfaceVariant.withOpacity(0.5),
        ),
      ),
    );
  }

  Widget _buildDetailChip(
    BuildContext context,
    String label,
    IconData icon, {
    Color? color,
  }) {
    final theme = Theme.of(context);
    final chipColor = color ?? theme.colorScheme.onSurfaceVariant;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: chipColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: chipColor),
          const SizedBox(width: 4),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: chipColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

/// Modern tour card widget
class ModernTourCard extends StatelessWidget {
  final Tour tour;
  final VoidCallback? onTap;
  final bool showDiscount;

  const ModernTourCard({
    super.key,
    required this.tour,
    this.onTap,
    this.showDiscount = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      color: theme.colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: theme.colorScheme.outline.withOpacity(0.2)),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Section
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
              child: Stack(
                children: [
                  Container(
                    height: 180,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          theme.colorScheme.primaryContainer.withOpacity(0.3),
                          theme.colorScheme.secondaryContainer.withOpacity(0.3),
                        ],
                      ),
                    ),
                    child:
                        tour.mainImageUrl != null
                            ? Image.network(
                              tour.mainImageUrl!,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return _buildImagePlaceholder(context);
                              },
                            )
                            : _buildImagePlaceholder(context),
                  ),
                  if (showDiscount && tour.hasDiscount)
                    Positioned(
                      top: 12,
                      right: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${tour.discountPercentage}% OFF',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  Positioned(
                    bottom: 12,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        tour.category,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Content Section
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tour.name,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on_outlined,
                        size: 16,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          tour.location,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _buildDetailChip(
                        context,
                        tour.durationText,
                        Icons.schedule_rounded,
                      ),
                      const SizedBox(width: 8),
                      _buildDetailChip(
                        context,
                        tour.difficultyLevel,
                        Icons.signal_cellular_alt_rounded,
                        color: tour.difficultyColor,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      if (tour.hasDiscount) ...[
                        Text(
                          tour.displayPrice,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          tour.originalPrice,
                          style: theme.textTheme.bodySmall?.copyWith(
                            decoration: TextDecoration.lineThrough,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ] else
                        Text(
                          tour.displayPrice,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      const Spacer(),
                      if (tour.averageRating != null) ...[
                        const Icon(
                          Icons.star_rounded,
                          size: 16,
                          color: Colors.amber,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          tour.averageRating!.toStringAsFixed(1),
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePlaceholder(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      color: theme.colorScheme.surfaceContainerHighest,
      child: Center(
        child: Icon(
          Icons.image_rounded,
          size: 64,
          color: theme.colorScheme.onSurfaceVariant.withOpacity(0.5),
        ),
      ),
    );
  }

  Widget _buildDetailChip(
    BuildContext context,
    String label,
    IconData icon, {
    Color? color,
  }) {
    final theme = Theme.of(context);
    final chipColor = color ?? theme.colorScheme.onSurfaceVariant;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: chipColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: chipColor),
          const SizedBox(width: 4),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: chipColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

/// Modern seasonal offer card
class ModernSeasonalOfferCard extends StatelessWidget {
  final SeasonalOffer offer;
  final VoidCallback? onTap;

  const ModernSeasonalOfferCard({super.key, required this.offer, this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final seasonColor = offer.getSeasonColor();

    return Card(
      elevation: 0,
      color: theme.colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: seasonColor.withOpacity(0.3), width: 2),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [seasonColor.withOpacity(0.1), theme.colorScheme.surface],
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: seasonColor.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      offer.getSeasonIcon(),
                      color: seasonColor,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${offer.season} Special',
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: seasonColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          offer.type.toUpperCase(),
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                offer.name,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Icons.location_on_outlined,
                    size: 16,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    offer.location,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: seasonColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  offer.seasonalHighlight,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: seasonColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Text(
                    offer.displayPrice,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: seasonColor,
                    ),
                  ),
                  if (offer.hasDiscount) ...[
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        offer.displayDiscount,
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: Colors.green,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Modern action card for quick actions
class ModernActionCard extends StatefulWidget {
  final String title;
  final String? subtitle;
  final IconData icon;
  final VoidCallback? onTap;
  final Color? color;
  final bool isEnabled;

  const ModernActionCard({
    super.key,
    required this.title,
    this.subtitle,
    required this.icon,
    this.onTap,
    this.color,
    this.isEnabled = true,
  });

  @override
  State<ModernActionCard> createState() => _ModernActionCardState();
}

class _ModernActionCardState extends State<ModernActionCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final actionColor = widget.color ?? theme.colorScheme.primary;
    final isDisabled = !widget.isEnabled;

    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Card(
            elevation: 0,
            color: theme.colorScheme.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(
                color:
                    isDisabled
                        ? theme.colorScheme.outline.withOpacity(0.2)
                        : actionColor.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: InkWell(
              onTap: isDisabled ? null : widget.onTap,
              onTapDown:
                  isDisabled ? null : (_) => _animationController.forward(),
              onTapUp:
                  isDisabled ? null : (_) => _animationController.reverse(),
              onTapCancel:
                  isDisabled ? null : () => _animationController.reverse(),
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient:
                      isDisabled
                          ? null
                          : LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              actionColor.withOpacity(0.1),
                              theme.colorScheme.surface,
                            ],
                          ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color:
                            isDisabled
                                ? theme.colorScheme.surfaceContainerHighest
                                : actionColor.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        widget.icon,
                        size: 32,
                        color:
                            isDisabled
                                ? theme.colorScheme.onSurfaceVariant
                                : actionColor,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      widget.title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color:
                            isDisabled
                                ? theme.colorScheme.onSurfaceVariant
                                : null,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    if (widget.subtitle != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        widget.subtitle!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color:
                              isDisabled
                                  ? theme.colorScheme.onSurfaceVariant
                                      .withOpacity(0.7)
                                  : theme.colorScheme.onSurfaceVariant,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
