import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../screens/settings/settings_screen.dart';
import '../providers/theme_provider.dart';

class ResponsiveSidebar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onDestinationSelected;
  final bool isAdmin;
  final bool isExtended;

  const ResponsiveSidebar({
    super.key,
    required this.currentIndex,
    required this.onDestinationSelected,
    required this.isAdmin,
    this.isExtended = true,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;

    if (isMobile) {
      return _buildBottomNavigationBar(context);
    } else {
      return _buildSideNavigationRail(context);
    }
  }

  Widget _buildBottomNavigationBar(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return NavigationBar(
      selectedIndex: currentIndex,
      onDestinationSelected: (index) {
        HapticFeedback.selectionClick();
        if (index == _getDestinations(context).length - 1) {
          // Settings button
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const SettingsScreen()),
          );
        } else {
          onDestinationSelected(index);
        }
      },
      backgroundColor: colorScheme.surface,
      indicatorColor: colorScheme.primaryContainer,
      destinations: [
        ..._getDestinations(context),
        NavigationDestination(
          icon: const Icon(Icons.settings_rounded),
          selectedIcon: Icon(
            Icons.settings_rounded,
            color: colorScheme.primary,
          ),
          label: 'Settings',
        ),
      ],
    );
  }

  Widget _buildSideNavigationRail(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Container(
      width: isExtended ? 280 : 80,
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(
          right: BorderSide(
            color: colorScheme.outline.withValues(alpha: 0.1),
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: EdgeInsets.all(isExtended ? 24 : 16),
              child:
                  isExtended
                      ? Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  colorScheme.primary,
                                  colorScheme.secondary,
                                ],
                              ),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Icon(
                              Icons.travel_explore_rounded,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'AlbTour',
                                  style: Theme.of(
                                    context,
                                  ).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: colorScheme.onSurface,
                                  ),
                                ),
                                Text(
                                  'Travel & Adventure',
                                  style: Theme.of(
                                    context,
                                  ).textTheme.bodySmall?.copyWith(
                                    color: colorScheme.onSurface.withValues(
                                      alpha: 0.7,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      )
                      : Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              colorScheme.primary,
                              colorScheme.secondary,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(
                          Icons.travel_explore_rounded,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
            ),

            const SizedBox(height: 16),

            // Navigation Items
            Expanded(
              child: ListView(
                padding: EdgeInsets.symmetric(horizontal: isExtended ? 16 : 8),
                children: [
                  ..._getNavigationItems(context).asMap().entries.map((entry) {
                    final index = entry.key;
                    final item = entry.value;
                    final isSelected = currentIndex == index;

                    return _buildNavItem(
                      context,
                      item['icon'] as IconData,
                      item['selectedIcon'] as IconData,
                      item['label'] as String,
                      isSelected,
                      () => onDestinationSelected(index),
                    );
                  }),
                ],
              ),
            ),

            // Theme Toggle and Settings
            Container(
              padding: EdgeInsets.all(isExtended ? 16 : 8),
              child: Column(
                children: [
                  // Theme Toggle
                  if (isExtended)
                    GestureDetector(
                      onTap: () => _toggleTheme(context),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: colorScheme.surfaceContainerLow,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              themeProvider.isDarkMode
                                  ? Icons.dark_mode_rounded
                                  : Icons.light_mode_rounded,
                              size: 20,
                              color: colorScheme.onSurface.withValues(
                                alpha: 0.7,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                themeProvider.themeDisplayName,
                                style: Theme.of(
                                  context,
                                ).textTheme.bodyMedium?.copyWith(
                                  color: colorScheme.onSurface.withValues(
                                    alpha: 0.7,
                                  ),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            Icon(
                              Icons.keyboard_arrow_right_rounded,
                              size: 16,
                              color: colorScheme.onSurface.withValues(
                                alpha: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: IconButton(
                        onPressed: () => _toggleTheme(context),
                        icon: Icon(
                          themeProvider.isDarkMode
                              ? Icons.light_mode_rounded
                              : Icons.dark_mode_rounded,
                        ),
                        tooltip: 'Toggle theme',
                      ),
                    ),

                  // Settings Button
                  _buildNavItem(
                    context,
                    Icons.settings_rounded,
                    Icons.settings_rounded,
                    'Settings',
                    false,
                    () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const SettingsScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context,
    IconData icon,
    IconData selectedIcon,
    String label,
    bool isSelected,
    VoidCallback onTap,
  ) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            HapticFeedback.lightImpact();
            onTap();
          },
          borderRadius: BorderRadius.circular(12),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: EdgeInsets.symmetric(
              horizontal: isExtended ? 16 : 12,
              vertical: 12,
            ),
            decoration: BoxDecoration(
              color:
                  isSelected
                      ? colorScheme.primaryContainer.withValues(alpha: 0.8)
                      : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
            ),
            child:
                isExtended
                    ? Row(
                      children: [
                        Icon(
                          isSelected ? selectedIcon : icon,
                          size: 24,
                          color:
                              isSelected
                                  ? colorScheme.primary
                                  : colorScheme.onSurface.withValues(
                                    alpha: 0.7,
                                  ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            label,
                            style: Theme.of(
                              context,
                            ).textTheme.bodyLarge?.copyWith(
                              color:
                                  isSelected
                                      ? colorScheme.primary
                                      : colorScheme.onSurface.withValues(
                                        alpha: 0.8,
                                      ),
                              fontWeight:
                                  isSelected
                                      ? FontWeight.w600
                                      : FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    )
                    : Center(
                      child: Icon(
                        isSelected ? selectedIcon : icon,
                        size: 24,
                        color:
                            isSelected
                                ? colorScheme.primary
                                : colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                    ),
          ),
        ),
      ),
    );
  }

  void _toggleTheme(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final currentMode = themeProvider.themeMode;

    ThemeMode newMode;
    switch (currentMode) {
      case ThemeMode.light:
        newMode = ThemeMode.dark;
        break;
      case ThemeMode.dark:
        newMode = ThemeMode.system;
        break;
      case ThemeMode.system:
      default:
        newMode = ThemeMode.light;
        break;
    }

    themeProvider.setThemeMode(newMode);
    HapticFeedback.lightImpact();
  }

  List<NavigationDestination> _getDestinations(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final baseDestinations = [
      NavigationDestination(
        icon: const Icon(Icons.tour_rounded),
        selectedIcon: Icon(Icons.tour_rounded, color: colorScheme.primary),
        label: 'Tours',
      ),
      NavigationDestination(
        icon: const Icon(Icons.recommend_rounded),
        selectedIcon: Icon(Icons.recommend_rounded, color: colorScheme.primary),
        label: 'Recommendations',
      ),
      NavigationDestination(
        icon: const Icon(Icons.directions_car_rounded),
        selectedIcon: Icon(
          Icons.directions_car_rounded,
          color: colorScheme.primary,
        ),
        label: 'Cars',
      ),
      NavigationDestination(
        icon: const Icon(Icons.home_rounded),
        selectedIcon: Icon(Icons.home_rounded, color: colorScheme.primary),
        label: 'Houses',
      ),
      NavigationDestination(
        icon: const Icon(Icons.book_online_rounded),
        selectedIcon: Icon(
          Icons.book_online_rounded,
          color: colorScheme.primary,
        ),
        label: 'Bookings',
      ),
    ];

    if (isAdmin) {
      baseDestinations.add(
        NavigationDestination(
          icon: const Icon(Icons.admin_panel_settings_rounded),
          selectedIcon: Icon(
            Icons.admin_panel_settings_rounded,
            color: colorScheme.primary,
          ),
          label: 'Admin',
        ),
      );
    }

    baseDestinations.add(
      NavigationDestination(
        icon: const Icon(Icons.person_rounded),
        selectedIcon: Icon(Icons.person_rounded, color: colorScheme.primary),
        label: 'Profile',
      ),
    );

    return baseDestinations;
  }

  List<Map<String, dynamic>> _getNavigationItems(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final baseItems = [
      {
        'icon': Icons.tour_rounded,
        'selectedIcon': Icons.tour_rounded,
        'label': 'Tours',
      },
      {
        'icon': Icons.recommend_rounded,
        'selectedIcon': Icons.recommend_rounded,
        'label': 'Recommendations',
      },
      {
        'icon': Icons.directions_car_rounded,
        'selectedIcon': Icons.directions_car_rounded,
        'label': 'Cars',
      },
      {
        'icon': Icons.home_rounded,
        'selectedIcon': Icons.home_rounded,
        'label': 'Houses',
      },
      {
        'icon': Icons.book_online_rounded,
        'selectedIcon': Icons.book_online_rounded,
        'label': 'Bookings',
      },
    ];

    if (isAdmin) {
      baseItems.add({
        'icon': Icons.admin_panel_settings_rounded,
        'selectedIcon': Icons.admin_panel_settings_rounded,
        'label': 'Admin',
      });
    }

    baseItems.add({
      'icon': Icons.person_rounded,
      'selectedIcon': Icons.person_rounded,
      'label': 'Profile',
    });

    return baseItems;
  }
}
