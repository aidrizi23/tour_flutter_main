import 'package:flutter/material.dart';
import '../../../../models/tour_models.dart';

class TourDescriptionSection extends StatefulWidget {
  final Tour tour;

  const TourDescriptionSection({
    super.key,
    required this.tour,
  });

  @override
  State<TourDescriptionSection> createState() => _TourDescriptionSectionState();
}

class _TourDescriptionSectionState extends State<TourDescriptionSection> {
  bool _isExpanded = false;
  static const int _collapsedMaxLines = 4;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.description_rounded,
                color: colorScheme.primary,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                'About This Tour',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          AnimatedSize(
            duration: const Duration(milliseconds: 300),
            child: Text(
              widget.tour.description,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: colorScheme.onSurface.withValues(alpha: 0.8),
                height: 1.6,
              ),
              maxLines: _isExpanded ? null : _collapsedMaxLines,
              overflow: _isExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
            ),
          ),
          if (_shouldShowExpandButton()) ...[
            const SizedBox(height: 12),
            InkWell(
              onTap: () {
                setState(() {
                  _isExpanded = !_isExpanded;
                });
              },
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _isExpanded ? 'Show Less' : 'Read More',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 4),
                    AnimatedRotation(
                      turns: _isExpanded ? 0.5 : 0,
                      duration: const Duration(milliseconds: 300),
                      child: Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: colorScheme.primary,
                        size: 20,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
          if (widget.tour.averageRating != null && widget.tour.reviewCount != null) ...[
            const SizedBox(height: 20),
            Container(
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
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.star_rounded,
                          color: colorScheme.primary,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          widget.tour.averageRating!.toStringAsFixed(1),
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      '${widget.tour.reviewCount} ${widget.tour.reviewCount == 1 ? 'review' : 'reviews'}',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: colorScheme.outline,
                    size: 16,
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  bool _shouldShowExpandButton() {
    // Create a TextPainter to measure the text
    final TextPainter textPainter = TextPainter(
      text: TextSpan(
        text: widget.tour.description,
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
          height: 1.6,
        ),
      ),
      maxLines: _collapsedMaxLines,
      textDirection: TextDirection.ltr,
    );

    // Layout the text with a reasonable width
    textPainter.layout(maxWidth: MediaQuery.of(context).size.width - 88);

    return textPainter.didExceedMaxLines;
  }
}