import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'responsive_sidebar.dart';

class ResponsiveLayout extends StatefulWidget {
  final Widget child;
  final int currentIndex;
  final Function(int) onDestinationSelected;
  final bool isAdmin;

  const ResponsiveLayout({
    super.key,
    required this.child,
    required this.currentIndex,
    required this.onDestinationSelected,
    required this.isAdmin,
  });

  @override
  State<ResponsiveLayout> createState() => _ResponsiveLayoutState();
}

class _ResponsiveLayoutState extends State<ResponsiveLayout>
    with TickerProviderStateMixin {
  bool _isSidebarCollapsed = false;
  late AnimationController _sidebarController;
  late Animation<double> _sidebarAnimation;

  @override
  void initState() {
    super.initState();
    _sidebarController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _sidebarAnimation = CurvedAnimation(
      parent: _sidebarController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _sidebarController.dispose();
    super.dispose();
  }

  void _toggleSidebar() {
    setState(() {
      _isSidebarCollapsed = !_isSidebarCollapsed;
    });
    if (_isSidebarCollapsed) {
      _sidebarController.reverse();
    } else {
      _sidebarController.forward();
    }
    HapticFeedback.lightImpact();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;

    if (isMobile) {
      return Scaffold(
        body: widget.child,
        bottomNavigationBar: ResponsiveSidebar(
          currentIndex: widget.currentIndex,
          onDestinationSelected: widget.onDestinationSelected,
          isAdmin: widget.isAdmin,
        ),
      );
    } else {
      return Scaffold(
        body: Row(
          children: [
            ResponsiveSidebar(
              currentIndex: widget.currentIndex,
              onDestinationSelected: widget.onDestinationSelected,
              isAdmin: widget.isAdmin,
              isExtended: !_isSidebarCollapsed,
            ),
            Expanded(
              child: Column(
                children: [
                  _buildTopBar(),
                  Expanded(child: widget.child),
                ],
              ),
            ),
          ],
        ),
      );
    }
  }



  Widget _buildTopBar() {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: colorScheme.outline.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Row(
          children: [
            // Sidebar toggle button
            IconButton(
              onPressed: _toggleSidebar,
              icon: Icon(
                _isSidebarCollapsed 
                    ? Icons.menu_open_rounded
                    : Icons.menu_rounded,
              ),
              tooltip: _isSidebarCollapsed ? 'Expand sidebar' : 'Collapse sidebar',
            ),
            
            const SizedBox(width: 16),
            
            // App Title
            Expanded(
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [colorScheme.primary, colorScheme.secondary],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.travel_explore_rounded,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'AlbTour',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.primary,
                      letterSpacing: -0.5,
                    ),
                  ),
                ],
              ),
            ),

            // Profile section
            _buildProfileSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileSection() {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        // Notifications
        IconButton(
          onPressed: () {
            HapticFeedback.lightImpact();
            // TODO: Show notifications
          },
          icon: Stack(
            children: [
              Icon(Icons.notifications_outlined, color: colorScheme.onSurface),
              Positioned(
                right: 0,
                top: 0,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: colorScheme.error,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
          tooltip: 'Notifications',
        ),

        const SizedBox(width: 8),

        // Profile avatar and dropdown
        PopupMenuButton<String>(
          offset: const Offset(0, 50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: colorScheme.outline.withValues(alpha: 0.2),
              ),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: colorScheme.primary,
                  child: const Icon(
                    Icons.person_rounded,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'Profile',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
                ),
                const SizedBox(width: 4),
                Icon(
                  Icons.keyboard_arrow_down_rounded,
                  size: 16,
                  color: colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ],
            ),
          ),
          itemBuilder:
              (context) => <PopupMenuEntry<String>>[
                PopupMenuItem<String>(
                  value: 'profile',
                  child: const Row(
                    children: [
                      Icon(Icons.person_outlined),
                      SizedBox(width: 12),
                      Text('My Profile'),
                    ],
                  ),
                ),
                PopupMenuItem<String>(
                  value: 'bookings',
                  child: const Row(
                    children: [
                      Icon(Icons.bookmark_outlined),
                      SizedBox(width: 12),
                      Text('My Bookings'),
                    ],
                  ),
                ),
                PopupMenuItem<String>(
                  value: 'settings',
                  child: const Row(
                    children: [
                      Icon(Icons.settings_outlined),
                      SizedBox(width: 12),
                      Text('Settings'),
                    ],
                  ),
                ),
                const PopupMenuDivider(),
                PopupMenuItem<String>(
                  value: 'logout',
                  child: Row(
                    children: [
                      Icon(Icons.logout_rounded, color: colorScheme.error),
                      const SizedBox(width: 12),
                      Text(
                        'Sign Out',
                        style: TextStyle(color: colorScheme.error),
                      ),
                    ],
                  ),
                ),
              ],
          onSelected: (value) {
            switch (value) {
              case 'profile':
                widget.onDestinationSelected(_getProfileIndex());
                break;
              case 'bookings':
                widget.onDestinationSelected(_getBookingsIndex());
                break;
              case 'settings':
                Navigator.of(context).pushNamed('/settings');
                break;
              case 'logout':
                // TODO: Handle logout
                break;
            }
          },
        ),
      ],
    );
  }

  List<Widget> _getSidebarItems(BuildContext context, bool isCollapsed) {
    final destinations = _getNavigationDestinations(context, false);

    return destinations.asMap().entries.map((entry) {
      final index = entry.key;
      final destination = entry.value;
      final isSelected = index == widget.currentIndex;

      return Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: _buildSidebarItem(
          context: context,
          icon:
              destination.icon is Icon
                  ? (destination.icon as Icon).icon!
                  : Icons.help_outline,
          selectedIcon:
              destination.selectedIcon is Icon
                  ? (destination.selectedIcon as Icon).icon
                  : null,
          label: destination.label,
          isSelected: isSelected,
          onTap: () => widget.onDestinationSelected(index),
          isCollapsed: isCollapsed,
        ),
      );
    }).toList();
  }

  Widget _buildSidebarItem({
    required BuildContext context,
    required IconData icon,
    IconData? selectedIcon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    required bool isCollapsed,
    bool showLabel = true,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          height: 48,
          padding: EdgeInsets.symmetric(
            horizontal: isCollapsed ? 0 : 16,
            vertical: 8,
          ),
          decoration: BoxDecoration(
            color:
                isSelected
                    ? colorScheme.primary.withValues(alpha: 0.1)
                    : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border:
                isSelected
                    ? Border.all(
                      color: colorScheme.primary.withValues(alpha: 0.3),
                      width: 1,
                    )
                    : null,
          ),
          child: Row(
            children: [
              if (isCollapsed)
                Expanded(
                  child: Icon(
                    isSelected && selectedIcon != null ? selectedIcon : icon,
                    color:
                        isSelected
                            ? colorScheme.primary
                            : colorScheme.onSurface.withValues(alpha: 0.7),
                    size: 24,
                  ),
                )
              else ...[
                Icon(
                  isSelected && selectedIcon != null ? selectedIcon : icon,
                  color:
                      isSelected
                          ? colorScheme.primary
                          : colorScheme.onSurface.withValues(alpha: 0.7),
                  size: 24,
                ),
                if (showLabel) ...[
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      label,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color:
                            isSelected
                                ? colorScheme.primary
                                : colorScheme.onSurface,
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                  ),
                ],
              ],
            ],
          ),
        ),
      ),
    );
  }

  List<NavigationDestination> _getNavigationDestinations(
    BuildContext context,
    bool isMobile,
  ) {
    final colorScheme = Theme.of(context).colorScheme;

    return [
      NavigationDestination(
        icon: const Icon(Icons.explore_outlined),
        selectedIcon: Icon(Icons.explore, color: colorScheme.primary),
        label: 'Tours',
      ),
      NavigationDestination(
        icon: const Icon(Icons.recommend_outlined),
        selectedIcon: Icon(Icons.recommend, color: colorScheme.primary),
        label: 'For You',
      ),
      NavigationDestination(
        icon: const Icon(Icons.directions_car_outlined),
        selectedIcon: Icon(Icons.directions_car, color: colorScheme.primary),
        label: 'Cars',
      ),
      NavigationDestination(
        icon: const Icon(Icons.home_outlined),
        selectedIcon: Icon(Icons.home, color: colorScheme.primary),
        label: 'Houses',
      ),
      NavigationDestination(
        icon: const Icon(Icons.bookmark_border_outlined),
        selectedIcon: Icon(Icons.bookmark, color: colorScheme.primary),
        label: 'Bookings',
      ),
      if (widget.isAdmin)
        NavigationDestination(
          icon: const Icon(Icons.admin_panel_settings_outlined),
          selectedIcon: Icon(
            Icons.admin_panel_settings,
            color: colorScheme.primary,
          ),
          label: 'Admin',
        ),
      NavigationDestination(
        icon: const Icon(Icons.person_outline),
        selectedIcon: Icon(Icons.person, color: colorScheme.primary),
        label: 'Profile',
      ),
    ];
  }

  int _getProfileIndex() {
    return widget.isAdmin ? 6 : 5;
  }

  int _getBookingsIndex() {
    return 4;
  }
}
