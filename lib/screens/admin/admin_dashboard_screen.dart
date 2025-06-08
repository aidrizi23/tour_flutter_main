import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../services/auth_service.dart';
import '../../services/tour_service.dart';
import '../../services/booking_service.dart';
import '../../services/car_service.dart';
import '../../services/house_service.dart';
import '../../services/discount_service.dart';
import '../../models/tour_models.dart';
import 'admin_tour_create_screen.dart';
import 'admin_discount_management_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen>
    with TickerProviderStateMixin {
  final AuthService _authService = AuthService();
  final TourService _tourService = TourService();
  final BookingService _bookingService = BookingService();
  final CarService _carService = CarService();
  final HouseService _houseService = HouseService();
  final DiscountService _discountService = DiscountService();
  
  late AnimationController _fadeController;
  late AnimationController _chartController;
  late AnimationController _cardController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _chartAnimation;
  
  Timer? _refreshTimer;
  
  // Dashboard data
  Map<String, dynamic> _dashboardStats = {};
  List<Map<String, dynamic>> _revenueData = [];
  List<Map<String, dynamic>> _bookingsTrend = [];
  List<Map<String, dynamic>> _popularTours = [];
  List<Map<String, dynamic>> _recentActivity = [];
  bool _isLoadingStats = true;
  bool _isRealTimeMode = false;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _loadDashboardData();
    _startRealTimeUpdates();
  }

  void _setupAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _chartController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _cardController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOutCubic,
    );
    _chartAnimation = CurvedAnimation(
      parent: _chartController,
      curve: Curves.elasticOut,
    );
    
    _fadeController.forward();
    _chartController.forward();
    _cardController.forward();
  }

  void _startRealTimeUpdates() {
    _refreshTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      if (_isRealTimeMode) {
        _updateRealTimeData();
      }
    });
  }

  Future<void> _loadDashboardData() async {
    try {
      setState(() {
        _isLoadingStats = true;
      });

      // Simulate loading real dashboard data with API calls
      await Future.delayed(const Duration(milliseconds: 800));
      
      // In a real app, these would be actual API calls:
      // final tours = await _tourService.getTours();
      // final bookings = await _bookingService.getAllBookings();
      // etc.
      
      // Generate realistic dummy data for demonstration
      final now = DateTime.now();
      final random = math.Random();
      
      setState(() {
        _dashboardStats = {
          'totalTours': 47 + random.nextInt(5),
          'activeTours': 42 + random.nextInt(3),
          'totalBookings': 1247 + random.nextInt(50),
          'monthlyRevenue': 45670.50 + (random.nextDouble() * 1000),
          'todayBookings': 12 + random.nextInt(8),
          'pendingReviews': 8 + random.nextInt(5),
          'totalUsers': 2847 + random.nextInt(20),
          'activeUsers': 1543 + random.nextInt(15),
          'totalCars': 23 + random.nextInt(3),
          'totalHouses': 35 + random.nextInt(5),
          'conversionRate': 12.5 + (random.nextDouble() * 3),
          'avgBookingValue': 287.50 + (random.nextDouble() * 50),
        };
        
        // Revenue trend for the last 7 days
        _revenueData = List.generate(7, (index) {
          final date = now.subtract(Duration(days: 6 - index));
          return {
            'date': date,
            'revenue': 2000 + random.nextDouble() * 3000,
            'bookings': 8 + random.nextInt(15),
          };
        });
        
        // Bookings trend for the last 12 hours
        _bookingsTrend = List.generate(12, (index) {
          final hour = now.subtract(Duration(hours: 11 - index));
          return {
            'hour': hour,
            'bookings': random.nextInt(5),
            'revenue': random.nextDouble() * 800,
          };
        });
        
        // Popular tours data
        _popularTours = [
          {
            'id': 1,
            'name': 'Historic City Walking Tour',
            'bookings': 45 + random.nextInt(10),
            'revenue': 12850.0 + (random.nextDouble() * 500),
            'rating': 4.8,
          },
          {
            'id': 2,
            'name': 'Mountain Adventure Trek',
            'bookings': 32 + random.nextInt(8),
            'revenue': 9640.0 + (random.nextDouble() * 400),
            'rating': 4.6,
          },
          {
            'id': 3,
            'name': 'Cultural Heritage Experience',
            'bookings': 28 + random.nextInt(6),
            'revenue': 8400.0 + (random.nextDouble() * 300),
            'rating': 4.9,
          },
          {
            'id': 4,
            'name': 'Coastal Scenic Drive',
            'bookings': 23 + random.nextInt(5),
            'revenue': 6900.0 + (random.nextDouble() * 250),
            'rating': 4.7,
          },
        ];
        
        // Recent activity feed
        _recentActivity = [
          {
            'type': 'booking',
            'title': 'New booking received',
            'description': 'Mountain Adventure Trek - John Smith',
            'time': now.subtract(const Duration(minutes: 5)),
            'icon': Icons.calendar_month_rounded,
            'color': Colors.green,
          },
          {
            'type': 'review',
            'title': 'New review posted',
            'description': '5-star review for Historic City Tour',
            'time': now.subtract(const Duration(minutes: 12)),
            'icon': Icons.star_rounded,
            'color': Colors.amber,
          },
          {
            'type': 'user',
            'title': 'New user registered',
            'description': 'Sarah Johnson joined the platform',
            'time': now.subtract(const Duration(minutes: 18)),
            'icon': Icons.person_add_rounded,
            'color': Colors.blue,
          },
          {
            'type': 'tour',
            'title': 'Tour updated',
            'description': 'Cultural Heritage Experience - pricing updated',
            'time': now.subtract(const Duration(minutes: 25)),
            'icon': Icons.edit_rounded,
            'color': Colors.orange,
          },
          {
            'type': 'payment',
            'title': 'Payment processed',
            'description': '\$287.50 - Coastal Scenic Drive',
            'time': now.subtract(const Duration(minutes: 33)),
            'icon': Icons.payment_rounded,
            'color': Colors.purple,
          },
        ];
        
        _isLoadingStats = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingStats = false;
      });
      _showErrorMessage('Failed to load dashboard data: $e');
    }
  }

  Future<void> _updateRealTimeData() async {
    if (!mounted) return;
    
    final random = math.Random();
    final now = DateTime.now();
    
    setState(() {
      // Update some stats with slight variations
      _dashboardStats['todayBookings'] = (_dashboardStats['todayBookings'] as int) + (random.nextBool() ? 1 : 0);
      _dashboardStats['monthlyRevenue'] = (_dashboardStats['monthlyRevenue'] as double) + (random.nextDouble() * 100);
      
      // Add new activity if random chance
      if (random.nextDouble() < 0.3) {
        final activities = [
          {
            'type': 'booking',
            'title': 'Live booking received',
            'description': 'New booking just came in!',
            'time': now,
            'icon': Icons.notifications_active_rounded,
            'color': Colors.green,
          },
          {
            'type': 'view',
            'title': 'High traffic detected',
            'description': 'Tour page views increased',
            'time': now,
            'icon': Icons.trending_up_rounded,
            'color': Colors.blue,
          },
        ];
        
        _recentActivity.insert(0, activities[random.nextInt(activities.length)]);
        
        // Keep only recent 10 activities
        if (_recentActivity.length > 10) {
          _recentActivity = _recentActivity.take(10).toList();
        }
      }
    });
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red.shade700,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    _fadeController.dispose();
    _chartController.dispose();
    _cardController.dispose();
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
      child: RefreshIndicator(
        onRefresh: _loadDashboardData,
        child: CustomScrollView(
          slivers: [
              // Modern App Bar
              _buildModernAppBar(colorScheme, isMobile),
              
              // Dashboard Content
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(isMobile ? 16 : 24),
                  child: Column(
                    children: [
                      // Real-time toggle and quick stats
                      _buildQuickStatsHeader(colorScheme, isMobile),
                      const SizedBox(height: 24),
                      
                      // Main statistics grid
                      _buildMainStatsGrid(colorScheme, isDesktop, isTablet, isMobile),
                      const SizedBox(height: 32),
                      
                      // Charts and analytics row
                      if (isDesktop)
                        _buildDesktopChartsRow(colorScheme)
                      else
                        _buildMobileChartsColumn(colorScheme, isMobile),
                      const SizedBox(height: 32),
                      
                      // Popular tours and recent activity
                      if (isDesktop)
                        _buildDesktopBottomRow(colorScheme)
                      else
                        _buildMobileBottomColumn(colorScheme, isMobile),
                      const SizedBox(height: 32),
                      
                      // Quick actions panel
                      _buildQuickActionsPanel(colorScheme, isMobile, isTablet),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
  }

  Widget _buildModernAppBar(ColorScheme colorScheme, bool isMobile) {
    return SliverAppBar(
      expandedHeight: isMobile ? 120 : 160,
      floating: false,
      pinned: true,
      elevation: 0,
      backgroundColor: colorScheme.surface,
      foregroundColor: colorScheme.onSurface,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                colorScheme.primaryContainer,
                colorScheme.secondaryContainer,
              ],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: EdgeInsets.all(isMobile ? 16 : 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(isMobile ? 12 : 16),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [colorScheme.primary, colorScheme.secondary],
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: colorScheme.primary.withValues(alpha: 0.3),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.dashboard_rounded,
                          color: Colors.white,
                          size: isMobile ? 24 : 32,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Admin Dashboard',
                              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: colorScheme.onPrimaryContainer,
                              ),
                            ),
                            if (!isMobile) ...[
                              const SizedBox(height: 4),
                              FutureBuilder<String?>(
                                future: _authService.getCurrentUser().then((user) => user?.userName),
                                builder: (context, snapshot) => Text(
                                  'Welcome back, ${snapshot.data ?? 'Admin'}! Here\'s your business overview.',
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: colorScheme.onPrimaryContainer.withValues(alpha: 0.8),
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      if (!isMobile)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: _isRealTimeMode ? Colors.green : colorScheme.surface,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: _isRealTimeMode ? Colors.white : Colors.green,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                _isRealTimeMode ? 'Live' : 'Static',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: _isRealTimeMode ? Colors.white : colorScheme.onSurface,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuickStatsHeader(ColorScheme colorScheme, bool isMobile) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Real-time Overview',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Row(
                children: [
                  Text(
                    'Live Updates',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(width: 8),
                  Switch(
                    value: _isRealTimeMode,
                    onChanged: (value) {
                      setState(() {
                        _isRealTimeMode = value;
                      });
                      HapticFeedback.lightImpact();
                    },
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (!isMobile)
            IntrinsicHeight(
              child: Row(
                children: [
                  _buildQuickStat(
                    'Today\'s Revenue',
                    '\$${(_dashboardStats['monthlyRevenue'] ?? 0.0).toStringAsFixed(0)}',
                    Icons.trending_up_rounded,
                    Colors.green,
                    '+12.5%',
                  ),
                  const VerticalDivider(),
                  _buildQuickStat(
                    'Active Users',
                    '${_dashboardStats['activeUsers'] ?? 0}',
                    Icons.people_rounded,
                    Colors.blue,
                    '+5.2%',
                  ),
                  const VerticalDivider(),
                  _buildQuickStat(
                    'Conversion Rate',
                    '${(_dashboardStats['conversionRate'] ?? 0.0).toStringAsFixed(1)}%',
                    Icons.analytics_rounded,
                    Colors.purple,
                    '+2.1%',
                  ),
                ],
              ),
            )
          else
            Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _buildQuickStat(
                        'Revenue',
                        '\$${(_dashboardStats['monthlyRevenue'] ?? 0.0).toStringAsFixed(0)}',
                        Icons.trending_up_rounded,
                        Colors.green,
                        '+12.5%',
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildQuickStat(
                        'Users',
                        '${_dashboardStats['activeUsers'] ?? 0}',
                        Icons.people_rounded,
                        Colors.blue,
                        '+5.2%',
                      ),
                    ),
                  ],
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildQuickStat(String title, String value, IconData icon, Color color, String trend) {
    return Expanded(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            trend,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.green,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainStatsGrid(ColorScheme colorScheme, bool isDesktop, bool isTablet, bool isMobile) {
    final crossAxisCount = isDesktop ? 4 : (isTablet ? 3 : 2);
    
    final stats = [
      {
        'title': 'Total Tours',
        'value': '${_dashboardStats['totalTours'] ?? 0}',
        'subtitle': '${_dashboardStats['activeTours'] ?? 0} active',
        'icon': Icons.map_rounded,
        'color': Colors.blue,
        'trend': '+5.2%',
        'isPositive': true,
      },
      {
        'title': 'Monthly Revenue',
        'value': '\$${(_dashboardStats['monthlyRevenue'] ?? 0.0).toStringAsFixed(0)}',
        'subtitle': 'This month',
        'icon': Icons.attach_money_rounded,
        'color': Colors.green,
        'trend': '+18.7%',
        'isPositive': true,
      },
      {
        'title': 'Total Bookings',
        'value': '${_dashboardStats['totalBookings'] ?? 0}',
        'subtitle': '${_dashboardStats['todayBookings'] ?? 0} today',
        'icon': Icons.calendar_month_rounded,
        'color': Colors.orange,
        'trend': '+12.4%',
        'isPositive': true,
      },
      {
        'title': 'Total Users',
        'value': '${_dashboardStats['totalUsers'] ?? 0}',
        'subtitle': '${_dashboardStats['activeUsers'] ?? 0} active',
        'icon': Icons.people_rounded,
        'color': Colors.purple,
        'trend': '+8.9%',
        'isPositive': true,
      },
      {
        'title': 'Car Fleet',
        'value': '${_dashboardStats['totalCars'] ?? 0}',
        'subtitle': 'Available vehicles',
        'icon': Icons.directions_car_rounded,
        'color': Colors.indigo,
        'trend': '+2.1%',
        'isPositive': true,
      },
      {
        'title': 'House Listings',
        'value': '${_dashboardStats['totalHouses'] ?? 0}',
        'subtitle': 'Active properties',
        'icon': Icons.home_rounded,
        'color': Colors.teal,
        'trend': '+7.3%',
        'isPositive': true,
      },
      {
        'title': 'Avg. Booking Value',
        'value': '\$${(_dashboardStats['avgBookingValue'] ?? 0.0).toStringAsFixed(0)}',
        'subtitle': 'Per transaction',
        'icon': Icons.monetization_on_rounded,
        'color': Colors.amber,
        'trend': '+3.2%',
        'isPositive': true,
      },
      {
        'title': 'Pending Reviews',
        'value': '${_dashboardStats['pendingReviews'] ?? 0}',
        'subtitle': 'Need attention',
        'icon': Icons.rate_review_rounded,
        'color': Colors.red,
        'trend': '-15.6%',
        'isPositive': false,
      },
    ];

    return AnimatedBuilder(
      animation: _cardController,
      builder: (context, child) {
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: isMobile ? 1.2 : 1.3,
          ),
          itemCount: stats.length,
          itemBuilder: (context, index) {
            final stat = stats[index];
            final delay = index * 0.1;
            final animationValue = Curves.easeOutCubic.transform(
              (_cardController.value - delay).clamp(0.0, 1.0),
            );
            
            return Transform.translate(
              offset: Offset(0, 30 * (1 - animationValue)),
              child: Opacity(
                opacity: animationValue,
                child: _buildStatCard(
                  stat['title'] as String,
                  stat['value'] as String,
                  stat['subtitle'] as String,
                  stat['icon'] as IconData,
                  stat['color'] as Color,
                  stat['trend'] as String,
                  stat['isPositive'] as bool,
                  colorScheme,
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    String subtitle,
    IconData icon,
    Color color,
    String trend,
    bool isPositive,
    ColorScheme colorScheme,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(
          color: color.withValues(alpha: 0.1),
          width: 1,
        ),
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
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isPositive ? Colors.green.withValues(alpha: 0.1) : Colors.red.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isPositive ? Icons.trending_up_rounded : Icons.trending_down_rounded,
                      color: isPositive ? Colors.green : Colors.red,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      trend,
                      style: TextStyle(
                        color: isPositive ? Colors.green : Colors.red,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: colorScheme.onSurface.withValues(alpha: 0.8),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopChartsRow(ColorScheme colorScheme) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: _buildRevenueChart(colorScheme),
        ),
        const SizedBox(width: 24),
        Expanded(
          child: _buildBookingsTrendChart(colorScheme),
        ),
      ],
    );
  }

  Widget _buildMobileChartsColumn(ColorScheme colorScheme, bool isMobile) {
    return Column(
      children: [
        _buildRevenueChart(colorScheme),
        const SizedBox(height: 24),
        _buildBookingsTrendChart(colorScheme),
      ],
    );
  }

  Widget _buildRevenueChart(ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Revenue Trend',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Last 7 days',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.trending_up_rounded, color: Colors.green, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      '+18.7%',
                      style: TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          AnimatedBuilder(
            animation: _chartAnimation,
            builder: (context, child) {
              return SizedBox(
                height: 200,
                child: _buildSimpleLineChart(_revenueData, colorScheme),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBookingsTrendChart(ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Bookings',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Last 12 hours',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
              Icon(
                Icons.bar_chart_rounded,
                color: colorScheme.primary,
              ),
            ],
          ),
          const SizedBox(height: 24),
          AnimatedBuilder(
            animation: _chartAnimation,
            builder: (context, child) {
              return SizedBox(
                height: 200,
                child: _buildSimpleBarChart(_bookingsTrend, colorScheme),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSimpleLineChart(List<Map<String, dynamic>> data, ColorScheme colorScheme) {
    if (data.isEmpty) return const Center(child: Text('No data available'));
    
    final maxRevenue = data.map((e) => e['revenue'] as double).reduce(math.max);
    
    return CustomPaint(
      painter: LineChartPainter(
        data: data,
        maxValue: maxRevenue,
        color: colorScheme.primary,
        animationValue: _chartAnimation.value,
      ),
      child: Container(),
    );
  }

  Widget _buildSimpleBarChart(List<Map<String, dynamic>> data, ColorScheme colorScheme) {
    if (data.isEmpty) return const Center(child: Text('No data available'));
    
    final maxBookings = data.map((e) => e['bookings'] as int).reduce(math.max);
    
    return CustomPaint(
      painter: BarChartPainter(
        data: data,
        maxValue: maxBookings.toDouble(),
        color: colorScheme.secondary,
        animationValue: _chartAnimation.value,
      ),
      child: Container(),
    );
  }

  Widget _buildDesktopBottomRow(ColorScheme colorScheme) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: _buildPopularToursPanel(colorScheme),
        ),
        const SizedBox(width: 24),
        Expanded(
          child: _buildRecentActivityPanel(colorScheme),
        ),
      ],
    );
  }

  Widget _buildMobileBottomColumn(ColorScheme colorScheme, bool isMobile) {
    return Column(
      children: [
        _buildPopularToursPanel(colorScheme),
        const SizedBox(height: 24),
        _buildRecentActivityPanel(colorScheme),
      ],
    );
  }

  Widget _buildPopularToursPanel(ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Popular Tours',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: () => _showComingSoon('Detailed Analytics'),
                child: Text('View All'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...List.generate(_popularTours.length, (index) {
            final tour = _popularTours[index];
            return _buildPopularTourItem(tour, colorScheme);
          }),
        ],
      ),
    );
  }

  Widget _buildPopularTourItem(Map<String, dynamic> tour, ColorScheme colorScheme) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainer.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.outline.withValues(alpha: 0.1),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [colorScheme.primary, colorScheme.secondary],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.tour_rounded,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tour['name'],
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.star_rounded, color: Colors.amber, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      tour['rating'].toStringAsFixed(1),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Icon(Icons.people_rounded, color: colorScheme.outline, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      '${tour['bookings']} bookings',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '\$${tour['revenue'].toStringAsFixed(0)}',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.primary,
                ),
              ),
              Text(
                'revenue',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRecentActivityPanel(ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recent Activity',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (_isRealTimeMode)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Live',
                        style: TextStyle(
                          color: Colors.green,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          ...List.generate(math.min(_recentActivity.length, 5), (index) {
            final activity = _recentActivity[index];
            return _buildActivityItem(activity, colorScheme);
          }),
          if (_recentActivity.length > 5)
            TextButton(
              onPressed: () => _showComingSoon('Activity Feed'),
              child: Text('View All Activities'),
            ),
        ],
      ),
    );
  }

  Widget _buildActivityItem(Map<String, dynamic> activity, ColorScheme colorScheme) {
    final time = activity['time'] as DateTime;
    final timeAgo = _getTimeAgo(time);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: (activity['color'] as Color).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              activity['icon'],
              color: activity['color'],
              size: 16,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activity['title'],
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  activity['description'],
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
          Text(
            timeAgo,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurface.withValues(alpha: 0.5),
            ),
          ),
        ],
      ),
    );
  }

  String _getTimeAgo(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);
    
    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }

  Widget _buildQuickActionsPanel(ColorScheme colorScheme, bool isMobile, bool isTablet) {
    final actions = [
      {
        'title': 'Create New Tour',
        'subtitle': 'Add a new tour experience',
        'icon': Icons.add_location_alt_rounded,
        'color': colorScheme.primary,
        'onTap': () => _navigateToTourCreate(),
      },
      {
        'title': 'Manage Discounts',
        'subtitle': 'Create and edit promotions',
        'icon': Icons.local_offer_rounded,
        'color': Colors.purple,
        'onTap': () => _navigateToDiscountManagement(),
      },
      {
        'title': 'View Analytics',
        'subtitle': 'Detailed business insights',
        'icon': Icons.analytics_rounded,
        'color': Colors.blue,
        'onTap': () => _showComingSoon('Advanced Analytics'),
      },
      {
        'title': 'Export Reports',
        'subtitle': 'Download business reports',
        'icon': Icons.file_download_rounded,
        'color': Colors.green,
        'onTap': () => _showComingSoon('Report Export'),
      },
    ];

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quick Actions',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: isMobile ? 1 : (isTablet ? 2 : 4),
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: isMobile ? 4 : 2.5,
            ),
            itemCount: actions.length,
            itemBuilder: (context, index) {
              final action = actions[index];
              return _buildQuickActionCard(
                action['title'] as String,
                action['subtitle'] as String,
                action['icon'] as IconData,
                action['color'] as Color,
                action['onTap'] as VoidCallback,
                colorScheme,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionCard(
    String title,
    String subtitle,
    IconData icon,
    Color color,
    VoidCallback onTap,
    ColorScheme colorScheme,
  ) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          onTap();
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: color.withValues(alpha: 0.2),
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                color: color,
                size: 16,
              ),
            ],
          ),
        ),
      ),
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
      MaterialPageRoute(builder: (context) => const AdminDiscountManagementScreen()),
    );
  }

  void _showComingSoon(String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.rocket_launch_rounded, color: Colors.white, size: 20),
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

// Custom painters for charts
class LineChartPainter extends CustomPainter {
  final List<Map<String, dynamic>> data;
  final double maxValue;
  final Color color;
  final double animationValue;

  LineChartPainter({
    required this.data,
    required this.maxValue,
    required this.color,
    required this.animationValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final paint = Paint()
      ..color = color
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final pointPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();
    final points = <Offset>[];

    for (int i = 0; i < data.length; i++) {
      final x = (i / (data.length - 1)) * size.width;
      final revenue = data[i]['revenue'] as double;
      final y = size.height - (revenue / maxValue) * size.height * animationValue;
      
      final point = Offset(x, y);
      points.add(point);
      
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    // Draw line
    canvas.drawPath(path, paint);

    // Draw points
    for (final point in points) {
      canvas.drawCircle(point, 4, pointPaint);
    }

    // Draw fill gradient
    final gradientPath = Path.from(path);
    gradientPath.lineTo(size.width, size.height);
    gradientPath.lineTo(0, size.height);
    gradientPath.close();

    final gradientPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          color.withValues(alpha: 0.3),
          color.withValues(alpha: 0.1),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawPath(gradientPath, gradientPaint);
  }

  @override
  bool shouldRepaint(LineChartPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue;
  }
}

class BarChartPainter extends CustomPainter {
  final List<Map<String, dynamic>> data;
  final double maxValue;
  final Color color;
  final double animationValue;

  BarChartPainter({
    required this.data,
    required this.maxValue,
    required this.color,
    required this.animationValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final barWidth = size.width / data.length * 0.6;
    final spacing = size.width / data.length * 0.4;

    for (int i = 0; i < data.length; i++) {
      final bookings = data[i]['bookings'] as int;
      final barHeight = (bookings / maxValue) * size.height * animationValue;
      
      final x = i * (barWidth + spacing) + spacing / 2;
      final y = size.height - barHeight;
      
      final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(x, y, barWidth, barHeight),
        const Radius.circular(4),
      );
      
      canvas.drawRRect(rect, paint);
    }
  }

  @override
  bool shouldRepaint(BarChartPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue;
  }
}