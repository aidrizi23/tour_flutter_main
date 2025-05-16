import 'package:flutter/material.dart';

class AdminPanelScreen extends StatelessWidget {
  const AdminPanelScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Panel'),
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: <Widget>[
          // Card for Tour Management
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ExpansionTile(
              leading: Icon(Icons.tour, color: colorScheme.primary),
              title: Text(
                'Tour Management',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.primary,
                ),
              ),
              children: <Widget>[
                ListTile(
                  leading: const Icon(Icons.add_circle_outline),
                  title: const Text('Create New Tour'),
                  subtitle: const Text('Add a new tour to the catalog.'),
                  onTap: () {
                    Navigator.pushNamed(context, '/admin/create-tour');
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.edit_note),
                  title: const Text('Manage Existing Tours'),
                  subtitle: const Text('Edit or remove current tours.'),
                  onTap: () {
                    // TODO: Navigate to a screen for managing existing tours
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Manage Tours - Coming Soon!'),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Card for Car Management
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ExpansionTile(
              leading: Icon(Icons.directions_car, color: colorScheme.secondary),
              title: Text(
                'Car Management',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.secondary,
                ),
              ),
              children: <Widget>[
                ListTile(
                  leading: const Icon(Icons.add_circle_outline),
                  title: const Text('Create New Car Listing'),
                  subtitle: const Text('Add a new car to the rental fleet.'),
                  onTap: () {
                    Navigator.pushNamed(context, '/admin/create-car');
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.edit_note),
                  title: const Text('Manage Existing Cars'),
                  subtitle: const Text('Edit or remove current car listings.'),
                  onTap: () {
                    // TODO: Navigate to a screen for managing existing cars
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Manage Cars - Coming Soon!'),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Card for User Management
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ExpansionTile(
              leading: Icon(Icons.group, color: colorScheme.tertiary),
              title: Text(
                'User Management',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.tertiary,
                ),
              ),
              children: <Widget>[
                ListTile(
                  leading: const Icon(Icons.list_alt),
                  title: const Text('View All Users'),
                  subtitle: const Text('See a list of all registered users.'),
                  onTap: () {
                    // TODO: Navigate to user list screen
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('View Users - Coming Soon!'),
                      ),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.manage_accounts),
                  title: const Text('Manage User Roles'),
                  subtitle: const Text('Assign or change user roles.'),
                  onTap: () {
                    // TODO: Navigate to user role management
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Manage Roles - Coming Soon!'),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Card for Booking Management
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ExpansionTile(
              leading: Icon(Icons.book_online, color: colorScheme.error),
              title: Text(
                'Booking Management',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.error,
                ),
              ),
              children: <Widget>[
                ListTile(
                  leading: const Icon(Icons.view_list),
                  title: const Text('View All Bookings'),
                  subtitle: const Text('Monitor all tour and car bookings.'),
                  onTap: () {
                    // TODO: Navigate to all bookings screen
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('View Bookings - Coming Soon!'),
                      ),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.receipt_long),
                  title: const Text('Manage Payments'),
                  subtitle: const Text('View and manage payment transactions.'),
                  onTap: () {
                    // TODO: Navigate to payment management
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Manage Payments - Coming Soon!'),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Card for System Settings
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ExpansionTile(
              leading: Icon(
                Icons.settings_applications,
                color: Colors.grey[700],
              ),
              title: Text(
                'System Settings',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[700],
                ),
              ),
              children: <Widget>[
                ListTile(
                  leading: const Icon(Icons.analytics_outlined),
                  title: const Text('View Analytics'),
                  subtitle: const Text(
                    'Check application usage and statistics.',
                  ),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Analytics - Coming Soon!')),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.miscellaneous_services_outlined),
                  title: const Text('App Configuration'),
                  subtitle: const Text('Manage general application settings.'),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('App Config - Coming Soon!'),
                      ),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.backup_outlined),
                  title: const Text('Data Management'),
                  subtitle: const Text('Backup and restore application data.'),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Data Management - Coming Soon!'),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
