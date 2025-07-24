import 'package:flutter/material.dart';
import '../cars/car_list_screen.dart';
import '../tours/tour_list_screen.dart';

/// Mobile optimized home screen with tabs for tours and cars.
class HomeMobileScreen extends StatelessWidget {
  const HomeMobileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('TourApp'),
          bottom: const TabBar(tabs: [Tab(text: 'Tours'), Tab(text: 'Cars')]),
        ),
        body: const TabBarView(children: [TourListScreen(), CarListScreen()]),
      ),
    );
  }
}
