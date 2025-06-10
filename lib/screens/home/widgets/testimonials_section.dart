import 'dart:async';
import 'package:flutter/material.dart';

class TestimonialsSection extends StatefulWidget {
  const TestimonialsSection({super.key});

  @override
  State<TestimonialsSection> createState() => _TestimonialsSectionState();
}

class _TestimonialsSectionState extends State<TestimonialsSection> {
  final PageController _pageController = PageController(viewportFraction: 0.92);
  int _currentPage = 0;
  Timer? _autoScrollTimer;

  final List<Map<String, dynamic>> _testimonials = [
    {
      'name': 'Sarah Johnson',
      'location': 'New York, USA',
      'rating': 5,
      'comment':
          'AlbTour made our European vacation absolutely perfect! Every detail was taken care of, from the amazing tours to the beautiful accommodations.',
      'avatar': '👩‍💼',
    },
    {
      'name': 'Michael Chen',
      'location': 'Toronto, Canada',
      'rating': 5,
      'comment':
          'Outstanding service and incredible value. The rental car was spotless and the customer support was available 24/7. Highly recommended!',
      'avatar': '👨‍💻',
    },
    {
      'name': 'Emily Rodriguez',
      'location': 'Barcelona, Spain',
      'rating': 5,
      'comment':
          'From booking to checkout, everything was seamless. The house we stayed in exceeded our expectations and the location was perfect.',
      'avatar': '👩‍🎨',
    },
    {
      'name': 'David Wilson',
      'location': 'London, UK',
      'rating': 4,
      'comment':
          'Great platform with fantastic options. The tours were well-organized and our guide was knowledgeable and friendly.',
      'avatar': '👨‍🔬',
    },
  ];

  @override
  void initState() {
    super.initState();
    _startAutoScroll();
  }

  void _startAutoScroll() {
    _autoScrollTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (_pageController.hasClients) {
        final nextPage = (_currentPage + 1) % _testimonials.length;
        _pageController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _autoScrollTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'What Our Travelers Say',
            style: Theme.of(context).textTheme.displaySmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.primary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Real experiences from real travelers',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 32),
          SizedBox(
            height: 280,
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index;
                });
              },
              itemCount: _testimonials.length,
              itemBuilder: (context, index) {
                final testimonial = _testimonials[index];
                return AnimatedScale(
                  duration: const Duration(milliseconds: 400),
                  scale: _currentPage == index ? 1.0 : 0.94,
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 400),
                    opacity: _currentPage == index ? 1.0 : 0.5,
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                      child: _buildTestimonialCard(context, testimonial),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              _testimonials.length,
              (index) => Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color:
                      _currentPage == index
                          ? colorScheme.primary
                          : colorScheme.onSurface.withOpacity(0.3),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTestimonialCard(
    BuildContext context,
    Map<String, dynamic> testimonial,
  ) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [colorScheme.surface, colorScheme.surfaceContainerLow],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Center(
                    child: Text(
                      testimonial['avatar'],
                      style: const TextStyle(fontSize: 24),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        testimonial['name'],
                        style: Theme.of(
                          context,
                        ).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        testimonial['location'],
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurface.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  children: List.generate(
                    5,
                    (index) => Icon(
                      index < testimonial['rating']
                          ? Icons.star
                          : Icons.star_border,
                      size: 20,
                      color: Colors.amber,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainer.withOpacity(0.5),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: colorScheme.outline.withOpacity(0.2)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.format_quote,
                    color: colorScheme.primary,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      testimonial['comment'],
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        height: 1.5,
                        color: colorScheme.onSurface.withOpacity(0.8),
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Icon(Icons.verified, size: 16, color: Colors.green),
                const SizedBox(width: 4),
                Text(
                  'Verified Traveler',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.green,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
