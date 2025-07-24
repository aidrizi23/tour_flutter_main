import 'package:flutter/material.dart';

/// Section with quick links to key parts of the app.
class HomeQuickAccessSection extends StatelessWidget {
  const HomeQuickAccessSection({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _QuickAccessButton(
            icon: Icons.tour,
            label: 'Tours',
            onTap: () => Navigator.pushNamed(context, '/tours'),
            color: colorScheme.primary,
          ),
          _QuickAccessButton(
            icon: Icons.house,
            label: 'Houses',
            onTap: () => Navigator.pushNamed(context, '/houses'),
            color: colorScheme.tertiary,
          ),
          _QuickAccessButton(
            icon: Icons.directions_car,
            label: 'Cars',
            onTap: () => Navigator.pushNamed(context, '/cars'),
            color: colorScheme.secondary,
          ),
        ],
      ),
    );
  }
}

class _QuickAccessButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color color;

  const _QuickAccessButton({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }
}
