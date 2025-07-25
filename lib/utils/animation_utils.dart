import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Animation constants for consistent timing across the app
class AnimationDurations {
  static const Duration instant = Duration(milliseconds: 100);
  static const Duration fast = Duration(milliseconds: 200);
  static const Duration normal = Duration(milliseconds: 300);
  static const Duration slow = Duration(milliseconds: 500);
  static const Duration pageTransition = Duration(milliseconds: 400);
  static const Duration stagger = Duration(milliseconds: 50);
}

/// Custom curves for smooth animations
class AnimationCurves {
  static const Curve smoothIn = Curves.easeInCubic;
  static const Curve smoothOut = Curves.easeOutCubic;
  static const Curve smoothInOut = Curves.easeInOutCubic;
  static const Curve bounce = Curves.elasticOut;
  static const Curve overshoot = Curves.easeOutBack;
}

/// Haptic feedback utilities
class HapticUtils {
  static void lightImpact() {
    HapticFeedback.lightImpact();
  }

  static void mediumImpact() {
    HapticFeedback.mediumImpact();
  }

  static void heavyImpact() {
    HapticFeedback.heavyImpact();
  }

  static void selectionClick() {
    HapticFeedback.selectionClick();
  }

  static void vibrate() {
    HapticFeedback.vibrate();
  }
}

/// Staggered animation helper
class StaggeredAnimationHelper {
  static Widget buildStaggeredList({
    required List<Widget> children,
    required Duration baseDelay,
    Duration staggerDelay = const Duration(milliseconds: 50),
    Curve curve = Curves.easeOutCubic,
  }) {
    return Column(
      children: List.generate(children.length, (index) {
        return TweenAnimationBuilder<double>(
          duration: baseDelay + (staggerDelay * index),
          tween: Tween(begin: 0.0, end: 1.0),
          curve: curve,
          builder: (context, value, child) {
            return Transform.translate(
              offset: Offset(0, 20 * (1 - value)),
              child: Opacity(opacity: value, child: child),
            );
          },
          child: children[index],
        );
      }),
    );
  }
}

/// Page route with custom transitions
class SmoothPageRoute<T> extends PageRouteBuilder<T> {
  final Widget page;
  final Duration duration;
  final Curve curve;

  SmoothPageRoute({
    required this.page,
    this.duration = const Duration(milliseconds: 400),
    this.curve = Curves.easeInOutCubic,
  }) : super(
         pageBuilder: (context, animation, secondaryAnimation) => page,
         transitionDuration: duration,
         reverseTransitionDuration: duration,
         transitionsBuilder: (context, animation, secondaryAnimation, child) {
           const begin = Offset(1.0, 0.0);
           const end = Offset.zero;

           var tween = Tween(
             begin: begin,
             end: end,
           ).chain(CurveTween(curve: curve));

           var offsetAnimation = animation.drive(tween);
           var fadeAnimation = animation.drive(
             Tween(
               begin: 0.0,
               end: 1.0,
             ).chain(CurveTween(curve: Curves.easeIn)),
           );

           return SlideTransition(
             position: offsetAnimation,
             child: FadeTransition(opacity: fadeAnimation, child: child),
           );
         },
       );
}

/// Fade page route
class FadePageRoute<T> extends PageRouteBuilder<T> {
  final Widget page;
  final Duration duration;

  FadePageRoute({
    required this.page,
    this.duration = const Duration(milliseconds: 300),
  }) : super(
         pageBuilder: (context, animation, secondaryAnimation) => page,
         transitionDuration: duration,
         transitionsBuilder: (context, animation, secondaryAnimation, child) {
           return FadeTransition(opacity: animation, child: child);
         },
       );
}

/// Scale page route with fade
class ScalePageRoute<T> extends PageRouteBuilder<T> {
  final Widget page;
  final Duration duration;
  final Curve curve;

  ScalePageRoute({
    required this.page,
    this.duration = const Duration(milliseconds: 350),
    this.curve = Curves.easeOutBack,
  }) : super(
         pageBuilder: (context, animation, secondaryAnimation) => page,
         transitionDuration: duration,
         transitionsBuilder: (context, animation, secondaryAnimation, child) {
           var scaleAnimation = animation.drive(
             Tween(begin: 0.8, end: 1.0).chain(CurveTween(curve: curve)),
           );

           var fadeAnimation = animation.drive(
             Tween(
               begin: 0.0,
               end: 1.0,
             ).chain(CurveTween(curve: Curves.easeIn)),
           );

           return ScaleTransition(
             scale: scaleAnimation,
             child: FadeTransition(opacity: fadeAnimation, child: child),
           );
         },
       );
}

/// Parallax scroll effect widget
class ParallaxWidget extends StatelessWidget {
  final Widget child;
  final double parallaxFactor;

  const ParallaxWidget({
    super.key,
    required this.child,
    this.parallaxFactor = 0.5,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return NotificationListener<ScrollNotification>(
          onNotification: (notification) {
            if (notification is ScrollUpdateNotification) {
              // Calculate parallax offset based on scroll position
              final scrollOffset = notification.metrics.pixels;
              final viewportDimension = notification.metrics.viewportDimension;
              final parallaxOffset = scrollOffset * parallaxFactor;

              return true;
            }
            return false;
          },
          child: child,
        );
      },
    );
  }
}

/// Shimmer effect widget
class ShimmerEffect extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final Color baseColor;
  final Color highlightColor;

  const ShimmerEffect({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 1500),
    this.baseColor = const Color(0xFFE0E0E0),
    this.highlightColor = const Color(0xFFF5F5F5),
  });

  @override
  State<ShimmerEffect> createState() => _ShimmerEffectState();
}

class _ShimmerEffectState extends State<ShimmerEffect>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: widget.duration, vsync: this)
      ..repeat();

    _animation = Tween<double>(
      begin: -1.0,
      end: 2.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.linear));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return ShaderMask(
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                widget.baseColor,
                widget.highlightColor,
                widget.baseColor,
              ],
              stops: [
                _animation.value - 0.3,
                _animation.value,
                _animation.value + 0.3,
              ],
              transform: const GradientRotation(0.5),
            ).createShader(bounds);
          },
          blendMode: BlendMode.srcIn,
          child: widget.child,
        );
      },
    );
  }
}

/// Bounce animation widget
class BounceAnimation extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final Duration duration;
  final double scaleFactor;

  const BounceAnimation({
    super.key,
    required this.child,
    this.onTap,
    this.duration = const Duration(milliseconds: 150),
    this.scaleFactor = 0.95,
  });

  @override
  State<BounceAnimation> createState() => _BounceAnimationState();
}

class _BounceAnimationState extends State<BounceAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: widget.duration, vsync: this);

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: widget.scaleFactor,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    _controller.forward();
    HapticUtils.lightImpact();
  }

  void _handleTapUp(TapUpDetails details) {
    _controller.reverse();
    widget.onTap?.call();
  }

  void _handleTapCancel() {
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: widget.child,
          );
        },
      ),
    );
  }
}

/// Animated visibility widget with multiple effects
class AnimatedVisibility extends StatelessWidget {
  final bool visible;
  final Widget child;
  final Duration duration;
  final Curve curve;
  final Axis direction;

  const AnimatedVisibility({
    super.key,
    required this.visible,
    required this.child,
    this.duration = const Duration(milliseconds: 300),
    this.curve = Curves.easeInOut,
    this.direction = Axis.vertical,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: duration,
      switchInCurve: curve,
      switchOutCurve: curve.flipped,
      transitionBuilder: (child, animation) {
        final offsetAnimation = Tween<Offset>(
          begin:
              direction == Axis.vertical
                  ? const Offset(0, 0.2)
                  : const Offset(0.2, 0),
          end: Offset.zero,
        ).animate(animation);

        return SlideTransition(
          position: offsetAnimation,
          child: FadeTransition(opacity: animation, child: child),
        );
      },
      child: visible ? child : const SizedBox.shrink(key: ValueKey('empty')),
    );
  }
}

/// Pull to refresh with custom animation
class CustomRefreshIndicator extends StatelessWidget {
  final Widget child;
  final Future<void> Function() onRefresh;
  final Color? color;
  final Color? backgroundColor;

  const CustomRefreshIndicator({
    super.key,
    required this.child,
    required this.onRefresh,
    this.color,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return RefreshIndicator(
      onRefresh: () async {
        HapticUtils.mediumImpact();
        await onRefresh();
      },
      color: color ?? theme.colorScheme.primary,
      backgroundColor: backgroundColor ?? theme.colorScheme.surface,
      strokeWidth: 3,
      displacement: 60,
      child: child,
    );
  }
}
