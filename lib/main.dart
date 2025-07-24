import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:tour_flutter_main/models/auth_models.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/tours/tour_list_screen.dart';
import 'screens/cars/car_list_screen.dart';
import 'screens/houses/house_list_screen.dart';
import 'screens/admin/admin_tour_create_screen.dart';
import 'screens/admin/admin_panel_screen.dart';
import 'screens/profile/profile_screen.dart';
import 'screens/booking/booking_screen.dart';
import 'screens/recommendation/recommendation_screen.dart';
import 'screens/settings/settings_screen.dart';
import 'screens/home/home_screen.dart';
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
            '/tours': (context) => const TourListScreen(),
            '/cars': (context) => const CarListScreen(),
            '/houses': (context) => const HouseListScreen(),
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
    // ... your existing theme data ...
    return ThemeData();
  }

  ThemeData _buildDarkTheme() {
    // ... your existing dark theme data ...
    return ThemeData.dark();
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

  Widget _buildAnimatedLogo() {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _pulseAnimation.value,
          child: AnimatedRotation(
            duration: const Duration(seconds: 5),
            turns: 1,
            child: Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  colors: [
                    Theme.of(context).colorScheme.primary.withOpacity(0.15),
                    Theme.of(context).colorScheme.surface,
                  ],
                  center: Alignment.center,
                  radius: 0.8,
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(
                      context,
                    ).colorScheme.primary.withOpacity(0.3),
                    blurRadius: 30,
                    spreadRadius: 10,
                  ),
                ],
              ),
              child: Icon(
                Icons.travel_explore_rounded,
                size: 64,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
        );
      },
    );
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
                _buildAnimatedLogo(),
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

    return _isLoggedIn ? const EnhancedHomeScreen() : const LoginScreen();
  }
}