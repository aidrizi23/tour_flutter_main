import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../providers/theme_provider.dart';

class HeroSection extends StatefulWidget {
  const HeroSection({super.key});

  @override
  State<HeroSection> createState() => _HeroSectionState();
}

class _HeroSectionState extends State<HeroSection>
    with TickerProviderStateMixin {
  late AnimationController _backgroundController;
  late Animation<double> _backgroundAnimation;

  @override
  void initState() {
    super.initState();
    _backgroundController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    );
    _backgroundAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(_backgroundController);
    _backgroundController.repeat();
  }

  @override
  void dispose() {
    _backgroundController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      height: screenSize.height * 0.75,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colorScheme.primary,
            colorScheme.secondary,
            colorScheme.tertiary,
          ],
          stops: const [0.0, 0.6, 1.0],
        ),
      ),
      child: Stack(
        children: [
          AnimatedBuilder(
            animation: _backgroundAnimation,
            builder: (context, child) {
              return Positioned(
                top: 50 + (50 * _backgroundAnimation.value),
                right: 100 + (30 * _backgroundAnimation.value),
                child: Transform.rotate(
                  angle: _backgroundAnimation.value * 2,
                  child: Icon(
                    Icons.travel_explore_rounded,
                    size: 120,
                    color: Colors.white.withValues(alpha: 0.1),
                  ),
                ),
              );
            },
          ),
          AnimatedBuilder(
            animation: _backgroundAnimation,
            builder: (context, child) {
              return Positioned(
                bottom: 100 + (20 * _backgroundAnimation.value),
                left: 50 + (40 * _backgroundAnimation.value),
                child: Transform.rotate(
                  angle: -_backgroundAnimation.value * 1.5,
                  child: Icon(
                    Icons.flight_rounded,
                    size: 80,
                    color: Colors.white.withValues(alpha: 0.08),
                  ),
                ),
              );
            },
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  _buildHeader(context),
                  const Spacer(),
                  _buildMainContent(context),
                  const Spacer(),
                  _buildSearchBar(context),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.travel_explore_rounded,
                color: Colors.white,
                size: 32,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'AlbTour',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                letterSpacing: -0.5,
              ),
            ),
          ],
        ),
        Consumer<ThemeProvider>(
          builder: (context, themeProvider, child) {
            return IconButton(
              onPressed: () {
                HapticFeedback.lightImpact();
                themeProvider.toggleTheme();
              },
              icon: Icon(
                themeProvider.isDarkMode 
                    ? Icons.light_mode_rounded 
                    : Icons.dark_mode_rounded,
                color: Colors.white,
                size: 28,
              ),
              tooltip: 'Toggle theme',
            );
          },
        ),
      ],
    );
  }

  Widget _buildMainContent(BuildContext context) {
    return Column(
      children: [
        Text(
          'Discover Your Next',
          style: Theme.of(context).textTheme.displayMedium?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w300,
            height: 1.1,
          ),
          textAlign: TextAlign.center,
        ),
        Text(
          'Adventure',
          style: Theme.of(context).textTheme.displayMedium?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            height: 1.1,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        Text(
          'Experience the world through our carefully curated tours,\ncomfortable accommodations, and reliable transportation.',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: Colors.white.withValues(alpha: 0.9),
            height: 1.4,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildStatItem('1000+', 'Happy Travelers'),
            Container(
              width: 1,
              height: 40,
              color: Colors.white.withValues(alpha: 0.3),
              margin: const EdgeInsets.symmetric(horizontal: 24),
            ),
            _buildStatItem('50+', 'Destinations'),
            Container(
              width: 1,
              height: 40,
              color: Colors.white.withValues(alpha: 0.3),
              margin: const EdgeInsets.symmetric(horizontal: 24),
            ),
            _buildStatItem('24/7', 'Support'),
          ],
        ),
      ],
    );
  }

  Widget _buildStatItem(String number, String label) {
    return Column(
      children: [
        Text(
          number,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Colors.white.withValues(alpha: 0.8),
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(
            Icons.search_rounded,
            color: Theme.of(context).colorScheme.primary,
            size: 24,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Where would you like to go?',
                border: InputBorder.none,
                hintStyle: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
              onSubmitted: (value) {
                if (value.isNotEmpty) {
                  Navigator.pushNamed(context, '/tours');
                }
              },
            ),
          ),
          const SizedBox(width: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(
              Icons.arrow_forward_rounded,
              color: Colors.white,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }
}