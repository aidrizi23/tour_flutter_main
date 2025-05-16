import 'package:flutter/material.dart';
import 'package:tour_flutter_main/models/auth_models.dart'; // Assuming this import is correct
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/tours/tour_list_screen.dart';
import 'screens/cars/car_list_screen.dart';
import 'screens/admin/admin_tour_create_screen.dart';
import 'screens/admin/admin_panel_screen.dart'; // Import the new Admin Panel screen
import 'screens/profile/profile_screen.dart';
import 'screens/booking/booking_screen.dart';
import 'services/auth_service.dart';
import 'services/stripe_service.dart'; // Assuming this import is correct

void main() async {
  // Ensure Flutter bindings are initialized.
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Stripe service.
  // It's good practice to handle potential errors during initialization.
  try {
    await StripeService.init();
  } catch (e) {
    // Log the error or handle it as appropriate for your application.
    debugPrint("Stripe initialization failed: $e");
  }

  // Run the application.
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Define a custom teal color swatch for the theme.
    const MaterialColor customTeal = MaterialColor(
      0xFF008080, // Primary Teal color
      <int, Color>{
        50: Color(0xFFE0F2F1),
        100: Color(0xFFB2DFDB),
        200: Color(0xFF80CBC4),
        300: Color(0xFF4DB6AC),
        400: Color(0xFF26A69A),
        500: Color(0xFF009688), // This is the primary color (Material Teal 500)
        600: Color(0xFF00897B),
        700: Color(
          0xFF00796B,
        ), // Darker shade for primaryVariant (Material Teal 700)
        800: Color(0xFF00695C),
        900: Color(0xFF004D40),
      },
    );

    // Define the light theme.
    final ThemeData lightTheme = ThemeData(
      useMaterial3: true,
      // Define the color scheme using the custom teal color.
      colorScheme: ColorScheme.fromSeed(
        seedColor: customTeal, // Use the custom teal as the seed.
        brightness: Brightness.light,
        primary: customTeal, // Explicitly set primary color.
        secondary:
            customTeal[700]!, // A slightly darker teal for secondary elements.
        surface: const Color(0xFFF5F5F5), // Light grey for surfaces.
        background: const Color(0xFFFFFFFF), // White background.
        error: Colors.redAccent,
      ),
      // Define AppBar theme.
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0, // Flat app bar.
        backgroundColor: customTeal, // Teal app bar background.
        foregroundColor: Colors.white, // White text/icons on app bar.
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      // Define ElevatedButton theme.
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: customTeal, // Teal background for buttons.
          foregroundColor: Colors.white, // White text/icons on buttons.
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              12,
            ), // Rounded corners for buttons.
          ),
        ),
      ),
      // Define InputDecoration theme for text fields.
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: customTeal[200]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: customTeal[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: customTeal, width: 2),
        ),
        filled: true,
        fillColor: customTeal[50]!.withOpacity(0.5),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
      // Define Card theme.
      cardTheme: CardTheme(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      ),
      // Define NavigationBar theme.
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: Colors.white,
        indicatorColor:
            customTeal[100], // Light teal for selected item indicator.
        labelTextStyle: WidgetStateProperty.resolveWith<TextStyle>((
          Set<WidgetState> states,
        ) {
          if (states.contains(WidgetState.selected)) {
            return const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: customTeal,
            );
          }
          return TextStyle(fontSize: 12, color: customTeal[700]);
        }),
        iconTheme: WidgetStateProperty.resolveWith<IconThemeData>((
          Set<WidgetState> states,
        ) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: customTeal);
          }
          return IconThemeData(color: customTeal[700]);
        }),
      ),
      // Define general text themes.
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          fontWeight: FontWeight.bold,
          color: Color(0xFF333333),
        ),
        headlineMedium: TextStyle(
          fontWeight: FontWeight.bold,
          color: Color(0xFF333333),
        ),
        headlineSmall: TextStyle(
          fontWeight: FontWeight.bold,
          color: Color(0xFF333333),
        ),
        titleLarge: TextStyle(
          fontWeight: FontWeight.w600,
          color: Color(0xFF444444),
        ),
        bodyLarge: TextStyle(color: Color(0xFF555555), fontSize: 16),
        bodyMedium: TextStyle(color: Color(0xFF666666), fontSize: 14),
      ),
      // Define scaffold background color.
      scaffoldBackgroundColor: const Color(0xFFFFFFFF),
    );

    // Define the dark theme.
    final ThemeData darkTheme = ThemeData(
      useMaterial3: true,
      // Define the color scheme for dark mode.
      colorScheme: ColorScheme.fromSeed(
        seedColor: customTeal, // Use custom teal as seed.
        brightness: Brightness.dark,
        primary: customTeal[300]!, // Lighter teal for primary in dark mode.
        secondary: customTeal[200]!, // Even lighter for secondary.
        surface: const Color(0xFF212121), // Dark grey for surfaces.
        background: const Color(0xFF121212), // Very dark grey for background.
        error: Colors.red[400]!,
      ),
      // Define AppBar theme for dark mode.
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
        backgroundColor: Color(0xFF1F1F1F), // Darker app bar background.
        foregroundColor: Colors.white,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      // Define ElevatedButton theme for dark mode.
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: customTeal[400], // Teal for buttons.
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      // Define InputDecoration theme for dark mode.
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: customTeal[600]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: customTeal[700]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: customTeal[300]!, width: 2),
        ),
        filled: true,
        fillColor: const Color(0xFF2C2C2C), // Darker fill for text fields.
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        hintStyle: TextStyle(color: Colors.grey[500]),
        labelStyle: TextStyle(color: customTeal[200]),
      ),
      // Define Card theme for dark mode.
      cardTheme: CardTheme(
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        color: const Color(0xFF2A2A2A), // Darker card background.
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      ),
      // Define NavigationBar theme for dark mode.
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: const Color(
          0xFF1F1F1F,
        ), // Dark background for navigation bar.
        indicatorColor:
            customTeal[700], // Darker teal for selected item indicator.
        labelTextStyle: WidgetStateProperty.resolveWith<TextStyle>((
          Set<WidgetState> states,
        ) {
          if (states.contains(WidgetState.selected)) {
            return TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: customTeal[200],
            );
          }
          return TextStyle(fontSize: 12, color: Colors.grey[400]);
        }),
        iconTheme: WidgetStateProperty.resolveWith<IconThemeData>((
          Set<WidgetState> states,
        ) {
          if (states.contains(WidgetState.selected)) {
            return IconThemeData(color: customTeal[200]);
          }
          return IconThemeData(color: Colors.grey[400]);
        }),
      ),
      // Define general text themes for dark mode.
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          fontWeight: FontWeight.bold,
          color: Color(0xFFE0E0E0),
        ),
        headlineMedium: TextStyle(
          fontWeight: FontWeight.bold,
          color: Color(0xFFE0E0E0),
        ),
        headlineSmall: TextStyle(
          fontWeight: FontWeight.bold,
          color: Color(0xFFE0E0E0),
        ),
        titleLarge: TextStyle(
          fontWeight: FontWeight.w600,
          color: Color(0xFFD0D0D0),
        ),
        bodyLarge: TextStyle(color: Color(0xFFC0C0C0), fontSize: 16),
        bodyMedium: TextStyle(color: Color(0xFFB0B0B0), fontSize: 14),
      ),
      // Define scaffold background color for dark mode.
      scaffoldBackgroundColor: const Color(0xFF121212),
    );

    return MaterialApp(
      title: 'TourApp',
      debugShowCheckedModeBanner: false,
      theme: lightTheme, // Apply the light theme.
      darkTheme: darkTheme, // Apply the dark theme.
      themeMode: ThemeMode.system, // Use system setting to choose theme.
      home: const AuthWrapper(),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/tours': (context) => const TourListScreen(),
        '/cars': (context) => const CarListScreen(),
        '/admin-panel': (context) =>
            const AdminPanelScreen(), // New route for Admin Panel
        '/admin/create-tour': (context) => const AdminTourCreateScreen(),
        '/profile': (context) => const ProfileScreen(),
        '/bookings': (context) => const BookingScreen(),
      },
    );
  }
}

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  final AuthService _authService = AuthService();
  bool _isLoading = true;
  bool _isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    try {
      final isLoggedIn = await _authService.isLoggedIn();
      if (mounted) {
        setState(() {
          _isLoggedIn = isLoggedIn;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoggedIn = false;
          _isLoading = false;
          // Optionally, show an error message or log the error.
          debugPrint("Error checking auth status: $e");
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    if (_isLoading) {
      return Scaffold(
        backgroundColor: colorScheme.surface, // Use theme background.
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: colorScheme.primary),
              const SizedBox(height: 20),
              Text(
                'Checking authentication...',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: colorScheme.onSurface.withOpacity(0.7),
                    ),
              ),
            ],
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

  // Define screens accessible to regular users.
  final List<Widget> _userScreens = [
    const TourListScreen(),
    const CarListScreen(),
    const BookingScreen(),
    const ProfileScreen(),
  ];

  // Define screens accessible to admin users.
  final List<Widget> _adminScreens = [
    const TourListScreen(),
    const CarListScreen(),
    const BookingScreen(),
    const AdminPanelScreen(), // Changed from AdminTourCreateScreen to AdminPanelScreen
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
    // Choose the set of screens based on admin status.
    final screens = _isAdmin ? _adminScreens : _userScreens;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: IndexedStack(
        // Use IndexedStack to preserve state of screens
        index: _currentIndex,
        children: screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        // Define navigation destinations.
        destinations: [
          const NavigationDestination(
            icon: Icon(Icons.explore_outlined),
            selectedIcon: Icon(Icons.explore),
            label: 'Tours',
          ),
          const NavigationDestination(
            icon: Icon(Icons.directions_car_outlined),
            selectedIcon: Icon(Icons.directions_car),
            label: 'Cars',
          ),
          const NavigationDestination(
            icon: Icon(Icons.book_online_outlined),
            selectedIcon: Icon(Icons.book_online),
            label: 'Bookings',
          ),
          // Conditionally add Admin screen to navigation bar.
          if (_isAdmin)
            const NavigationDestination(
              icon: Icon(Icons.admin_panel_settings_outlined), // Changed icon
              selectedIcon: Icon(Icons.admin_panel_settings), // Changed icon
              label: 'Admin Panel', // Changed label
            ),
          const NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
      // Drawer for additional navigation and actions.
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            // Drawer header with user information.
            FutureBuilder<User?>(
              future: _authService.getCurrentUser(),
              builder: (context, snapshot) {
                final user = snapshot.data;
                return UserAccountsDrawerHeader(
                  accountName: Text(
                    user?.userName ?? 'Guest',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  accountEmail: Text(user?.email ?? ''),
                  currentAccountPicture: CircleAvatar(
                    backgroundColor: colorScheme.onPrimary.withOpacity(0.8),
                    child: Text(
                      user?.userName.isNotEmpty == true
                          ? user!.userName[0].toUpperCase()
                          : 'G',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.primary,
                      ),
                    ),
                  ),
                  decoration: BoxDecoration(
                    color: colorScheme.primary, // Use theme primary color.
                  ),
                  otherAccountsPictures: [
                    if (_isAdmin)
                      CircleAvatar(
                        backgroundColor: colorScheme.secondary.withOpacity(0.8),
                        child: Icon(
                          Icons.admin_panel_settings,
                          color: colorScheme.onSecondary,
                          size: 20,
                        ),
                      ),
                  ],
                );
              },
            ),
            // Navigation items in the drawer.
            ListTile(
              leading: const Icon(Icons.explore),
              title: const Text('Tours'),
              selected: _currentIndex == 0,
              onTap: () {
                Navigator.pop(context);
                setState(() {
                  _currentIndex = 0;
                });
              },
            ),
            ListTile(
              leading: const Icon(Icons.directions_car),
              title: const Text('Car Rentals'),
              selected: _currentIndex == 1,
              onTap: () {
                Navigator.pop(context);
                setState(() {
                  _currentIndex = 1;
                });
              },
            ),
            ListTile(
              leading: const Icon(Icons.book_online),
              title: const Text('My Bookings'),
              selected: _currentIndex == 2,
              onTap: () {
                Navigator.pop(context);
                setState(() {
                  _currentIndex = 2;
                });
              },
            ),
            // Admin-specific drawer items.
            if (_isAdmin) ...[
              const Divider(),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 8.0,
                ),
                child: Text(
                  "Admin Tools",
                  style: Theme.of(context).textTheme.labelSmall,
                ),
              ),
              ListTile(
                leading: Icon(
                  Icons.admin_panel_settings,
                  color: colorScheme.secondary,
                ), // Changed icon
                title: const Text('Admin Panel'), // Changed label
                selected: _currentIndex == 3,
                onTap: () {
                  Navigator.pop(context);
                  setState(() {
                    _currentIndex = 3;
                  });
                },
              ),
            ],
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Profile'),
              selected: _currentIndex == (_isAdmin ? 4 : 3),
              onTap: () {
                Navigator.pop(context);
                setState(() {
                  _currentIndex = _isAdmin ? 4 : 3;
                });
              },
            ),
            const Divider(),
            // Settings and Logout.
            ListTile(
              leading: const Icon(Icons.settings_outlined),
              title: const Text('Settings'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Settings feature coming soon!'),
                  ),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.logout, color: colorScheme.error),
              title: Text('Logout', style: TextStyle(color: colorScheme.error)),
              onTap: () async {
                Navigator.pop(context); // Close drawer first.
                await _authService.logout();
                if (mounted) {
                  // Check if widget is still in the tree.
                  Navigator.of(context).pushReplacementNamed('/login');
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
