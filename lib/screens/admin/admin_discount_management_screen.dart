import 'package:flutter/material.dart';
import '../../models/discount_models.dart';
import '../../services/discount_service.dart';
import '../../widgets/modern_widgets.dart';
import '../../widgets/custom_text_field.dart';
import 'discount_create_screen.dart';

class AdminDiscountManagementScreen extends StatefulWidget {
  const AdminDiscountManagementScreen({super.key});

  @override
  State<AdminDiscountManagementScreen> createState() =>
      _AdminDiscountManagementScreenState();
}

class _AdminDiscountManagementScreenState
    extends State<AdminDiscountManagementScreen>
    with TickerProviderStateMixin {
  final DiscountService _discountService = DiscountService();
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  List<Discount> _discounts = [];
  bool _isLoading = true;
  bool _isLoadingMore = false;
  String _error = '';
  int _currentPage = 1;
  bool _hasMoreData = true;

  // Filter states
  DiscountType? _selectedType;
  bool? _isActive;
  bool _showExpired = false;

  // Animation controllers
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  // Statistics
  Map<String, dynamic> _statistics = {};

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _loadDiscounts();
    _loadStatistics();
    _setupScrollListener();
  }

  void _setupAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeOut));
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOut));

    _fadeController.forward();
    _slideController.forward();
  }

  void _setupScrollListener() {
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent * 0.8) {
        _loadMoreDiscounts();
      }
    });
  }

  Future<void> _loadDiscounts({bool refresh = false}) async {
    if (refresh) {
      setState(() {
        _currentPage = 1;
        _hasMoreData = true;
        _discounts.clear();
        _isLoading = true;
        _error = '';
      });
    }

    try {
      final filter = _buildFilter();
      final result = await _discountService.getDiscounts(filter: filter);

      if (mounted) {
        setState(() {
          if (refresh) {
            _discounts = result.items;
          } else {
            _discounts.addAll(result.items);
          }
          _hasMoreData = result.hasNextPage;
          _isLoading = false;
          _isLoadingMore = false;
          _error = '';
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
          _isLoadingMore = false;
        });
      }
    }
  }

  Future<void> _loadMoreDiscounts() async {
    if (_isLoadingMore || !_hasMoreData) return;

    setState(() {
      _isLoadingMore = true;
      _currentPage++;
    });

    await _loadDiscounts();
  }

  Future<void> _loadStatistics() async {
    try {
      final stats = await _discountService.getDiscountStatistics();
      if (mounted) {
        setState(() {
          _statistics = stats;
        });
      }
    } catch (e) {
      // Handle error silently for statistics
    }
  }

  DiscountFilterRequest _buildFilter() {
    return DiscountFilterRequest(
      searchTerm:
          _searchController.text.isNotEmpty ? _searchController.text : null,
      type: _selectedType,
      isActive: _isActive,
      showExpired: _showExpired,
      pageIndex: _currentPage,
      pageSize: 15,
      sortBy: 'createdAt',
      ascending: false,
    );
  }

  void _clearFilters() {
    setState(() {
      _selectedType = null;
      _isActive = null;
      _showExpired = false;
      _searchController.clear();
    });
    _loadDiscounts(refresh: true);
  }

  int _getActiveFilterCount() {
    int count = 0;
    if (_selectedType != null) count++;
    if (_isActive != null) count++;
    if (_showExpired) count++;
    if (_searchController.text.isNotEmpty) count++;
    return count;
  }

  Future<void> _toggleDiscountStatus(Discount discount) async {
    try {
      final updatedDiscount = await _discountService.toggleDiscountStatus(
        discount.id,
      );

      setState(() {
        final index = _discounts.indexWhere((d) => d.id == discount.id);
        if (index != -1) {
          _discounts[index] = updatedDiscount;
        }
      });

      if (mounted) {
        ModernSnackBar.show(
          context,
          message:
              updatedDiscount.isActive
                  ? 'Discount activated successfully'
                  : 'Discount deactivated successfully',
          type: SnackBarType.success,
        );
      }
    } catch (e) {
      if (mounted) {
        ModernSnackBar.show(
          context,
          message: 'Failed to update discount status: $e',
          type: SnackBarType.error,
        );
      }
    }
  }

  Future<void> _deleteDiscount(Discount discount) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Delete Discount'),
            content: Text(
              'Are you sure you want to delete the discount "${discount.name}"? This action cannot be undone.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: FilledButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.error,
                ),
                child: const Text('Delete'),
              ),
            ],
          ),
    );

    if (confirmed != true) return;

    try {
      await _discountService.deleteDiscount(discount.id);

      setState(() {
        _discounts.removeWhere((d) => d.id == discount.id);
      });

      if (mounted) {
        ModernSnackBar.show(
          context,
          message: 'Discount deleted successfully',
          type: SnackBarType.success,
        );
      }

      // Reload statistics
      _loadStatistics();
    } catch (e) {
      if (mounted) {
        ModernSnackBar.show(
          context,
          message: 'Failed to delete discount: $e',
          type: SnackBarType.error,
        );
      }
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Discount Management'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () {
              _loadDiscounts(refresh: true);
              _loadStatistics();
            },
          ),
          IconButton(
            icon: const Icon(Icons.add_rounded),
            onPressed: _navigateToCreateDiscount,
          ),
        ],
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: Column(
            children: [
              _buildStatistics(),
              _buildSearchAndFilters(),
              Expanded(
                child:
                    _isLoading && _discounts.isEmpty
                        ? const ModernLoadingState(
                          message: 'Loading discount codes...',
                        )
                        : _error.isNotEmpty && _discounts.isEmpty
                        ? ModernErrorState(
                          title: 'Failed to load discounts',
                          message: _error,
                          actionText: 'Retry',
                          onRetry: () => _loadDiscounts(refresh: true),
                        )
                        : _discounts.isEmpty
                        ? const ModernEmptyState(
                          icon: Icons.discount_outlined,
                          title: 'No discounts yet',
                          description:
                              'Create your first discount code to get started.',
                          actionText: 'Create Discount',
                        )
                        : _buildDiscountList(),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _navigateToCreateDiscount,
        icon: const Icon(Icons.add_rounded),
        label: const Text('New Discount'),
      ),
    );
  }

  Widget _buildStatistics() {
    if (_statistics.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.all(16),
      child: ModernCard(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Discount Statistics',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Total Discounts',
                    '${_statistics['totalDiscounts'] ?? 0}',
                    Icons.discount,
                    Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    'Active',
                    '${_statistics['activeDiscounts'] ?? 0}',
                    Icons.check_circle,
                    Colors.green,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    'Used Today',
                    '${_statistics['usedToday'] ?? 0}',
                    Icons.trending_up,
                    Colors.orange,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilters() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Search bar
          CustomTextField(
            controller: _searchController,
            label: 'Search discounts',
            hint: 'Search by code, name, or description',
            prefixIcon: Icons.search_rounded,
            suffixIcon:
                _searchController.text.isNotEmpty
                    ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        _loadDiscounts(refresh: true);
                      },
                    )
                    : null,
            onChanged: (value) {
              // Debounce search
              Future.delayed(const Duration(milliseconds: 500), () {
                if (_searchController.text == value) {
                  _loadDiscounts(refresh: true);
                }
              });
            },
          ),
          const SizedBox(height: 16),

          // Filter chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                ModernFilterButton(
                  onPressed: _showFilterDialog,
                  hasActiveFilters: _getActiveFilterCount() > 0,
                  filterCount: _getActiveFilterCount(),
                ),
                const SizedBox(width: 12),
                ModernChip(
                  label: 'All Types',
                  selected: _selectedType == null,
                  onTap: () {
                    setState(() {
                      _selectedType = null;
                    });
                    _loadDiscounts(refresh: true);
                  },
                ),
                const SizedBox(width: 8),
                ModernChip(
                  label: 'Percentage',
                  selected: _selectedType == DiscountType.percentage,
                  icon: Icons.percent,
                  onTap: () {
                    setState(() {
                      _selectedType = DiscountType.percentage;
                    });
                    _loadDiscounts(refresh: true);
                  },
                ),
                const SizedBox(width: 8),
                ModernChip(
                  label: 'Fixed Amount',
                  selected: _selectedType == DiscountType.fixedAmount,
                  icon: Icons.attach_money,
                  onTap: () {
                    setState(() {
                      _selectedType = DiscountType.fixedAmount;
                    });
                    _loadDiscounts(refresh: true);
                  },
                ),
                const SizedBox(width: 8),
                ModernChip(
                  label:
                      _isActive == true
                          ? 'Active Only'
                          : _isActive == false
                          ? 'Inactive Only'
                          : 'All Status',
                  selected: _isActive != null,
                  icon:
                      _isActive == true
                          ? Icons.check_circle
                          : _isActive == false
                          ? Icons.block
                          : Icons.radio_button_checked,
                  onTap: () {
                    setState(() {
                      if (_isActive == null) {
                        _isActive = true;
                      } else if (_isActive == true) {
                        _isActive = false;
                      } else {
                        _isActive = null;
                      }
                    });
                    _loadDiscounts(refresh: true);
                  },
                ),
                if (_getActiveFilterCount() > 0) ...[
                  const SizedBox(width: 8),
                  ModernChip(
                    label: 'Clear Filters',
                    icon: Icons.clear,
                    onTap: _clearFilters,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDiscountList() {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _discounts.length + (_isLoadingMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == _discounts.length) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: CircularProgressIndicator(),
            ),
          );
        }

        final discount = _discounts[index];
        return _buildDiscountCard(discount);
      },
    );
  }

  Widget _buildDiscountCard(Discount discount) {
    final colorScheme = Theme.of(context).colorScheme;

    return ModernCard(
      margin: const EdgeInsets.only(bottom: 12),
      onTap: () => _navigateToDiscountDetail(discount),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color:
                      discount.type == DiscountType.percentage
                          ? Colors.purple.withOpacity(0.1)
                          : Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  discount.type.icon,
                  color:
                      discount.type == DiscountType.percentage
                          ? Colors.purple
                          : Colors.green,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: colorScheme.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            discount.code,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: colorScheme.primary,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        ModernTag(
                          label: discount.statusText,
                          backgroundColor: discount.statusColor.withOpacity(
                            0.1,
                          ),
                          textColor: discount.statusColor,
                          icon: discount.statusIcon,
                          isSmall: true,
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      discount.name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (discount.description != null)
                      Text(
                        discount.description!,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurface.withOpacity(0.7),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    discount.formattedValue,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.primary,
                    ),
                  ),
                  Text(
                    discount.usageText,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Details
          Row(
            children: [
              Expanded(
                child: _buildInfoItem(
                  'Valid Until',
                  '${discount.endDate.day}/${discount.endDate.month}/${discount.endDate.year}',
                  Icons.calendar_today,
                ),
              ),
              Expanded(
                child: _buildInfoItem(
                  'Min Amount',
                  discount.minimumAmount != null
                      ? '\$${discount.minimumAmount!.toStringAsFixed(2)}'
                      : 'No limit',
                  Icons.money,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Actions
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _toggleDiscountStatus(discount),
                  icon: Icon(
                    discount.isActive ? Icons.pause : Icons.play_arrow,
                  ),
                  label: Text(discount.isActive ? 'Deactivate' : 'Activate'),
                ),
              ),
              const SizedBox(width: 12),
              OutlinedButton.icon(
                onPressed: () => _deleteDiscount(discount),
                icon: const Icon(Icons.delete_outline),
                label: const Text('Delete'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: colorScheme.error,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(String label, String value, IconData icon) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        Icon(icon, size: 16, color: colorScheme.primary),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
            Text(
              value,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ],
    );
  }

  void _showFilterDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => DraggableScrollableSheet(
            initialChildSize: 0.7,
            maxChildSize: 0.9,
            minChildSize: 0.5,
            builder:
                (context, scrollController) => Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                  ),
                  child: Column(
                    children: [
                      // Handle
                      Container(
                        margin: const EdgeInsets.symmetric(vertical: 12),
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.outline,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      // Content
                      Expanded(
                        child: ListView(
                          controller: scrollController,
                          padding: const EdgeInsets.all(20),
                          children: [
                            Text(
                              'Filter Discounts',
                              style: Theme.of(context).textTheme.headlineSmall
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 24),

                            // Type filter
                            Text(
                              'Discount Type',
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 12),
                            Wrap(
                              spacing: 8,
                              children: [
                                ModernChip(
                                  label: 'All',
                                  selected: _selectedType == null,
                                  onTap:
                                      () =>
                                          setState(() => _selectedType = null),
                                ),
                                ModernChip(
                                  label: 'Percentage',
                                  selected:
                                      _selectedType == DiscountType.percentage,
                                  icon: Icons.percent,
                                  onTap:
                                      () => setState(
                                        () =>
                                            _selectedType =
                                                DiscountType.percentage,
                                      ),
                                ),
                                ModernChip(
                                  label: 'Fixed Amount',
                                  selected:
                                      _selectedType == DiscountType.fixedAmount,
                                  icon: Icons.attach_money,
                                  onTap:
                                      () => setState(
                                        () =>
                                            _selectedType =
                                                DiscountType.fixedAmount,
                                      ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),

                            // Status filter
                            Text(
                              'Status',
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 12),
                            Wrap(
                              spacing: 8,
                              children: [
                                ModernChip(
                                  label: 'All',
                                  selected: _isActive == null,
                                  onTap: () => setState(() => _isActive = null),
                                ),
                                ModernChip(
                                  label: 'Active',
                                  selected: _isActive == true,
                                  icon: Icons.check_circle,
                                  onTap: () => setState(() => _isActive = true),
                                ),
                                ModernChip(
                                  label: 'Inactive',
                                  selected: _isActive == false,
                                  icon: Icons.block,
                                  onTap:
                                      () => setState(() => _isActive = false),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),

                            // Show expired toggle
                            SwitchListTile(
                              title: const Text('Show Expired Discounts'),
                              subtitle: const Text(
                                'Include expired discount codes in results',
                              ),
                              value: _showExpired,
                              onChanged:
                                  (value) =>
                                      setState(() => _showExpired = value),
                            ),
                            const SizedBox(height: 24),

                            // Action buttons
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton(
                                    onPressed: () {
                                      _clearFilters();
                                      Navigator.pop(context);
                                    },
                                    child: const Text('Clear All'),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: FilledButton(
                                    onPressed: () {
                                      _loadDiscounts(refresh: true);
                                      Navigator.pop(context);
                                    },
                                    child: const Text('Apply Filters'),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
          ),
    );
  }

  void _navigateToCreateDiscount() async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (context) => const DiscountCreateScreen()),
    );

    if (result == true) {
      _loadDiscounts(refresh: true);
      _loadStatistics();
    }
  }

  void _navigateToDiscountDetail(Discount discount) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => DiscountCreateScreen(discount: discount),
      ),
    );

    if (result == true) {
      _loadDiscounts(refresh: true);
      _loadStatistics();
    }
  }
}
