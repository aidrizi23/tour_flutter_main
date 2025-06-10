import 'package:flutter/material.dart';
import '../../models/models.dart';
import '../../services/services.dart';
import '../../widgets/modern_widgets.dart';
import 'widgets/hero_section.dart';
import 'widgets/company_overview.dart';
import 'widgets/services_showcase.dart';
import 'widgets/featured_content.dart';
import 'widgets/stats_overview.dart';
import 'widgets/testimonials_section.dart';
import 'widgets/cta_section.dart';
import 'package:shimmer/shimmer.dart';

class EnhancedHomeScreen extends StatefulWidget {
  const EnhancedHomeScreen({super.key});

  @override
  State<EnhancedHomeScreen> createState() => _EnhancedHomeScreenState();
}

class _EnhancedHomeScreenState extends State<EnhancedHomeScreen>
    with TickerProviderStateMixin {
  final TourService _tourService = TourService();
  final HouseService _houseService = HouseService();
  final CarService _carService = CarService();

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  List<Tour> _featuredTours = [];
  List<House> _featuredHouses = [];
  List<Car> _featuredCars = [];

  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _loadHomeData();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.2, 0.8, curve: Curves.easeOut),
      ),
    );

    _animationController.forward();
  }

  Future<void> _loadHomeData() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final results = await Future.wait([
        _tourService.getTours(
          filter: TourFilterRequest(
            sortBy: 'rating',
            ascending: false,
            pageSize: 6,
          ),
        ),
        _houseService.getHouses(
          filter: HouseFilterRequest(
            sortBy: 'averageRating',
            ascending: false,
            pageSize: 4,
          ),
        ),
        _carService.getCars(
          filter: CarFilterRequest(
            sortBy: 'averageRating',
            ascending: false,
            pageSize: 4,
          ),
        ),
      ]);

      if (mounted) {
        setState(() {
          final tourResponse = results[0] as PaginatedTours;
          _featuredTours = tourResponse.items;

          final houseResponse = results[1] as PaginatedHouses;
          _featuredHouses = houseResponse.items;

          final carResponse = results[2] as PaginatedCars;
          _featuredCars = carResponse.items;

          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Failed to load content. Please try again.';
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: _isLoading ? _buildLoadingState() : _buildContent());
  }

  Widget _buildLoadingState() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: ListView.builder(
        itemCount: 4,
        itemBuilder:
            (context, index) => Shimmer.fromColors(
              baseColor: Theme.of(context).colorScheme.surfaceContainerLow,
              highlightColor: Theme.of(context).colorScheme.surface,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: ModernCard(
                  child: Container(
                    height: 120,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color: Theme.of(context).colorScheme.surface,
                    ),
                  ),
                ),
              ),
            ),
      ),
    );
  }

  Widget _buildContent() {
    if (_error != null) {
      return Center(
        child: ModernErrorWidget(message: _error!, onRetry: _loadHomeData),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadHomeData,
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: const HeroSection(),
              ),
            ),
          ),
          const SliverToBoxAdapter(child: CompanyOverview()),
          const SliverToBoxAdapter(child: ServicesShowcase()),
          const SliverToBoxAdapter(child: StatsOverview()),
          SliverToBoxAdapter(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: FeaturedContent(
                  featuredTours: _featuredTours,
                  featuredHouses: _featuredHouses,
                  featuredCars: _featuredCars,
                ),
              ),
            ),
          ),
          const SliverToBoxAdapter(child: TestimonialsSection()),
          const SliverToBoxAdapter(child: CTASection()),
          const SliverToBoxAdapter(child: SizedBox(height: 32)),
        ],
      ),
    );
  }
}
