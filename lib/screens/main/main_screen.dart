import 'package:flutter/material.dart';
import '../tours/tour_list_screen.dart';
import '../cars/car_list_screen.dart';
import '../houses/house_list_screen.dart';
import '../../widgets/custom_segmented_control.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late PageController _pageController;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _onTabTapped(int index) {
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  final List<Widget> _screens = [
    const TourListScreen(),
    const CarListScreen(),
    const HouseListScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: CustomSegmentedControl(
          selectedIndex: _selectedIndex,
          onValueChanged: _onTabTapped,
          children: const ['Tours', 'Cars', 'Houses'],
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: PageView(
        controller: _pageController,
        onPageChanged: _onPageChanged,
        children: _screens,
      ),
    );
  }
}