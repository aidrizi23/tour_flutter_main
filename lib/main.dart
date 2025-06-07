import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tour_flutter_main/models/auth_models.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/tours/tour_list_screen.dart';
import 'screens/cars/car_list_screen.dart';
import 'screens/admin/admin_tour_create_screen.dart';
import 'screens/admin/admin_panel_screen.dart';
import 'screens/profile/profile_screen.dart';
import 'screens/booking/booking_screen.dart';
import 'screens/recommendation/recommendation_screen.dart';
import 'services/auth_service.dart';
import 'services/stripe_service.dart';
import 'widgets/resizable_navigation_rail.dart';
import 'widgets/app_layout.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await StripeService.init();
  } catch (e) {
    debugPrint("Stripe initialization failed: $e");
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TourApp',
      debugShowCheckedModeBanner: false,
      theme: _buildLightTheme(),
      darkTheme: _buildDarkTheme(),
      themeMode: ThemeMode.system,
      builder: (context, child) => AppLayout(child: child ?? const SizedBox()),
      home: const AuthWrapper(),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/tours': (context) => const TourListScreen(),
        '/cars': (context) => const CarListScreen(),
        '/admin-panel': (context) => const AdminPanelScreen(),
        '/admin/create-tour': (context) => const AdminTourCreateScreen(),
        '/profile': (context) => const ProfileScreen(),
        '/bookings': (context) => const BookingScreen(),
        '/recommendations': (context) => const RecommendationScreen(),
      },
    );
  }

  ThemeData _buildLightTheme() {
    // Subtle palette with a modern web feel
    const primaryColor = Color(0xFF0D6EFD); // Bootstrap blue
    const secondaryColor = Color(0xFF6610F2); // Accent purple
    const accentColor = Color(0xFF198754); // Success green
    const backgroundColor = Color(0xFFF8F9FA);
    const surfaceColor = Color(0xFFFFFFFF);
    const cardColor = Color(0xFFFFFFFF);

    return ThemeData(
      useMaterial3: true,
      textTheme: GoogleFonts.interTextTheme(ThemeData.light().textTheme),
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        brightness: Brightness.light,
        primary: primaryColor,
        secondary: secondaryColor,
        tertiary: accentColor,
        surface: surfaceColor,
        surfaceContainerLowest: backgroundColor,
        surfaceContainerLow: const Color(0xFFF7F9FA),
        surfaceContainer: const Color(0xFFF0F2F5),
        surfaceContainerHigh: const Color(0xFFE4E7EB),
        background: backgroundColor,
        error: const Color(0xFFD32F2F),
        outline: const Color(0xFFD1D5DB),
        onPrimary: Colors.white,
        onSurface: const Color(0xFF1A1A1A),
        onSurfaceVariant: const Color(0xFF5F6368),
        onBackground: const Color(0xFF1A1A1A),
      ),
      appBarTheme: const AppBarTheme(
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 1,
        backgroundColor: surfaceColor,
        surfaceTintColor: surfaceColor,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Color(0xFF1A1A1A),
        ),
        iconTheme: IconThemeData(color: Color(0xFF1A1A1A)),
      ),
      cardTheme: CardThemeData(
        elevation: 2,
        shadowColor: Colors.black.withOpacity(0.08),
        color: cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        clipBehavior: Clip.antiAlias,
        margin: EdgeInsets.zero,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryColor,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          side: BorderSide(color: primaryColor.withOpacity(0.5)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFF7F9FA),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: primaryColor, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        hintStyle: const TextStyle(color: Color(0xFF9CA3AF)),
      ),
      scaffoldBackgroundColor: backgroundColor,
    );
  }

  ThemeData _buildDarkTheme() {
    // Complementary dark palette
    const primaryColor = Color(0xFF0D6EFD); // Same base blue
    const secondaryColor = Color(0xFF7C4DFF);
    const accentColor = Color(0xFF20C997);
    const backgroundColor = Color(0xFF121212);
    const surfaceColor = Color(0xFF1E1E1E);
    const cardColor = Color(0xFF2C2C2C);

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme),
      colorScheme: ColorScheme.dark(
        primary: primaryColor,
        secondary: secondaryColor,
        tertiary: accentColor,
        surface: surfaceColor,
        surfaceContainerLowest: backgroundColor,
        surfaceContainerLow: const Color(0xFF161B26),
        surfaceContainer: cardColor,
        surfaceContainerHigh: const Color(0xFF2A3142),
        surfaceContainerHighest: const Color(0xFF303749),
        background: backgroundColor,
        error: const Color(0xFFE57373),
        outline: const Color(0xFF3F4650),
        onPrimary: Colors.white,
        onSurface: const Color(0xFFE8EAED),
        onSurfaceVariant: const Color(0xFFBDC1C6),
        onBackground: const Color(0xFFE8EAED),
      ),
      appBarTheme: AppBarTheme(
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 1,
        backgroundColor: surfaceColor,
        surfaceTintColor: surfaceColor,
        titleTextStyle: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Color(0xFFE8EAED),
        ),
        iconTheme: const IconThemeData(color: Color(0xFFE8EAED)),
      ),
      cardTheme: CardThemeData(
        elevation: 4,
        shadowColor: Colors.black.withOpacity(0.3),
        color: cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        clipBehavior: Clip.antiAlias,
        margin: EdgeInsets.zero,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryColor,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          side: BorderSide(color: primaryColor.withOpacity(0.5)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF2A3142),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF3F4650)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF3F4650)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: primaryColor, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        hintStyle: const TextStyle(color: Color(0xFF9CA3AF)),
      ),
      scaffoldBackgroundColor: backgroundColor,
    );
  }
}

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper>
    with TickerProviderStateMixin {
  final AuthService _authService = AuthService();
  bool _isLoading = true;
  bool _isLoggedIn = false;
  late AnimationController _loadingController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _loadingController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _loadingController, curve: Curves.easeInOut),
    );
    _loadingController.repeat(reverse: true);
    _checkAuthStatus();
  }

  @override
  void dispose() {
    _loadingController.dispose();
    super.dispose();
  }

  Future<void> _checkAuthStatus() async {
    try {
      final isLoggedIn = await _authService.isLoggedIn();
      if (mounted) {
        setState(() {
          _isLoggedIn = isLoggedIn;
          _isLoading = false;
        });
        _loadingController.stop();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoggedIn = false;
          _isLoading = false;
        });
        _loadingController.stop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Theme.of(context).colorScheme.primary.withOpacity(0.1),
                Theme.of(context).colorScheme.background,
              ],
            ),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedBuilder(
                  animation: _pulseAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _pulseAnimation.value,
                      child: Container(
                        padding: const EdgeInsets.all(32),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surface,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Theme.of(
                                context,
                              ).colorScheme.primary.withOpacity(0.2),
                              blurRadius: 20,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.travel_explore_rounded,
                          size: 64,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 32),
                Text(
                  'TourApp',
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Your next adventure awaits...',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: 32,
                  height: 32,
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return _isLoggedIn ? const HomeScreen() : const LoginScreen();
  }
}

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
    const TourListScreen(),
    const RecommendationScreen(),
    const CarListScreen(),
    const BookingScreen(),
    const ProfileScreen(),
  ];

  final List<Widget> _adminScreens = [
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
