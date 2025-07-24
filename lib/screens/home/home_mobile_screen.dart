import 'package:flutter/material.dart';
import '../cars/car_list_screen.dart';
import '../houses/house_list_screen.dart';
import '../tours/tour_list_screen.dart';

/// Mobile optimized home screen with tabs for tours, houses and cars.
class HomeMobileScreen extends StatelessWidget {
  const HomeMobileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('TourApp'),
          bottom: const TabBar(
            isScrollable: true,
            tabs: [
              Tab(text: 'Tours'),
              Tab(text: 'Houses'),
              Tab(text: 'Cars'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            TourListScreen(),
            HouseListScreen(),
            CarListScreen(),
          ],
        ),
      ),
    );
  }
}
