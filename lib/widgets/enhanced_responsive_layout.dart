import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui';
import '../utils/animation_utils.dart';

class EnhancedResponsiveLayout extends StatefulWidget {
  final Widget child;
  final int currentIndex;
  final Function(int) onDestinationSelected;
  final bool isAdmin;

  const EnhancedResponsiveLayout({
    super.key,
    required this.child,
    required this.currentIndex,
    required this.onDestinationSelected,
    this.isAdmin = false,
  });

  @override
  State<EnhancedResponsiveLayout> createState() =>
      _EnhancedResponsiveLayoutState();
}

class _EnhancedResponsiveLayoutState extends State<EnhancedResponsiveLayout>
    with TickerProviderStateMixin {
  late AnimationController _navAnimationController;
  late AnimationController _fabAnimationController;
  late Animation<double> _navScaleAnimation;
  late Animation<double> _fabRotationAnimation;

  bool _isDrawerOpen = false;

  @override
  void initState() {
    super.initState();

    _navAnimationController = AnimationController(
      duration: AnimationDurations.normal,
      vsync: this,
    );

    _fabAnimationController = AnimationController(
      duration: AnimationDurations.slow,
      vsync: this,
    );

    _navScaleAnimation = CurvedAnimation(
      parent: _navAnimationController,
      curve: AnimationCurves.overshoot,
    );

    _fabRotationAnimation = CurvedAnimation(
      parent: _fabAnimationController,
      curve: AnimationCurves.smoothInOut,
    );

    _navAnimationController.forward();
  }

  @override
  void dispose() {
    _navAnimationController.dispose();
    _fabAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 1200;
    final isTablet = screenWidth > 600 && screenWidth <= 1200;
    final isMobile = screenWidth <= 600;

    if (isDesktop) {
      return _buildDesktopLayout();
    } else if (isTablet) {
      return _buildTabletLayout();
    } else {
      return _buildMobileLayout();
    }
  }

  Widget _buildDesktopLayout() {
    return Scaffold(
      body: Row(
        children: [
          _buildEnhancedNavigationRail(expanded: true),
          Expanded(child: widget.child),
        ],
      ),
    );
  }

  Widget _buildTabletLayout() {
    return Scaffold(
      body: Row(
        children: [
          _buildEnhancedNavigationRail(expanded: false),
          Expanded(child: widget.child),
        ],
      ),
    );
  }

  Widget _buildMobileLayout() {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: Stack(
        children: [
          widget.child,

          // Animated Bottom Navigation Bar
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _buildEnhancedBottomNavBar(),
          ),

          // Floating Action Menu
          if (widget.isAdmin)
            Positioned(
              bottom: 90,
              right: 16,
              child: _buildFloatingActionMenu(),
            ),
        ],
      ),
      drawer: _buildEnhancedDrawer(),
    );
  }

  Widget _buildEnhancedNavigationRail({required bool expanded}) {
    final colorScheme = Theme.of(context).colorScheme;
    final destinations = _getNavigationDestinations();

    return AnimatedContainer(
      duration: AnimationDurations.normal,
      width: expanded ? 280 : 80,
      decoration: BoxDecoration(
        color: colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(2, 0),
          ),
        ],
      ),
      child: NavigationRail(
        extended: expanded,
        backgroundColor: Colors.transparent,
        selectedIndex: widget.currentIndex,
        onDestinationSelected: (index) {
          HapticUtils.selectionClick();
          widget.onDestinationSelected(index);
        },
        labelType:
            expanded
                ? NavigationRailLabelType.none
                : NavigationRailLabelType.all,
        leading: Padding(
          padding: const EdgeInsets.symmetric(vertical: 24),
          child: _buildLogo(expanded),
        ),
        destinations:
            destinations.map((dest) {
              return NavigationRailDestination(
                icon: _buildNavIcon(dest.icon, false),
                selectedIcon: _buildNavIcon(dest.icon, true),
                label: Text(dest.label),
              );
            }).toList(),
      ),
    );
  }

  Widget _buildEnhancedBottomNavBar() {
    final colorScheme = Theme.of(context).colorScheme;
    final destinations = _getNavigationDestinations();

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface.withOpacity(0.95),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: AnimatedBuilder(
            animation: _navAnimationController,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(0, 80 * (1 - _navScaleAnimation.value)),
                child: NavigationBar(
                  selectedIndex: widget.currentIndex,
                  onDestinationSelected: (index) {
                    HapticUtils.mediumImpact();
                    widget.onDestinationSelected(index);

                    // Add bounce animation
                    _navAnimationController.reverse().then((_) {
                      _navAnimationController.forward();
                    });
                  },
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  height: 65,
                  destinations:
                      destinations.map((dest) {
                        final isSelected =
                            destinations.indexOf(dest) == widget.currentIndex;

                        return NavigationDestination(
                          icon: Icon(dest.icon),
                          label: dest.label,
                        );
                      }).toList(),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildEnhancedDrawer() {
    final colorScheme = Theme.of(context).colorScheme;
    final destinations = _getNavigationDestinations();

    return Drawer(
      backgroundColor: colorScheme.surface,
      child: Column(
        children: [
          // Header
          Container(
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 24,
              bottom: 24,
              left: 24,
              right: 24,
            ),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [colorScheme.primary, colorScheme.secondary],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.travel_explore_rounded,
                    size: 40,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'TourApp',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Explore the world',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),

          // Navigation Items
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: destinations.length,
              itemBuilder: (context, index) {
                final dest = destinations[index];
                final isSelected = index == widget.currentIndex;

                return AnimatedContainer(
                  duration: AnimationDurations.fast,
                  margin: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color:
                        isSelected
                            ? colorScheme.primaryContainer
                            : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    leading: AnimatedSwitcher(
                      duration: AnimationDurations.fast,
                      child: Icon(
                        dest.icon,
                        key: ValueKey(isSelected),
                        color:
                            isSelected
                                ? colorScheme.primary
                                : colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                    title: Text(
                      dest.label,
                      style: TextStyle(
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.normal,
                        color:
                            isSelected
                                ? colorScheme.primary
                                : colorScheme.onSurface,
                      ),
                    ),
                    onTap: () {
                      HapticUtils.lightImpact();
                      widget.onDestinationSelected(index);
                      Navigator.pop(context);
                    },
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                );
              },
            ),
          ),

          // Footer
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(color: colorScheme.outline.withOpacity(0.2)),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.person_rounded,
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
                        'Welcome back!',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      Text(
                        widget.isAdmin ? 'Admin' : 'User',
                        style: TextStyle(
                          fontSize: 12,
                          color: colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingActionMenu() {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // Menu Items
        AnimatedBuilder(
          animation: _fabRotationAnimation,
          builder: (context, child) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (_fabRotationAnimation.value > 0) ...[
                  Transform.translate(
                    offset: Offset(0, 60 * (1 - _fabRotationAnimation.value)),
                    child: Opacity(
                      opacity: _fabRotationAnimation.value,
                      child: _buildFabMenuItem(
                        icon: Icons.tour_rounded,
                        label: 'Add Tour',
                        onTap: () {
                          HapticUtils.lightImpact();
                          Navigator.pushNamed(context, '/admin/create-tour');
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Transform.translate(
                    offset: Offset(0, 40 * (1 - _fabRotationAnimation.value)),
                    child: Opacity(
                      opacity: _fabRotationAnimation.value,
                      child: _buildFabMenuItem(
                        icon: Icons.directions_car_rounded,
                        label: 'Add Car',
                        onTap: () {
                          HapticUtils.lightImpact();
                          // Navigate to add car
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Transform.translate(
                    offset: Offset(0, 20 * (1 - _fabRotationAnimation.value)),
                    child: Opacity(
                      opacity: _fabRotationAnimation.value,
                      child: _buildFabMenuItem(
                        icon: Icons.home_rounded,
                        label: 'Add House',
                        onTap: () {
                          HapticUtils.lightImpact();
                          // Navigate to add house
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ],
            );
          },
        ),

        // Main FAB
        AnimatedBuilder(
          animation: _fabRotationAnimation,
          builder: (context, child) {
            return Transform.rotate(
              angle: _fabRotationAnimation.value * 0.75 * 3.14159,
              child: FloatingActionButton(
                onPressed: () {
                  HapticUtils.mediumImpact();
                  if (_fabAnimationController.isCompleted) {
                    _fabAnimationController.reverse();
                  } else {
                    _fabAnimationController.forward();
                  }
                },
                backgroundColor: colorScheme.primary,
                child: Icon(
                  _fabRotationAnimation.value > 0.5
                      ? Icons.close_rounded
                      : Icons.add_rounded,
                  color: Colors.white,
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildFabMenuItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Text(
            label,
            style: TextStyle(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.w500,
              fontSize: 12,
            ),
          ),
        ),
        const SizedBox(width: 12),
        BounceAnimation(
          onTap: onTap,
          child: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: colorScheme.secondaryContainer,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: colorScheme.secondary.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(icon, color: colorScheme.secondary, size: 20),
          ),
        ),
      ],
    );
  }

  Widget _buildLogo(bool expanded) {
    final colorScheme = Theme.of(context).colorScheme;

    return AnimatedContainer(
      duration: AnimationDurations.normal,
      padding: EdgeInsets.all(expanded ? 16 : 8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
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
          if (expanded) ...[
            const SizedBox(width: 12),
            Text(
              'TourApp',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildNavIcon(IconData icon, bool isSelected) {
    final colorScheme = Theme.of(context).colorScheme;

    return AnimatedContainer(
      duration: AnimationDurations.fast,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color:
            isSelected
                ? colorScheme.primaryContainer.withOpacity(0.3)
                : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(
        icon,
        size: 24,
        color:
            isSelected
                ? colorScheme.primary
                : colorScheme.onSurface.withOpacity(0.6),
      ),
    );
  }

  List<NavDestination> _getNavigationDestinations() {
    final destinations = [
      const NavDestination(icon: Icons.explore_rounded, label: 'Tours'),
      const NavDestination(icon: Icons.recommend_rounded, label: 'For You'),
      const NavDestination(icon: Icons.directions_car_rounded, label: 'Cars'),
      const NavDestination(icon: Icons.home_rounded, label: 'Stays'),
      const NavDestination(icon: Icons.bookmark_rounded, label: 'Bookings'),
    ];

    if (widget.isAdmin) {
      destinations.add(
        const NavDestination(
          icon: Icons.admin_panel_settings_rounded,
          label: 'Admin',
        ),
      );
    }

    destinations.add(
      const NavDestination(icon: Icons.person_rounded, label: 'Profile'),
    );

    return destinations;
  }
}

class NavDestination {
  final IconData icon;
  final String label;

  const NavDestination({required this.icon, required this.label});
}
