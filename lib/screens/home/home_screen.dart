import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../services/auth_service.dart';
import '../cars/car_list_screen.dart';
import '../tours/tour_list_screen.dart';
import '../admin/admin_panel_screen.dart';
import '../admin/admin_tour_create_screen.dart';
import '../profile/profile_screen.dart';
import '../booking/booking_screen.dart';
import '../home/home_web_screen.dart';
import '../recommendation/recommendation_screen.dart';
import '../../widgets/resizable_navigation_rail.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AuthService _authService = AuthService();
  int _currentIndex = 0;
  bool _isAdmin = false;

  final List<Widget> _userScreens = [
    const HomeWebScreen(),
    const TourListScreen(),
    const RecommendationScreen(),
    const CarListScreen(),
    const BookingScreen(),
    const ProfileScreen(),
  ];

  final List<Widget> _adminScreens = [
    const HomeWebScreen(),
    const TourListScreen(),
    const RecommendationScreen(),
    const CarListScreen(),
    const BookingScreen(),
    const AdminPanelScreen(),
    const ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _checkAdminStatus();
  }

  Future<void> _checkAdminStatus() async {
    final isAdmin = await _authService.isAdmin();
    if (mounted) {
      setState(() {
        _isAdmin = isAdmin;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screens = _isAdmin ? _adminScreens : _userScreens;
    final colorScheme = Theme.of(context).colorScheme;
    final bool isDesktop = MediaQuery.of(context).size.width >= 800;

    final navigationDestinations = <NavigationDestination>[
      NavigationDestination(
        icon: const Icon(Icons.home_outlined),
        selectedIcon: Icon(Icons.home, color: colorScheme.primary),
        label: 'Home',
      ),
      NavigationDestination(
        icon: const Icon(Icons.explore_outlined),
        selectedIcon: Icon(Icons.explore, color: colorScheme.primary),
        label: 'Discover',
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
        icon: const Icon(Icons.bookmark_border_outlined),
        selectedIcon: Icon(Icons.bookmark, color: colorScheme.primary),
        label: 'Bookings',
      ),
      if (_isAdmin)
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

    return Scaffold(
      body: isDesktop
          ? Row(
              children: [
                ResizableNavigationRail(
                  selectedIndex: _currentIndex,
                  onDestinationSelected: (index) {
                    if (index != _currentIndex) {
                      setState(() => _currentIndex = index);
                      HapticFeedback.selectionClick();
                    }
                  },
                  backgroundColor: colorScheme.surface,
                  selectedIconTheme: IconThemeData(color: colorScheme.primary),
                  indicatorColor: colorScheme.primary.withOpacity(0.1),
                  destinations: navigationDestinations
                      .map(
                        (e) => NavigationRailDestination(
                          icon: e.icon,
                          selectedIcon: e.selectedIcon!,
                          label: Text(e.label),
                        ),
                      )
                      .toList(),
                ),
                const VerticalDivider(width: 1),
                Expanded(
                  child: IndexedStack(index: _currentIndex, children: screens),
                ),
              ],
            )
          : IndexedStack(index: _currentIndex, children: screens),
      bottomNavigationBar: isDesktop
          ? null
          : Container(
              decoration: BoxDecoration(
                color: colorScheme.surface,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: SafeArea(
                child: NavigationBar(
                  selectedIndex: _currentIndex,
                  onDestinationSelected: (index) {
                    if (index != _currentIndex) {
                      setState(() {
                        _currentIndex = index;
                      });
                      HapticFeedback.selectionClick();
                    }
                  },
                  backgroundColor: colorScheme.surface,
                  surfaceTintColor: colorScheme.surface,
                  indicatorColor: colorScheme.primary.withOpacity(0.1),
                  destinations: navigationDestinations,
                ),
              ),
            ),
    );
  }
}
