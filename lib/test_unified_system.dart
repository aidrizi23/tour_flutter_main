import 'package:flutter/material.dart';
import 'screens/tours/tour_list_screen.dart';
import 'screens/houses/house_list_screen.dart';
import 'screens/cars/car_list_screen.dart';

void main() {
  runApp(const TestUnifiedSystemApp());
}

class TestUnifiedSystemApp extends StatelessWidget {
  const TestUnifiedSystemApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Unified System Test',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const TestHomeScreen(),
    );
  }
}

class TestHomeScreen extends StatelessWidget {
  const TestHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Unified System Test'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'Test the unified filter and layout system:',
                style: TextStyle(fontSize: 18),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const TourListScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.explore_rounded),
              label: const Text('Tours (Unified)'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const HouseListScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.home_rounded),
              label: const Text('Houses (Unified)'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CarListScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.directions_car_rounded),
              label: const Text('Cars (Unified)'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              ),
            ),
            const SizedBox(height: 32),
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'All screens now use the same unified filter system and responsive layout with mobile-first design!',
                style: TextStyle(fontSize: 14, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}