import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/tours/tour_list_screen_unified.dart';
import 'screens/cars/car_list_screen_unified.dart';
import 'screens/houses/house_list_screen_unified.dart';
import 'screens/admin/admin_tour_create_screen.dart';
import 'screens/admin/admin_panel_screen.dart';
import 'screens/profile/profile_screen.dart';
import 'screens/booking/booking_screen.dart';
import 'screens/recommendation/recommendation_screen.dart';
import 'screens/settings/settings_screen.dart';
import 'widgets/responsive_layout.dart';
import 'services/auth_service.dart';
import 'services/stripe_service.dart';
import 'providers/theme_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await StripeService.init();
  } catch (e) {
    debugPrint("Stripe initialization failed: $e");
  }

  runApp(
    ChangeNotifierProvider(
      create: (context) => ThemeProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          title: 'TourApp',
          debugShowCheckedModeBanner: false,
          theme: _buildLightTheme(),
          darkTheme: _buildDarkTheme(),
          themeMode: themeProvider.themeMode,
          home: const AuthWrapper(),
          routes: {
            '/login': (context) => const LoginScreen(),
            '/register': (context) => const RegisterScreen(),
            '/tours': (context) => const TourListScreenUnified(),
            '/cars': (context) => const CarListScreenUnified(),
            '/admin-panel': (context) => const AdminPanelScreen(),
            '/admin/create-tour': (context) => const AdminTourCreateScreen(),
            '/profile': (context) => const ProfileScreen(),
            '/bookings': (context) => const BookingScreen(),
            '/recommendations': (context) => const RecommendationScreen(),
            '/settings': (context) => const SettingsScreen(),
          },
        );
      },
    );
  }

  ThemeData _buildLightTheme() {
    // Modern, smooth color palette inspired by Booking.com
    const primaryColor = Color(0xFF003B95); // Deep blue
    const secondaryColor = Color(0xFF0071C2); // Lighter blue
    const accentColor = Color(0xFF00A651); // Success green
    const backgroundColor = Color(0xFFFAFBFC);
    const surfaceColor = Color(0xFFFFFFFF);
    const cardColor = Color(0xFFFFFFFF);

    return ThemeData(
      useMaterial3: true,
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
      dropdownMenuTheme: DropdownMenuThemeData(
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
        ),
        menuStyle: MenuStyle(
          backgroundColor: WidgetStateProperty.all(surfaceColor),
          elevation: WidgetStateProperty.all(8),
          shape: WidgetStateProperty.all(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ),
      scaffoldBackgroundColor: backgroundColor,
      // Enhanced performance settings
      visualDensity: VisualDensity.adaptivePlatformDensity,
      // Improved tap target size for mobile
      materialTapTargetSize: MaterialTapTargetSize.padded,
      // Enhanced typography with better readability
      textTheme: const TextTheme(
        displayLarge: TextStyle(fontWeight: FontWeight.w300, letterSpacing: -0.5),
        displayMedium: TextStyle(fontWeight: FontWeight.w300, letterSpacing: -0.25),
        displaySmall: TextStyle(fontWeight: FontWeight.w400, letterSpacing: 0),
        headlineLarge: TextStyle(fontWeight: FontWeight.w600, letterSpacing: -0.25),
        headlineMedium: TextStyle(fontWeight: FontWeight.w600, letterSpacing: 0),
        headlineSmall: TextStyle(fontWeight: FontWeight.w600, letterSpacing: 0.15),
        titleLarge: TextStyle(fontWeight: FontWeight.w700, letterSpacing: 0),
        titleMedium: TextStyle(fontWeight: FontWeight.w600, letterSpacing: 0.1),
        titleSmall: TextStyle(fontWeight: FontWeight.w600, letterSpacing: 0.1),
        bodyLarge: TextStyle(fontWeight: FontWeight.w400, letterSpacing: 0.5),
        bodyMedium: TextStyle(fontWeight: FontWeight.w400, letterSpacing: 0.25),
        bodySmall: TextStyle(fontWeight: FontWeight.w400, letterSpacing: 0.4),
        labelLarge: TextStyle(fontWeight: FontWeight.w600, letterSpacing: 1.25),
        labelMedium: TextStyle(fontWeight: FontWeight.w600, letterSpacing: 1.25),
        labelSmall: TextStyle(fontWeight: FontWeight.w600, letterSpacing: 1.5),
      ),
    );
  }

  ThemeData _buildDarkTheme() {
    // Dark theme with smooth, professional colors
    const primaryColor = Color(0xFF4A90E2); // Softer blue for dark mode
    const secondaryColor = Color(0xFF5BA3F5);
    const accentColor = Color(0xFF2ECC71);
    const backgroundColor = Color(0xFF0F1419);
    const surfaceColor = Color(0xFF1A1F2E);
    const cardColor = Color(0xFF252B3A);

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
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
      dropdownMenuTheme: DropdownMenuThemeData(
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
        ),
        menuStyle: MenuStyle(
          backgroundColor: WidgetStateProperty.all(surfaceColor),
          elevation: WidgetStateProperty.all(8),
          shape: WidgetStateProperty.all(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ),
      scaffoldBackgroundColor: backgroundColor,
      // Enhanced performance settings
      visualDensity: VisualDensity.adaptivePlatformDensity,
      // Improved tap target size for mobile
      materialTapTargetSize: MaterialTapTargetSize.padded,
      // Enhanced typography with better readability
      textTheme: const TextTheme(
        displayLarge: TextStyle(fontWeight: FontWeight.w300, letterSpacing: -0.5),
        displayMedium: TextStyle(fontWeight: FontWeight.w300, letterSpacing: -0.25),
        displaySmall: TextStyle(fontWeight: FontWeight.w400, letterSpacing: 0),
        headlineLarge: TextStyle(fontWeight: FontWeight.w600, letterSpacing: -0.25),
        headlineMedium: TextStyle(fontWeight: FontWeight.w600, letterSpacing: 0),
        headlineSmall: TextStyle(fontWeight: FontWeight.w600, letterSpacing: 0.15),
        titleLarge: TextStyle(fontWeight: FontWeight.w700, letterSpacing: 0),
        titleMedium: TextStyle(fontWeight: FontWeight.w600, letterSpacing: 0.1),
        titleSmall: TextStyle(fontWeight: FontWeight.w600, letterSpacing: 0.1),
        bodyLarge: TextStyle(fontWeight: FontWeight.w400, letterSpacing: 0.5),
        bodyMedium: TextStyle(fontWeight: FontWeight.w400, letterSpacing: 0.25),
        bodySmall: TextStyle(fontWeight: FontWeight.w400, letterSpacing: 0.4),
        labelLarge: TextStyle(fontWeight: FontWeight.w600, letterSpacing: 1.25),
        labelMedium: TextStyle(fontWeight: FontWeight.w600, letterSpacing: 1.25),
        labelSmall: TextStyle(fontWeight: FontWeight.w600, letterSpacing: 1.5),
      ),
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
                        padding: const EdgeInsets.all(36),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surface,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Theme.of(
                                context,
                              ).colorScheme.primary.withOpacity(0.3),
                              blurRadius: 30,
                              spreadRadius: 8,
                            ),
                            BoxShadow(
                              color: Theme.of(
                                context,
                              ).colorScheme.secondary.withOpacity(0.1),
                              blurRadius: 50,
                              spreadRadius: 20,
                            ),
                          ],
                        ),
                        child: ShaderMask(
                          shaderCallback: (bounds) => LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Theme.of(context).colorScheme.primary,
                              Theme.of(context).colorScheme.secondary,
                            ],
                          ).createShader(bounds),
                          child: const Icon(
                            Icons.travel_explore_rounded,
                            size: 72,
                            color: Colors.white,
                          ),
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
    const TourListScreenUnified(),
    const RecommendationScreen(),
    const CarListScreenUnified(),
    const HouseListScreenUnified(),
    const BookingScreen(),
    const ProfileScreen(),
  ];

  final List<Widget> _adminScreens = [
    const TourListScreenUnified(),
    const RecommendationScreen(),
    const CarListScreenUnified(),
    const HouseListScreenUnified(),
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

    return ResponsiveLayout(
      currentIndex: _currentIndex,
      onDestinationSelected: (index) {
        if (index != _currentIndex) {
          setState(() {
            _currentIndex = index;
          });
          HapticFeedback.selectionClick();
        }
      },
      isAdmin: _isAdmin,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        transitionBuilder: (child, animation) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0.1, 0),
              end: Offset.zero,
            ).animate(
              CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutCubic,
              ),
            ),
            child: FadeTransition(
              opacity: animation,
              child: child,
            ),
          );
        },
        child: IndexedStack(
          key: ValueKey(_currentIndex),
          index: _currentIndex,
          children: screens,
        ),
      ),
    );
  }
}
