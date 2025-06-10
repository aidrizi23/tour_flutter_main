# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands

### Development Commands
- `flutter run` - Run the application in debug mode
- `flutter build` - Build the application for production
- `flutter test` - Run the test suite
- `flutter pub get` - Install dependencies
- `flutter clean` - Clean build artifacts

### Platform-specific commands
- `flutter run -d chrome` - Run on web
- `flutter run -d linux` - Run on Linux desktop
- `flutter run -d android` - Run on Android (if connected)

## Architecture

This is a Flutter tourism application with a multi-platform responsive design supporting tours, car rentals, and house accommodations.

### Key Architecture Patterns
- **Service Layer**: All API calls are handled through service classes in `lib/services/`
- **Model Layer**: Data models are defined in `lib/models/` with proper JSON serialization
- **Screen-based UI**: Each major feature has its own screen in `lib/screens/`
- **Responsive Design**: Uses `ResponsiveLayout` widget and layout utilities for desktop/tablet/mobile
- **Provider Pattern**: Uses Provider for state management (theme, auth state)

### Core Services
- `TourService`: Handles all tour-related API operations
- `AuthService`: Authentication and user management
- `BookingService`: Booking flow and payment processing
- `StripeService`: Payment integration with Stripe
- `CarService`, `HouseService`: Similar patterns for other accommodation types

### Navigation Structure
- Main layout uses `ResponsiveLayout` with sidebar navigation for desktop/tablet
- Bottom navigation for mobile
- Hero transitions for tour cards to details screens
- Uses `LayoutUtils.createLayoutRoute()` for consistent responsive navigation
- Main screens (Tours, Cars, Houses, Bookings, Profile, Settings, Admin) are managed via `IndexedStack`
- Detail screens and payment flows use independent `Scaffold` for focused workflows

### UI Components
- **Modern Design**: Material 3 design system with custom theming
- **Responsive Grids**: Adaptive layouts that change based on screen size
- **Hero Animations**: Smooth transitions between list and detail views
- **Image Galleries**: Full-screen image viewing with pagination
- **Search & Filters**: Advanced filtering system for tours

### Payment Flow
The booking system integrates with Stripe:
1. User selects tour and date
2. Creates `PaymentInfo` object
3. Navigates to `PaymentScreen`
4. Processes payment via `StripeService`
5. Returns booking confirmation

### Known Issues & Solutions
- **Hero Tag Conflicts**: Tour cards use `tour_card_${id}` tags, image galleries use `tour_image_${id}_${index}`
- **setState() after dispose()**: Always wrap setState calls in `if (mounted)` checks for async operations
- **Network Errors**: API calls have proper error handling with user-friendly messages
- **Image Loading**: Graceful fallbacks for failed image loads, validate URLs before displaying (check for "string" literals)
- **Navigation Consistency**: All main screens use `ResponsiveLayout` wrapper for consistent sidebar/navigation

### File Organization
- `lib/screens/tours/` - Tour listing and detail screens
- `lib/screens/tours/widgets/` - Reusable tour-specific widgets
- `lib/widgets/` - Global reusable widgets
- `lib/utils/` - Utility functions and helpers
- `lib/theme/` - App theming and styling

### Development Notes
- Always use proper responsive breakpoints (mobile: <768px, tablet: 768-1200px, desktop: >1200px)
- Hero widgets must have unique tags to avoid conflicts
- API error handling should provide user-friendly messages
- Image URLs should be validated before displaying (check for null, empty, or "string" values)
- Use `if (mounted)` checks before setState() calls in async functions to prevent memory leaks
- Prefer `.withValues(alpha: value)` over deprecated `.withOpacity()` method
- Settings screen is integrated into main navigation (not a separate route)