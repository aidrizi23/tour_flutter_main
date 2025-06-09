import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../providers/theme_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  void _onThemeChanged(ThemeMode? themeMode) {
    if (themeMode != null) {
      final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
      if (themeMode != themeProvider.themeMode) {
        themeProvider.setThemeMode(themeMode);
        HapticFeedback.lightImpact();

        // Show feedback
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.palette_rounded, color: Colors.white, size: 20),
                const SizedBox(width: 12),
                Text('Theme changed to ${_getThemeDisplayName(themeMode)}'),
              ],
            ),
            backgroundColor: Theme.of(context).colorScheme.primary,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  String _getThemeDisplayName(ThemeMode themeMode) {
    switch (themeMode) {
      case ThemeMode.light:
        return 'Light';
      case ThemeMode.dark:
        return 'Dark';
      case ThemeMode.system:
        return 'System';
    }
  }

  IconData _getThemeIcon(ThemeMode themeMode) {
    switch (themeMode) {
      case ThemeMode.light:
        return Icons.light_mode_rounded;
      case ThemeMode.dark:
        return Icons.dark_mode_rounded;
      case ThemeMode.system:
        return Icons.auto_mode_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;

    return Container(
      color: colorScheme.surfaceContainerLowest,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: CustomScrollView(
          slivers: [
            // Header
            SliverToBoxAdapter(
              child: Container(
                color: colorScheme.surface,
                child: SafeArea(
                  child: Padding(
                    padding: EdgeInsets.all(isMobile ? 20 : 32),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                colorScheme.primary,
                                colorScheme.secondary,
                              ],
                            ),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Icon(
                            Icons.settings_rounded,
                            color: Colors.white,
                            size: 32,
                          ),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Settings',
                                style: Theme.of(
                                  context,
                                ).textTheme.headlineLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: colorScheme.onSurface,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Customize your AlbTour experience',
                                style: Theme.of(
                                  context,
                                ).textTheme.bodyLarge?.copyWith(
                                  color: colorScheme.onSurface.withValues(
                                    alpha: 0.7,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Content
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(isMobile ? 20 : 32),
                child: Column(
                  children: [
                    // Theme Settings Section
                    _buildSettingsSection(
                      title: 'Appearance',
                      icon: Icons.palette_rounded,
                      description: 'Customize the look and feel of the app',
                      children: [_buildThemeSelector()],
                    ),

                    const SizedBox(height: 32),

                    // Coming Soon Section
                    _buildSettingsSection(
                      title: 'More Settings',
                      icon: Icons.more_horiz_rounded,
                      description: 'Additional settings will be available soon',
                      children: [
                        _buildComingSoonCard('Account Settings'),
                        const SizedBox(height: 12),
                        _buildComingSoonCard('Notification Preferences'),
                        const SizedBox(height: 12),
                        _buildComingSoonCard('Privacy & Security'),
                        const SizedBox(height: 12),
                        _buildComingSoonCard('Language & Region'),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsSection({
    required String title,
    required IconData icon,
    required String description,
    required List<Widget> children,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(maxWidth: 800),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    icon,
                    color: colorScheme.onPrimaryContainer,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        description,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurface.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildThemeSelector() {
    final colorScheme = Theme.of(context).colorScheme;
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Theme Mode',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 16),
        if (isMobile)
          Column(
            children:
                ThemeMode.values.map((themeMode) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _buildThemeOption(themeMode),
                  );
                }).toList(),
          )
        else
          Row(
            children:
                ThemeMode.values.map((themeMode) {
                  return Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(
                        right: themeMode != ThemeMode.values.last ? 16 : 0,
                      ),
                      child: _buildThemeOption(themeMode),
                    ),
                  );
                }).toList(),
          ),
      ],
    );
  }

  Widget _buildThemeOption(ThemeMode themeMode) {
    final colorScheme = Theme.of(context).colorScheme;
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isSelected = themeProvider.themeMode == themeMode;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _onThemeChanged(themeMode),
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color:
                isSelected
                    ? colorScheme.primary.withValues(alpha: 0.1)
                    : colorScheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color:
                  isSelected
                      ? colorScheme.primary
                      : colorScheme.outline.withValues(alpha: 0.2),
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color:
                      isSelected
                          ? colorScheme.primary
                          : colorScheme.surfaceContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _getThemeIcon(themeMode),
                  color:
                      isSelected
                          ? Colors.white
                          : colorScheme.onSurface.withValues(alpha: 0.7),
                  size: 32,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                _getThemeDisplayName(themeMode),
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color:
                      isSelected ? colorScheme.primary : colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _getThemeDescription(themeMode),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurface.withValues(alpha: 0.6),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getThemeDescription(ThemeMode themeMode) {
    switch (themeMode) {
      case ThemeMode.light:
        return 'Always use light theme';
      case ThemeMode.dark:
        return 'Always use dark theme';
      case ThemeMode.system:
        return 'Follow system setting';
    }
  }

  Widget _buildComingSoonCard(String title) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outline.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainer,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.hourglass_empty_rounded,
              color: colorScheme.onSurface.withValues(alpha: 0.5),
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: colorScheme.onSurface.withValues(alpha: 0.7),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'Coming Soon',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
