import 'package:flutter/material.dart';

/// Custom page route that provides seamless transitions between screens
class SeamlessPageRoute<T> extends PageRoute<T> {
  final Widget page;
  final Duration duration;
  final Curve curve;

  SeamlessPageRoute({
    required this.page,
    this.duration = const Duration(milliseconds: 300),
    this.curve = Curves.easeInOut,
    super.settings,
  });

  @override
  bool get opaque => false;

  @override
  Color? get barrierColor => null;

  @override
  String? get barrierLabel => null;

  @override
  bool get maintainState => true;

  @override
  Duration get transitionDuration => duration;

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    return page;
  }

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(1.0, 0.0),
        end: Offset.zero,
      ).animate(CurvedAnimation(parent: animation, curve: curve)),
      child: FadeTransition(
        opacity: animation,
        child: child,
      ),
    );
  }
}

/// Show a seamless page transition
void showSeamlessPage(BuildContext context, Widget page) {
  Navigator.of(context).push(SeamlessPageRoute(page: page));
}

/// Replace current page with seamless transition
void replaceSeamlessPage(BuildContext context, Widget page) {
  Navigator.of(context).pushReplacement(SeamlessPageRoute(page: page));
}