import 'package:flutter/material.dart';

/// A basic layout that wraps every screen with a standard [Scaffold].
/// If the child already provides its own [Scaffold], it will be returned
/// directly so that existing pages are unaffected.
class AppLayout extends StatelessWidget {
  final Widget child;
  final PreferredSizeWidget? appBar;

  const AppLayout({super.key, required this.child, this.appBar});

  @override
  Widget build(BuildContext context) {
    if (child is Scaffold) {
      return child;
    }

    return Scaffold(
      appBar: appBar ?? AppBar(title: const Text('TourApp')),
      body: child,
    );
  }
}
