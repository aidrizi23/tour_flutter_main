import 'package:flutter/material.dart';
import 'feature_card.dart';

class HomeFeaturesSection extends StatelessWidget {
  const HomeFeaturesSection({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Why Choose TourApp?',
                style: Theme.of(context)
                    .textTheme
                    .headlineSmall
                    ?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.primary),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              LayoutBuilder(
                builder: (context, constraints) {
                  int crossAxisCount = 1;
                  if (constraints.maxWidth >= 1200) {
                    crossAxisCount = 3;
                  } else if (constraints.maxWidth >= 800) {
                    crossAxisCount = 2;
                  }

                  final cardWidth =
                      (constraints.maxWidth - (crossAxisCount - 1) * 24) /
                          crossAxisCount;

                  return Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 24,
                    runSpacing: 24,
                    children: [
                      FeatureCard(
                        icon: Icons.public,
                        title: 'Worldwide Tours',
                        description:
                            'Discover amazing places across the globe.',
                        width: cardWidth,
                      ),
                      FeatureCard(
                        icon: Icons.star_outline,
                        title: 'Top Rated Guides',
                        description:
                            'Travel with experienced local guides.',
                        width: cardWidth,
                      ),
                      FeatureCard(
                        icon: Icons.payment,
                        title: 'Secure Payments',
                        description: 'Pay confidently with secure checkout.',
                        width: cardWidth,
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
