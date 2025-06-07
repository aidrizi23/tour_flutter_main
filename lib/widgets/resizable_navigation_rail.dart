import 'package:flutter/material.dart';

class ResizableNavigationRail extends StatefulWidget {
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;
  final List<NavigationRailDestination> destinations;
  final Color backgroundColor;
  final Color indicatorColor;
  final IconThemeData selectedIconTheme;

  const ResizableNavigationRail({
    super.key,
    required this.selectedIndex,
    required this.onDestinationSelected,
    required this.destinations,
    required this.backgroundColor,
    required this.indicatorColor,
    required this.selectedIconTheme,
  });

  @override
  State<ResizableNavigationRail> createState() =>
      _ResizableNavigationRailState();
}

class _ResizableNavigationRailState extends State<ResizableNavigationRail> {
  static const double _minWidth = 72;
  static const double _maxWidth = 240;
  double _width = _minWidth;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: _width,
          child: NavigationRail(
            selectedIndex: widget.selectedIndex,
            onDestinationSelected: widget.onDestinationSelected,
            backgroundColor: widget.backgroundColor,
            indicatorColor: widget.indicatorColor,
            selectedIconTheme: widget.selectedIconTheme,
            extended: _width > 100,
            destinations: widget.destinations,
          ),
        ),
        GestureDetector(
          behavior: HitTestBehavior.translucent,
          onHorizontalDragUpdate: (details) {
            setState(() {
              _width = (_width + details.delta.dx).clamp(_minWidth, _maxWidth);
            });
          },
          child: MouseRegion(
            cursor: SystemMouseCursors.resizeColumn,
            child: Container(
              width: 6,
              height: double.infinity,
              color: Colors.transparent,
            ),
          ),
        ),
      ],
    );
  }
}
