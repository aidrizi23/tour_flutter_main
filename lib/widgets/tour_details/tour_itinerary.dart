import 'package:flutter/material.dart';
import '../../models/tour_models.dart';

class TourItinerary extends StatefulWidget {
  final Tour tour;
  final bool isDesktop;

  const TourItinerary({
    super.key,
    required this.tour,
    this.isDesktop = false,
  });

  @override
  State<TourItinerary> createState() => _TourItineraryState();
}

class _TourItineraryState extends State<TourItinerary> {
  int? _selectedDay;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    if (widget.tour.itineraryItems.isEmpty) {
      return const SizedBox.shrink();
    }

    // Group itinerary items by day
    final Map<int, List<ItineraryItem>> groupedItems = {};
    for (final item in widget.tour.itineraryItems) {
      groupedItems.putIfAbsent(item.dayNumber, () => []).add(item);
    }

    return Container(
      padding: EdgeInsets.all(widget.isDesktop ? 32 : 24),
      margin: EdgeInsets.symmetric(horizontal: widget.isDesktop ? 0 : 16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.route_rounded,
                  color: colorScheme.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Text(
                'Tour Itinerary',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          Text(
            '${widget.tour.durationInDays} day${widget.tour.durationInDays != 1 ? 's' : ''} of adventure',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: colorScheme.onSurface.withValues(alpha: 0.7),
              fontWeight: FontWeight.w500,
            ),
          ),

          const SizedBox(height: 24),

          // Day tabs if there are multiple days
          if (groupedItems.length > 1) ...[
            SizedBox(
              height: 50,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: groupedItems.length,
                itemBuilder: (context, index) {
                  final dayNumber = groupedItems.keys.elementAt(index);
                  final isSelected = _selectedDay == dayNumber || 
                      (_selectedDay == null && index == 0);
                  
                  return Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedDay = dayNumber;
                        });
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected 
                              ? colorScheme.primary 
                              : colorScheme.surfaceContainer,
                          borderRadius: BorderRadius.circular(25),
                          border: Border.all(
                            color: isSelected 
                                ? colorScheme.primary 
                                : colorScheme.outline.withValues(alpha: 0.2),
                          ),
                        ),
                        child: Text(
                          'Day $dayNumber',
                          style: TextStyle(
                            color: isSelected 
                                ? colorScheme.onPrimary 
                                : colorScheme.onSurface,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 24),
          ],

          // Itinerary items
          _buildItineraryItems(groupedItems, colorScheme),
        ],
      ),
    );
  }

  Widget _buildItineraryItems(
    Map<int, List<ItineraryItem>> groupedItems,
    ColorScheme colorScheme,
  ) {
    if (groupedItems.isEmpty) return const SizedBox.shrink();

    // Show selected day or first day if none selected
    final displayDay = _selectedDay ?? groupedItems.keys.first;
    final items = groupedItems[displayDay] ?? [];

    if (groupedItems.length == 1) {
      // If only one day, show all items
      return _buildDayItinerary(widget.tour.itineraryItems, colorScheme);
    }

    return _buildDayItinerary(items, colorScheme);
  }

  Widget _buildDayItinerary(List<ItineraryItem> items, ColorScheme colorScheme) {
    return Column(
      children: items.asMap().entries.map((entry) {
        final index = entry.key;
        final item = entry.value;
        final isLast = index == items.length - 1;

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Timeline
            Column(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: colorScheme.primary,
                      width: 2,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      '${index + 1}',
                      style: TextStyle(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
                if (!isLast)
                  Container(
                    width: 2,
                    height: 60,
                    color: colorScheme.outline.withValues(alpha: 0.3),
                  ),
              ],
            ),

            const SizedBox(width: 16),

            // Content
            Expanded(
              child: Container(
                margin: EdgeInsets.only(bottom: isLast ? 0 : 20),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainer,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: colorScheme.outline.withValues(alpha: 0.1),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Time and activity type
                    Row(
                      children: [
                        if (item.startTime != null) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: colorScheme.secondaryContainer,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.schedule_rounded,
                                  size: 14,
                                  color: colorScheme.onSecondaryContainer,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  item.endTime != null 
                                      ? '${item.startTime} - ${item.endTime}'
                                      : item.startTime!,
                                  style: TextStyle(
                                    color: colorScheme.onSecondaryContainer,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                        ],
                        if (item.activityType != null)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: colorScheme.tertiaryContainer,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              item.activityType!,
                              style: TextStyle(
                                color: colorScheme.onTertiaryContainer,
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                              ),
                            ),
                          ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // Title
                    Text(
                      item.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                    ),

                    const SizedBox(height: 8),

                    // Description
                    Text(
                      item.description,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurface.withValues(alpha: 0.8),
                        height: 1.5,
                      ),
                    ),

                    // Location
                    if (item.location != null) ...[
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Icon(
                            Icons.location_on_outlined,
                            size: 16,
                            color: colorScheme.primary,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              item.location!,
                              style: TextStyle(
                                color: colorScheme.primary,
                                fontWeight: FontWeight.w500,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        );
      }).toList(),
    );
  }
}