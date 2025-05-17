import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../widgets/modern_widgets.dart';
import 'admin_tour_create_screen.dart';
import 'admin_discount_management_screen.dart';

class AdminPanelScreen extends StatefulWidget {
  const AdminPanelScreen({super.key});

  @override
  State<AdminPanelScreen> createState() => _AdminPanelScreenState();
}

class _AdminPanelScreenState extends State<AdminPanelScreen>
    with TickerProviderStateMixin {
  final AuthService _authService = AuthService();
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
  }

  void _setupAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeOut));
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Admin Panel'), elevation: 0),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildWelcomeSection(),
              const SizedBox(height: 24),
              _buildQuickActions(),
              const SizedBox(height: 24),
              _buildManagementCards(),
              const SizedBox(height: 24),
              _buildSystemCards(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeSection() {
    return ModernCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  Icons.admin_panel_settings,
                  color: Theme.of(context).colorScheme.primary,
                  size: 32,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome to Admin Panel',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    FutureBuilder<String?>(
                      future: _authService.getCurrentUser().then(
                        (user) => user?.userName,
                      ),
                      builder:
                          (context, snapshot) => Text(
                            'Hello, ${snapshot.data ?? 'Admin'}!',
                            style: Theme.of(
                              context,
                            ).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurface.withOpacity(0.7),
                            ),
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Manage your tours, cars, discounts, and system settings from this central dashboard.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildQuickActionCard(
                'Create Tour',
                Icons.add_location_alt,
                Colors.blue,
                () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AdminTourCreateScreen(),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              _buildQuickActionCard(
                'Create Discount',
                Icons.add_card,
                Colors.purple,
                () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AdminDiscountManagementScreen(),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              _buildQuickActionCard(
                'View Analytics',
                Icons.analytics,
                Colors.green,
                () => ModernSnackBar.show(
                  context,
                  message: 'Analytics feature coming soon!',
                  type: SnackBarType.info,
                ),
              ),
              const SizedBox(width: 12),
              _buildQuickActionCard(
                'System Health',
                Icons.health_and_safety,
                Colors.orange,
                () => ModernSnackBar.show(
                  context,
                  message: 'System health monitoring coming soon!',
                  type: SnackBarType.info,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActionCard(
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return ModernCard(
      onTap: onTap,
      child: SizedBox(
        width: 120,
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildManagementCards() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Management',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.2,
          children: [
            _buildManagementCard(
              'Tour Management',
              'Create and manage tours',
              Icons.map_outlined,
              Colors.blue,
              () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AdminTourCreateScreen(),
                ),
              ),
            ),
            _buildManagementCard(
              'Discount Codes',
              'Create and manage discounts',
              Icons.discount_outlined,
              Colors.purple,
              () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AdminDiscountManagementScreen(),
                ),
              ),
            ),
            _buildManagementCard(
              'Car Fleet',
              'Manage car rental inventory',
              Icons.directions_car_outlined,
              Colors.orange,
              () => ModernSnackBar.show(
                context,
                message: 'Car management feature coming soon!',
                type: SnackBarType.info,
              ),
            ),
            _buildManagementCard(
              'Bookings',
              'View and manage bookings',
              Icons.roofing_outlined,
              Colors.green,
              () => ModernSnackBar.show(
                context,
                message: 'Booking management feature coming soon!',
                type: SnackBarType.info,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildManagementCard(
    String title,
    String subtitle,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return ModernCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSystemCards() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'System & Reports',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        _buildSystemCard(
          'Analytics & Reports',
          'View detailed analytics and generate reports',
          Icons.analytics_outlined,
          Colors.blue,
          () => ModernSnackBar.show(
            context,
            message: 'Analytics feature coming soon!',
            type: SnackBarType.info,
          ),
        ),
        const SizedBox(height: 12),
        _buildSystemCard(
          'User Management',
          'Manage users, roles, and permissions',
          Icons.people_outline,
          Colors.green,
          () => ModernSnackBar.show(
            context,
            message: 'User management feature coming soon!',
            type: SnackBarType.info,
          ),
        ),
        const SizedBox(height: 12),
        _buildSystemCard(
          'System Settings',
          'Configure app settings and preferences',
          Icons.settings_outlined,
          Colors.orange,
          () => ModernSnackBar.show(
            context,
            message: 'System settings feature coming soon!',
            type: SnackBarType.info,
          ),
        ),
        const SizedBox(height: 12),
        _buildSystemCard(
          'Payment Settings',
          'Configure payment gateways and pricing',
          Icons.payment_outlined,
          Colors.purple,
          () => ModernSnackBar.show(
            context,
            message: 'Payment settings feature coming soon!',
            type: SnackBarType.info,
          ),
        ),
      ],
    );
  }

  Widget _buildSystemCard(
    String title,
    String subtitle,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return ModernCard(
      onTap: onTap,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.chevron_right,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
          ),
        ],
      ),
    );
  }
}
