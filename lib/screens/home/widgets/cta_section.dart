import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CTASection extends StatefulWidget {
  const CTASection({super.key});

  @override
  State<CTASection> createState() => _CTASectionState();
}

class _CTASectionState extends State<CTASection>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 0.95,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    _animationController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.all(24),
      child: Column(
        children: [
          AnimatedBuilder(
            animation: _scaleAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _scaleAnimation.value,
                child: Container(
                  padding: const EdgeInsets.all(40),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        colorScheme.primary,
                        colorScheme.secondary,
                        colorScheme.tertiary,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(32),
                    boxShadow: [
                      BoxShadow(
                        color: colorScheme.primary.withValues(alpha: 0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.travel_explore_rounded,
                        size: 64,
                        color: Colors.white,
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Ready for Your Next Adventure?',
                        style: Theme.of(context).textTheme.displaySmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Join thousands of satisfied travelers who have discovered amazing destinations with AlbTour. Start planning your perfect trip today!',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Colors.white.withValues(alpha: 0.9),
                          height: 1.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 32),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildCTAButton(
                            context,
                            icon: Icons.tour_rounded,
                            label: 'Explore Tours',
                            onTap: () {
                              HapticFeedback.lightImpact();
                              Navigator.pushNamed(context, '/tours');
                            },
                            isPrimary: true,
                          ),
                          const SizedBox(width: 16),
                          _buildCTAButton(
                            context,
                            icon: Icons.contact_support_rounded,
                            label: 'Get Started',
                            onTap: () {
                              HapticFeedback.lightImpact();
                              _showGetStartedDialog(context);
                            },
                            isPrimary: false,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 40),
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainer,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: colorScheme.outline.withValues(alpha: 0.2),
              ),
            ),
            child: Column(
              children: [
                Text(
                  'Why Choose AlbTour?',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: _buildFeatureItem(
                        context,
                        icon: Icons.verified_rounded,
                        title: 'Trusted',
                        description: 'Verified partners and secure booking',
                      ),
                    ),
                    Expanded(
                      child: _buildFeatureItem(
                        context,
                        icon: Icons.support_agent_rounded,
                        title: '24/7 Support',
                        description: 'Always here when you need us',
                      ),
                    ),
                    Expanded(
                      child: _buildFeatureItem(
                        context,
                        icon: Icons.price_check_rounded,
                        title: 'Best Prices',
                        description: 'Competitive rates guaranteed',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCTAButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required bool isPrimary,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          decoration: BoxDecoration(
            color: isPrimary
                ? Colors.white
                : Colors.white.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(16),
            border: isPrimary
                ? null
                : Border.all(
                    color: Colors.white.withValues(alpha: 0.5),
                    width: 2,
                  ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: isPrimary ? colorScheme.primary : Colors.white,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: isPrimary ? colorScheme.primary : Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: colorScheme.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(
            icon,
            color: colorScheme.primary,
            size: 32,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        Text(
          description,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurface.withValues(alpha: 0.7),
            height: 1.3,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  void _showGetStartedDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Row(
          children: [
            Icon(
              Icons.rocket_launch_rounded,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 8),
            const Text('Get Started'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Choose how you\'d like to begin your journey:',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            _buildDialogOption(
              context,
              icon: Icons.tour_rounded,
              title: 'Browse Tours',
              subtitle: 'Discover amazing destinations',
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/tours');
              },
            ),
            const SizedBox(height: 12),
            _buildDialogOption(
              context,
              icon: Icons.directions_car_rounded,
              title: 'Rent a Car',
              subtitle: 'Find the perfect vehicle',
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/cars');
              },
            ),
            const SizedBox(height: 12),
            _buildDialogOption(
              context,
              icon: Icons.home_rounded,
              title: 'Book Accommodation',
              subtitle: 'Find your perfect stay',
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/houses');
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Maybe Later'),
          ),
        ],
      ),
    );
  }

  Widget _buildDialogOption(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainer,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: colorScheme.outline.withValues(alpha: 0.2),
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: colorScheme.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16,
                color: colorScheme.onSurface.withValues(alpha: 0.5),
              ),
            ],
          ),
        ),
      ),
    );
  }
}