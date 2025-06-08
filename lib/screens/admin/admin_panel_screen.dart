import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../services/auth_service.dart';
import 'admin_tour_create_screen.dart';
import 'admin_discount_management_screen.dart';
import 'admin_dashboard_screen.dart';

class AdminPanelScreen extends StatefulWidget {
  const AdminPanelScreen({super.key});

  @override
  State<AdminPanelScreen> createState() => _AdminPanelScreenState();
}

class _AdminPanelScreenState extends State<AdminPanelScreen>
    with TickerProviderStateMixin {
  final AuthService _authService = AuthService();
  late AnimationController _fadeController;
  late AnimationController _staggerController;
  late Animation<double> _fadeAnimation;

  // Real-time dashboard stats
  Map<String, dynamic> _dashboardStats = {};
  bool _isLoadingStats = true;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _loadDashboardStats();
  }

  void _setupAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _staggerController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );
    _fadeController.forward();
    _staggerController.forward();
  }

  Future<void> _loadDashboardStats() async {
    try {
      // Note: In a real app, you would fetch these from your API
      // For now, we'll simulate an API call and provide fallback values
      await Future.delayed(const Duration(seconds: 1)); // Simulate API delay
      
      // You would replace this with actual API calls like:
      // final stats = await AdminService.getDashboardStats();
      
      setState(() {
        _dashboardStats = {
          'totalTours': 0,
          'activeTours': 0,
          'totalBookings': 0,
          'monthlyRevenue': 0.0,
          'todayBookings': 0,
          'pendingReviews': 0,
        };
        _isLoadingStats = false;
      });
    } catch (e) {
      setState(() {
        _dashboardStats = {
          'totalTours': 0,
          'activeTours': 0,
          'totalBookings': 0,
          'monthlyRevenue': 0.0,
          'todayBookings': 0,
          'pendingReviews': 0,
        };
        _isLoadingStats = false;
      });
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _staggerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;
    final isTablet = screenWidth >= 768 && screenWidth < 1200;
    final isDesktop = screenWidth >= 1200;

    return FadeTransition(
      opacity: _fadeAnimation,
      child: CustomScrollView(
        slivers: [
            // Header Section
            SliverToBoxAdapter(
              child: Container(
                color: colorScheme.surface,
                child: SafeArea(child: _buildHeader(isMobile)),
              ),
            ),

            // Content
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(isMobile ? 16 : 24),
                child: Column(
                  children: [
                    // Dashboard navigation card
                    _buildDashboardCard(colorScheme, isMobile),
                    const SizedBox(height: 24),

                    // Stats Overview
                    _buildStatsOverview(isMobile, isTablet, isDesktop),
                    const SizedBox(height: 32),

                    // Quick Actions
                    _buildQuickActionsSection(isMobile, isTablet),
                    const SizedBox(height: 32),

                    // Management Grid
                    _buildManagementGrid(isMobile, isTablet, isDesktop),
                    const SizedBox(height: 32),

                    // Recent Activity
                    _buildRecentActivity(isMobile),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
  }

  Widget _buildDashboardCard(ColorScheme colorScheme, bool isMobile) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colorScheme.primary,
            colorScheme.secondary,
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            HapticFeedback.mediumImpact();
            Navigator.of(context).push(
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) =>
                    const AdminDashboardScreen(),
                transitionsBuilder: (context, animation, secondaryAnimation, child) {
                  return SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(1.0, 0.0),
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
                transitionDuration: const Duration(milliseconds: 400),
              ),
            );
          },
          borderRadius: BorderRadius.circular(20),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.dashboard_rounded,
                  color: Colors.white,
                  size: 32,
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Advanced Dashboard',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Comprehensive analytics, charts, and real-time data',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.arrow_forward_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(bool isMobile) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: EdgeInsets.all(isMobile ? 20 : 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isMobile)
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [colorScheme.primary, colorScheme.secondary],
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.admin_panel_settings_rounded,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Admin Dashboard',
                        style: Theme.of(
                          context,
                        ).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      FutureBuilder<String?>(
                        future: _authService.getCurrentUser().then(
                          (user) => user?.userName,
                        ),
                        builder:
                            (context, snapshot) => Text(
                              'Welcome back, ${snapshot.data ?? 'Admin'}!',
                              style: Theme.of(
                                context,
                              ).textTheme.bodyMedium?.copyWith(
                                color: colorScheme.onSurface.withValues(
                                  alpha: 0.7,
                                ),
                              ),
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            )
          else
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [colorScheme.primary, colorScheme.secondary],
                    ),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: colorScheme.primary.withValues(alpha: 0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.admin_panel_settings_rounded,
                    color: Colors.white,
                    size: 36,
                  ),
                ),
                const SizedBox(width: 24),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Admin Dashboard',
                        style: Theme.of(
                          context,
                        ).textTheme.headlineLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 8),
                      FutureBuilder<String?>(
                        future: _authService.getCurrentUser().then(
                          (user) => user?.userName,
                        ),
                        builder:
                            (context, snapshot) => Text(
                              'Welcome back, ${snapshot.data ?? 'Admin'}! Here\'s what\'s happening with AlbTour today.',
                              style: Theme.of(
                                context,
                              ).textTheme.bodyLarge?.copyWith(
                                color: colorScheme.onSurface.withValues(
                                  alpha: 0.7,
                                ),
                              ),
                            ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.schedule_rounded,
                        size: 16,
                        color: colorScheme.onPrimaryContainer,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Last updated: ${DateTime.now().hour}:${DateTime.now().minute.toString().padLeft(2, '0')}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onPrimaryContainer,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildStatsOverview(bool isMobile, bool isTablet, bool isDesktop) {
    final colorScheme = Theme.of(context).colorScheme;

    int crossAxisCount;
    double childAspectRatio;

    if (isDesktop) {
      crossAxisCount = 3;
      childAspectRatio = 1.4;
    } else if (isTablet) {
      crossAxisCount = 2;
      childAspectRatio = 1.3;
    } else {
      crossAxisCount = 1;
      childAspectRatio = 2.5;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8, bottom: 16),
          child: Text(
            'Overview',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
        ),
        GridView.count(
          crossAxisCount: crossAxisCount,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: childAspectRatio,
          children: [
            _buildStatCard(
              'Total Tours',
              _isLoadingStats ? '...' : '${_dashboardStats['totalTours'] ?? 0}',
              Icons.map_rounded,
              colorScheme.primary,
              _isLoadingStats ? 'Loading...' : 'Connect your API for real data',
              false,
            ),
            _buildStatCard(
              'Monthly Revenue',
              _isLoadingStats ? '...' : '\$${(_dashboardStats['monthlyRevenue'] ?? 0.0).toStringAsFixed(0)}',
              Icons.trending_up_rounded,
              Colors.green,
              _isLoadingStats ? 'Loading...' : 'Connect your API for real data',
              false,
            ),
            _buildStatCard(
              'Total Bookings',
              _isLoadingStats ? '...' : '${_dashboardStats['totalBookings'] ?? 0}',
              Icons.calendar_month_rounded,
              colorScheme.secondary,
              _isLoadingStats ? 'Loading...' : 'Connect your API for real data',
              false,
            ),
            _buildStatCard(
              'Active Tours',
              _isLoadingStats ? '...' : '${_dashboardStats['activeTours'] ?? 0}',
              Icons.explore_rounded,
              Colors.orange,
              _isLoadingStats ? 'Loading...' : 'Out of ${_dashboardStats['totalTours'] ?? 0} total',
              false,
            ),
            _buildStatCard(
              'Today\'s Bookings',
              _isLoadingStats ? '...' : '${_dashboardStats['todayBookings'] ?? 0}',
              Icons.today_rounded,
              Colors.purple,
              _isLoadingStats ? 'Loading...' : 'No pending confirmations',
              false,
            ),
            _buildStatCard(
              'Pending Reviews',
              _isLoadingStats ? '...' : '${_dashboardStats['pendingReviews'] ?? 0}',
              Icons.rate_review_rounded,
              Colors.amber,
              _isLoadingStats ? 'Loading...' : 'No pending reviews',
              false,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
    String subtitle,
    bool showTrend,
  ) {
    final colorScheme = Theme.of(context).colorScheme;

    return AnimatedBuilder(
      animation: _staggerController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, 30 * (1 - _staggerController.value)),
          child: Opacity(
            opacity: _staggerController.value,
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: colorScheme.shadow.withValues(alpha: 0.05),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(icon, color: color, size: 24),
                      ),
                      const Spacer(),
                      if (showTrend)
                        Icon(
                          Icons.trending_up_rounded,
                          color: Colors.green,
                          size: 20,
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    value,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    title,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurface.withValues(alpha: 0.7),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color:
                          showTrend
                              ? Colors.green
                              : colorScheme.onSurface.withValues(alpha: 0.6),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildQuickActionsSection(bool isMobile, bool isTablet) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8, bottom: 16),
          child: Text(
            'Quick Actions',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
        ),
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: colorScheme.shadow.withValues(alpha: 0.05),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child:
              isMobile
                  ? Column(
                    children: [
                      _buildQuickActionButton(
                        'Create New Tour',
                        'Add a new tour to your catalog',
                        Icons.add_location_alt_rounded,
                        colorScheme.primary,
                        () => _navigateToTourCreate(),
                      ),
                      const SizedBox(height: 16),
                      _buildQuickActionButton(
                        'Manage Discounts',
                        'Create and edit discount codes',
                        Icons.local_offer_rounded,
                        Colors.purple,
                        () => _navigateToDiscountManagement(),
                      ),
                    ],
                  )
                  : Row(
                    children: [
                      Expanded(
                        child: _buildQuickActionButton(
                          'Create New Tour',
                          'Add a new tour to your catalog',
                          Icons.add_location_alt_rounded,
                          colorScheme.primary,
                          () => _navigateToTourCreate(),
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: _buildQuickActionButton(
                          'Manage Discounts',
                          'Create and edit discount codes',
                          Icons.local_offer_rounded,
                          Colors.purple,
                          () => _navigateToDiscountManagement(),
                        ),
                      ),
                    ],
                  ),
        ),
      ],
    );
  }

  Widget _buildQuickActionButton(
    String title,
    String subtitle,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          onTap();
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withValues(alpha: 0.1)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 28),
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
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios_rounded, color: color, size: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildManagementGrid(bool isMobile, bool isTablet, bool isDesktop) {
    final colorScheme = Theme.of(context).colorScheme;

    int crossAxisCount;
    if (isDesktop) {
      crossAxisCount = 2;
    } else if (isTablet) {
      crossAxisCount = 2;
    } else {
      crossAxisCount = 1;
    }

    final managementItems = [
      {
        'title': 'Tour Management',
        'subtitle': 'View, edit, and manage all tours',
        'icon': Icons.map_outlined,
        'color': Colors.blue,
        'onTap': () => _showComingSoon('Tour Management'),
      },
      {
        'title': 'Car Fleet',
        'subtitle': 'Manage rental car inventory',
        'icon': Icons.directions_car_outlined,
        'color': Colors.orange,
        'onTap': () => _showComingSoon('Car Fleet Management'),
      },
      {
        'title': 'House Listings',
        'subtitle': 'Manage accommodation properties',
        'icon': Icons.home_outlined,
        'color': Colors.green,
        'onTap': () => _showComingSoon('House Management'),
      },
      {
        'title': 'User Management',
        'subtitle': 'Manage users and permissions',
        'icon': Icons.people_outline,
        'color': Colors.purple,
        'onTap': () => _showComingSoon('User Management'),
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8, bottom: 16),
          child: Text(
            'Management',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
        ),
        GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: isMobile ? 2.5 : 2.0,
          ),
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: managementItems.length,
          itemBuilder: (context, index) {
            final item = managementItems[index];
            return _buildManagementCard(
              item['title'] as String,
              item['subtitle'] as String,
              item['icon'] as IconData,
              item['color'] as Color,
              item['onTap'] as VoidCallback,
            );
          },
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
    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          onTap();
        },
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: colorScheme.shadow.withValues(alpha: 0.05),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                color: colorScheme.onSurface.withValues(alpha: 0.5),
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecentActivity(bool isMobile) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8, bottom: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recent Activity',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              TextButton(
                onPressed: () => _showComingSoon('Activity Log'),
                child: Text(
                  'View All',
                  style: TextStyle(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: colorScheme.shadow.withValues(alpha: 0.05),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            children: [
              // Empty state for activities
              Container(
                padding: const EdgeInsets.all(32),
                child: Column(
                  children: [
                    Icon(
                      Icons.history_rounded,
                      size: 48,
                      color: colorScheme.onSurface.withValues(alpha: 0.3),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No Recent Activity',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: colorScheme.onSurface.withValues(alpha: 0.6),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Connect your API to see real-time activity updates',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurface.withValues(alpha: 0.5),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _navigateToTourCreate() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AdminTourCreateScreen()),
    );
  }

  void _navigateToDiscountManagement() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AdminDiscountManagementScreen(),
      ),
    );
  }

  void _showComingSoon(String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.construction_rounded, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Text('$feature feature coming soon!'),
          ],
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
