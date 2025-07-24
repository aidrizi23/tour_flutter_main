import 'package:flutter/material.dart';

class DesktopScaffold extends StatefulWidget {
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;
  final List<NavigationRailDestination> destinations;
  final Widget body;

  const DesktopScaffold({
    super.key,
    required this.selectedIndex,
    required this.onDestinationSelected,
    required this.destinations,
    required this.body,
  });

  @override
  State<DesktopScaffold> createState() => _DesktopScaffoldState();
}

class _DesktopScaffoldState extends State<DesktopScaffold> {
  bool _isExtended = true;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: widget.selectedIndex,
            onDestinationSelected: widget.onDestinationSelected,
            extended: _isExtended,
            leading: IconButton(
              icon: Icon(_isExtended ? Icons.menu_open : Icons.menu),
              onPressed: () {
                setState(() {
                  _isExtended = !_isExtended;
                });
              },
            ),
            destinations: widget.destinations,
            backgroundColor: colorScheme.surface,
            indicatorColor: colorScheme.primary.withOpacity(0.1),
            selectedIconTheme: IconThemeData(color: colorScheme.primary),
          ),
          const VerticalDivider(width: 1),
          Expanded(child: widget.body),
        ],
      ),
    );
  }
}
