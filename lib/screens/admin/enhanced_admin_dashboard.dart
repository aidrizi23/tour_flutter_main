import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/models.dart';
import '../../services/services.dart';
import '../../widgets/modern_widgets.dart';

class EnhancedAdminDashboard extends StatefulWidget {
  const EnhancedAdminDashboard({super.key});

  @override
  State<EnhancedAdminDashboard> createState() => _EnhancedAdminDashboardState();
}

class _EnhancedAdminDashboardState extends State<EnhancedAdminDashboard>
    with TickerProviderStateMixin {
  final AdminService _adminService = AdminService();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  AdminDashboardStats? _stats;
  List<RecentBooking> _recentBookings = [];
  List<UserSummary> _topUsers = [];
  List<RevenueData> _revenueData = [];

  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _loadDashboardData();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _animationController.forward();
  }

  Future<void> _loadDashboardData() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final results = await Future.wait([
        _adminService.getDashboardStats(),
        _adminService.getRecentBookings(limit: 10),
        _adminService.getTopUsers(limit: 5),
        _adminService.getRevenueData(
          startDate: DateTime.now().subtract(const Duration(days: 30)),
          endDate: DateTime.now(),
        ),
      ]);

      setState(() {
        _stats = results[0] as AdminDashboardStats;
        _recentBookings = results[1] as List<RecentBooking>;
        _topUsers = results[2] as List<UserSummary>;
        _revenueData = results[3] as List<RevenueData>;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load dashboard data: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        actions: [
          IconButton(
            onPressed: _loadDashboardData,
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh Data',
          ),
        ],
      ),
      body: _isLoading ? _buildLoadingState() : _buildContent(),
    );
  }

  Widget _buildLoadingState() {
    return const ModernLoadingIndicator();
  }

  Widget _buildContent() {
    if (_error != null) {
      return ModernErrorWidget(message: _error!, onRetry: _loadDashboardData);
    }

    return RefreshIndicator(
      onRefresh: _loadDashboardData,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildWelcomeSection(),
              const SizedBox(height: 24),
              _buildStatsGrid(),
              const SizedBox(height: 24),
              _buildRevenueChart(),
              const SizedBox(height: 24),
              _buildQuickActions(),
              const SizedBox(height: 24),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: _buildRecentBookings()),
                  const SizedBox(width: 16),
                  Expanded(child: _buildTopUsers()),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeSection() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).colorScheme.primary,
            Theme.of(context).colorScheme.secondary,
          ],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(Icons.admin_panel_settings, size: 48, color: Colors.white),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome, Admin!',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Here\'s your business overview',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid() {
    if (_stats == null) return const SizedBox.shrink();

    final statItems = [
      {
        'title': 'Total Tours',
        'value': _stats!.totalTours.toString(),
        'icon': Icons.tour,
        'color': Colors.blue,
      },
      {
        'title': 'Total Houses',
        'value': _stats!.totalHouses.toString(),
        'icon': Icons.house,
        'color': Colors.green,
      },
      {
        'title': 'Total Cars',
        'value': _stats!.totalCars.toString(),
        'icon': Icons.directions_car,
        'color': Colors.orange,
      },
      {
        'title': 'Total Users',
        'value': _stats!.totalUsers.toString(),
        'icon': Icons.people,
        'color': Colors.purple,
      },
      {
        'title': 'Total Bookings',
        'value': _stats!.totalBookings.toString(),
        'icon': Icons.book_online,
        'color': Colors.teal,
      },
      {
        'title': 'Total Revenue',
        'value': '\$${_stats!.totalRevenue.toStringAsFixed(0)}',
        'icon': Icons.attach_money,
        'color': Colors.indigo,
      },
      {
        'title': 'Monthly Revenue',
        'value': '\$${_stats!.monthlyRevenue.toStringAsFixed(0)}',
        'icon': Icons.trending_up,
        'color': Colors.pink,
      },
      {
        'title': 'Average Rating',
        'value': _stats!.averageRating.toStringAsFixed(1),
        'icon': Icons.star,
        'color': Colors.amber,
      },
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: MediaQuery.of(context).size.width > 768 ? 4 : 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.5,
      ),
      itemCount: statItems.length,
      itemBuilder: (context, index) {
        final item = statItems[index];
        return _buildStatCard(
          title: item['title'] as String,
          value: item['value'] as String,
          icon: item['icon'] as IconData,
          color: item['color'] as Color,
        );
      },
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 24),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.trending_up, size: 16, color: color),
                ),
              ],
            ),
            const Spacer(),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              title,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRevenueChart() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Revenue Trend (Last 30 Days)',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child:
                  _revenueData.isEmpty
                      ? Center(
                        child: Text(
                          'No revenue data available',
                          style: Theme.of(
                            context,
                          ).textTheme.bodyLarge?.copyWith(
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurface.withValues(alpha: 0.7),
                          ),
                        ),
                      )
                      : _buildSimpleChart(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSimpleChart() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
            Theme.of(context).colorScheme.primary.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.bar_chart,
            size: 48,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 8),
          Text(
            'Revenue Chart',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          Text(
            'Total: \$${_revenueData.fold<double>(0, (sum, data) => sum + data.amount).toStringAsFixed(2)}',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    final actions = [
      {
        'title': 'Create Tour',
        'icon': Icons.add_circle,
        'color': Colors.blue,
        'onTap': () => Navigator.pushNamed(context, '/admin/create-tour'),
      },
      {
        'title': 'Manage Houses',
        'icon': Icons.house,
        'color': Colors.green,
        'onTap': () => _showComingSoon(),
      },
      {
        'title': 'Manage Cars',
        'icon': Icons.directions_car,
        'color': Colors.orange,
        'onTap': () => _showComingSoon(),
      },
      {
        'title': 'User Analytics',
        'icon': Icons.analytics,
        'color': Colors.purple,
        'onTap': () => _showComingSoon(),
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: MediaQuery.of(context).size.width > 768 ? 4 : 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.8,
          ),
          itemCount: actions.length,
          itemBuilder: (context, index) {
            final action = actions[index];
            return ModernActionCard(
              title: action['title'] as String,
              subtitle: 'Tap to manage',
              icon: action['icon'] as IconData,
              color: action['color'] as Color,
              onTap: action['onTap'] as VoidCallback,
            );
          },
        ),
      ],
    );
  }

  Widget _buildRecentBookings() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Recent Bookings',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () => Navigator.pushNamed(context, '/bookings'),
                  child: const Text('View All'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_recentBookings.isEmpty)
              Center(
                child: Text(
                  'No recent bookings',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _recentBookings.take(5).length,
                itemBuilder: (context, index) {
                  final booking = _recentBookings[index];
                  return _buildBookingItem(booking);
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildBookingItem(RecentBooking booking) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: _getStatusColor(booking.status).withValues(alpha: 0.1),
        child: Icon(
          _getStatusIcon(booking.status),
          color: _getStatusColor(booking.status),
          size: 20,
        ),
      ),
      title: Text(
        booking.itemName,
        style: const TextStyle(fontWeight: FontWeight.w500),
      ),
      subtitle: Text('${booking.customerName} • ${booking.type}'),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            '\$${booking.amount.toStringAsFixed(2)}',
            style: Theme.of(
              context,
            ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          Text(
            booking.status,
            style: TextStyle(
              color: _getStatusColor(booking.status),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopUsers() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Top Users',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            if (_topUsers.isEmpty)
              Center(
                child: Text(
                  'No user data available',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _topUsers.length,
                itemBuilder: (context, index) {
                  final user = _topUsers[index];
                  return _buildUserItem(user, index + 1);
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserItem(UserSummary user, int rank) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Theme.of(
          context,
        ).colorScheme.primary.withValues(alpha: 0.1),
        child: Text(
          '#$rank',
          style: TextStyle(
            color: Theme.of(context).colorScheme.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      title: Text(
        user.name,
        style: const TextStyle(fontWeight: FontWeight.w500),
      ),
      subtitle: Text(user.email),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            '\$${user.totalSpent.toStringAsFixed(0)}',
            style: Theme.of(
              context,
            ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          Text(
            '${user.totalBookings} bookings',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'confirmed':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'confirmed':
        return Icons.check_circle;
      case 'pending':
        return Icons.schedule;
      case 'cancelled':
        return Icons.cancel;
      default:
        return Icons.info;
    }
  }

  void _showComingSoon() {
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Feature coming soon!'),
        duration: Duration(seconds: 2),
      ),
    );
  }
}
