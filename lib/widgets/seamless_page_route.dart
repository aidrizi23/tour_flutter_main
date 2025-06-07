import 'package:flutter/material.dart';

Future<T?> showSeamlessPage<T>(BuildContext context, WidgetBuilder builder) {
  return Navigator.of(context).push(_SeamlessPageRoute<T>(builder));
}

class _SeamlessPageRoute<T> extends PageRouteBuilder<T> {
  _SeamlessPageRoute(this.builder)
    : super(
        pageBuilder: (context, animation, secondaryAnimation) =>
            builder(context),
        opaque: false,
        barrierColor: Colors.black54,
        barrierDismissible: true,
        transitionDuration: const Duration(milliseconds: 300),
        reverseTransitionDuration: const Duration(milliseconds: 300),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          final curved = CurvedAnimation(
            parent: animation,
            curve: Curves.easeOut,
          );
          return FadeTransition(
            opacity: curved,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.1),
                end: Offset.zero,
              ).animate(curved),
              child: child,
            ),
          );
        },
      );

  final WidgetBuilder builder;
}
