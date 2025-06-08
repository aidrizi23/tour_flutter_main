import 'package:flutter/material.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/home/home_web_screen.dart';
import '../screens/tours/tour_list_screen.dart';
import '../screens/cars/car_list_screen.dart';
import '../screens/admin/admin_panel_screen.dart';
import '../screens/admin/admin_tour_create_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../screens/booking/booking_screen.dart';
import '../screens/recommendation/recommendation_screen.dart';

class AppRoutes {
  static const login = '/login';
  static const register = '/register';
  static const home = '/home';
  static const tours = '/tours';
  static const cars = '/cars';
  static const adminPanel = '/admin-panel';
  static const adminCreateTour = '/admin/create-tour';
  static const profile = '/profile';
  static const bookings = '/bookings';
  static const recommendations = '/recommendations';

  static Map<String, WidgetBuilder> get routes => {
    login: (context) => const LoginScreen(),
    register: (context) => const RegisterScreen(),
    home: (context) => const HomeWebScreen(),
    tours: (context) => const TourListScreen(),
    cars: (context) => const CarListScreen(),
    adminPanel: (context) => const AdminPanelScreen(),
    adminCreateTour: (context) => const AdminTourCreateScreen(),
    profile: (context) => const ProfileScreen(),
    bookings: (context) => const BookingScreen(),
    recommendations: (context) => const RecommendationScreen(),
  };
}
