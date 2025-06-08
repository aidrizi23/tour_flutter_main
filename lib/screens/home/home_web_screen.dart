import 'package:flutter/material.dart';
import 'widgets/hero_section.dart';
import 'widgets/features_section.dart';

/// A simple landing page styled like a modern website.
class HomeWebScreen extends StatelessWidget {
  const HomeWebScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
        title: Text(
          'TourApp',
          style: Theme.of(context)
              .textTheme
              .titleLarge
              ?.copyWith(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pushNamed(context, '/tours'),
            style: TextButton.styleFrom(foregroundColor: Colors.white),
            child: const Text('Tours'),
          ),
          TextButton(
            onPressed: () => Navigator.pushNamed(context, '/cars'),
            style: TextButton.styleFrom(foregroundColor: Colors.white),
            child: const Text('Cars'),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: const CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: HomeHeroSection()),
          SliverToBoxAdapter(child: HomeFeaturesSection()),
          SliverToBoxAdapter(child: SizedBox(height: 40)),
        ],
      ),
    );
  }
}
