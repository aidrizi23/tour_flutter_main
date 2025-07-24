import 'package:flutter/material.dart';
import 'widgets/hero_section.dart';
import 'widgets/features_section.dart';
import 'widgets/inspiration_section.dart';
import 'widgets/quick_access_section.dart';
import 'widgets/footer.dart';

/// Mobile friendly landing screen using a scrolling layout.
class HomeMobileScreen extends StatelessWidget {
  const HomeMobileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: HomeHeroSection()),
          SliverToBoxAdapter(child: HomeQuickAccessSection()),
          SliverToBoxAdapter(child: HomeFeaturesSection()),
          SliverToBoxAdapter(child: HomeInspirationSection()),
          SliverToBoxAdapter(child: HomeFooter()),
        ],
      ),
    );
  }
}
