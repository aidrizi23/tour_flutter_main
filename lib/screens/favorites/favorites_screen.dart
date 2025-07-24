import 'package:flutter/material.dart';

/// Simple placeholder screen for saved items.
class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Favorites')),
      body: const Center(
        child: Text('No favorites yet', style: TextStyle(fontSize: 18)),
      ),
    );
  }
}
