import 'package:flutter/material.dart';
import '../widgets/responsive_layout.dart';

/// Wraps a screen widget with ResponsiveLayout for consistent navigation
class LayoutUtils {
  /// Wraps a screen with ResponsiveLayout for navigation consistency
  static Widget wrapWithResponsiveLayout({
    required Widget child,
    required BuildContext context,
    int currentIndex = 0,
    bool isAdmin = false,
    Function(int)? onDestinationSelected,
  }) {
    return ResponsiveLayout(
      currentIndex: currentIndex,
      onDestinationSelected: onDestinationSelected ?? (index) {
        Navigator.of(context).pop();
      },
      isAdmin: isAdmin,
      child: Container(
        color: Theme.of(context).colorScheme.surfaceContainerLowest,
        child: child,
      ),
    );
  }

  /// Creates a page route with consistent layout wrapping
  static PageRouteBuilder createLayoutRoute({
    required Widget child,
    required BuildContext context,
    int currentIndex = 0,
    bool isAdmin = false,
    Function(int)? onDestinationSelected,
    Duration transitionDuration = const Duration(milliseconds: 400),
  }) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) =>
          wrapWithResponsiveLayout(
            child: child,
            context: context,
            currentIndex: currentIndex,
            isAdmin: isAdmin,
            onDestinationSelected: onDestinationSelected,
          ),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1.0, 0.0),
            end: Offset.zero,
          ).animate(
            CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
            ),
          ),
          child: FadeTransition(
            opacity: animation,
            child: child,
          ),
        );
      },
      transitionDuration: transitionDuration,
    );
  }
}