import 'dart:convert';
import 'dart:developer';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/auth_models.dart';
import '../utils/api_client.dart';

class AuthService {
  static const String _tokenKey = 'auth_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _userKey = 'user_data';
  static const String _expirationKey = 'token_expiration';

  final ApiClient _apiClient = ApiClient();

  // Login method
  Future<LoginResponse?> login(LoginRequest request) async {
    try {
      log('Attempting login for email: ${request.email}');

      final response = await _apiClient.post(
        '/auth/login',
        data: request.toJson(),
      );

      log('Login response status: ${response.statusCode}');
      log('Login response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // Parse the response according to the API documentation format
        final loginResponse = LoginResponse.fromJson(data);

        if (!loginResponse.isSuccess) {
          throw Exception(loginResponse.message);
        }

        // Store authentication data
        await _storeAuthData(loginResponse);

        log('Login successful for user: ${loginResponse.email}');
        return loginResponse;
      } else {
        // Handle specific error cases
        if (response.statusCode == 401) {
          throw Exception('Invalid email or password');
        } else if (response.statusCode == 400) {
          try {
            final error = json.decode(response.body);
            throw Exception(error['message'] ?? 'Invalid login credentials');
          } catch (e) {
            throw Exception('Invalid login credentials');
          }
        } else {
          throw Exception('Login failed. Please try again.');
        }
      }
    } catch (e) {
      log('Login error: $e');
      if (e.toString().contains('Connection') ||
          e.toString().contains('network') ||
          e.toString().contains('SocketException')) {
        throw Exception(
          'Connection error. Please check your internet connection.',
        );
      }
      rethrow;
    }
  }

  // Register method
  Future<LoginResponse?> register(RegisterRequest request) async {
    try {
      log('Attempting registration for email: ${request.email}');

      final response = await _apiClient.post(
        '/auth/register',
        data: request.toJson(),
      );

      log('Register response status: ${response.statusCode}');
      log('Register response body: ${response.body}');

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = json.decode(response.body);

        // Parse the response according to the API documentation format
        final loginResponse = LoginResponse.fromJson(data);

        if (!loginResponse.isSuccess) {
          throw Exception(loginResponse.message);
        }

        // Store authentication data
        await _storeAuthData(loginResponse);

        log('Registration successful for user: ${loginResponse.email}');
        return loginResponse;
      } else {
        // Handle specific error cases
        if (response.statusCode == 400) {
          try {
            final error = json.decode(response.body);
            String message = error['message'] ?? 'Registration failed';

            // Check for specific validation errors
            if (error['errors'] != null) {
              final errors = error['errors'] as Map<String, dynamic>;
              if (errors['Email'] != null) {
                throw Exception('Email already exists');
              } else if (errors['Password'] != null) {
                throw Exception('Password validation failed');
              }
            }

            throw Exception(message);
          } catch (e) {
            if (e.toString().contains('Email already exists') ||
                e.toString().contains('Password validation failed')) {
              rethrow;
            }
            throw Exception('Registration failed. Please try again.');
          }
        } else if (response.statusCode == 409) {
          throw Exception('Email already exists');
        } else {
          throw Exception('Registration failed. Please try again.');
        }
      }
    } catch (e) {
      log('Registration error: $e');
      if (e.toString().contains('Connection') ||
          e.toString().contains('network') ||
          e.toString().contains('SocketException')) {
        throw Exception(
          'Connection error. Please check your internet connection.',
        );
      }
      rethrow;
    }
  }

  // Store authentication data
  Future<void> _storeAuthData(LoginResponse loginResponse) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      await prefs.setString(_tokenKey, loginResponse.token);
      await prefs.setString(_refreshTokenKey, loginResponse.refreshToken);
      await prefs.setString(
        _userKey,
        json.encode(loginResponse.toUser().toJson()),
      );
      await prefs.setString(
        _expirationKey,
        loginResponse.expiration.toUtc().toIso8601String(),
      );

      log('Auth data stored successfully');
    } catch (e) {
      log('Error storing auth data: $e');
      throw Exception('Failed to store authentication data');
    }
  }

  // Get stored token
  Future<String?> getToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_tokenKey);
    } catch (e) {
      log('Error getting token: $e');
      return null;
    }
  }

  // Get stored refresh token
  Future<String?> getRefreshToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_refreshTokenKey);
    } catch (e) {
      log('Error getting refresh token: $e');
      return null;
    }
  }

  // Get stored user data
  Future<User?> getCurrentUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString(_userKey);

      if (userJson != null) {
        final userData = json.decode(userJson);
        return User.fromJson(userData);
      }

      return null;
    } catch (e) {
      log('Error getting current user: $e');
      return null;
    }
  }

  // Check if user is admin
  Future<bool> isAdmin() async {
    try {
      final user = await getCurrentUser();
      if (user == null) return false;

      log('User roles: ${user.roles}');
      return user.roles.contains('Admin');
    } catch (e) {
      log('Error checking admin status: $e');
      return false;
    }
  }

  // Check if token is expired
  Future<bool> isTokenExpired() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final expirationString = prefs.getString(_expirationKey);

      if (expirationString == null) return true;

      final expiration = DateTime.parse(expirationString).toUtc();
      final now = DateTime.now().toUtc();

      // Check if token expires within the next 5 minutes
      return now.add(const Duration(minutes: 5)).isAfter(expiration);
    } catch (e) {
      log('Error checking token expiration: $e');
      return true;
    }
  }

  // Refresh token
  Future<bool> refreshToken() async {
    try {
      final token = await getToken();
      final refreshToken = await getRefreshToken();

      if (token == null || refreshToken == null) {
        log('No tokens available for refresh');
        return false;
      }

      log('Attempting token refresh');

      final response = await _apiClient.post(
        '/auth/refresh-token',
        data: {'token': token, 'refreshToken': refreshToken},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final refreshResponse = LoginResponse.fromJson(data);

        if (!refreshResponse.isSuccess) {
          log('Token refresh failed: ${refreshResponse.message}');
          return false;
        }

        // Store new tokens
        await _storeAuthData(refreshResponse);

        log('Token refresh successful');
        return true;
      }

      log('Token refresh failed with status: ${response.statusCode}');
      return false;
    } catch (e) {
      log('Token refresh error: $e');
      return false;
    }
  }

  // Logout
  Future<void> logout() async {
    try {
      final token = await getToken();
      if (token != null) {
        log('Attempting server logout');
        // Call logout endpoint to invalidate token on server
        try {
          await _apiClient.post('/auth/logout', requiresAuth: true);
        } catch (e) {
          log('Server logout failed, continuing with local logout: $e');
          // Continue with local logout even if server logout fails
        }
      }
    } catch (e) {
      log('Logout error: $e');
      // Continue with local logout even if server logout fails
    } finally {
      // Clear local storage
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove(_tokenKey);
        await prefs.remove(_refreshTokenKey);
        await prefs.remove(_userKey);
        await prefs.remove(_expirationKey);
        log('Local storage cleared');
      } catch (e) {
        log('Error clearing local storage: $e');
      }
    }
  }

  // Check if user is logged in
  Future<bool> isLoggedIn() async {
    try {
      final token = await getToken();
      if (token == null) return false;

      // Check if token is expired
      if (await isTokenExpired()) {
        // Try to refresh the token
        final refreshed = await refreshToken();
        if (!refreshed) {
          // If refresh fails, user is not logged in
          await logout();
          return false;
        }
      }

      return true;
    } catch (e) {
      log('Error checking login status: $e');
      return false;
    }
  }

  // Update user profile
  Future<User?> updateProfile(UpdateProfileRequest request) async {
    try {
      log('Updating user profile');

      final response = await _apiClient.put(
        '/users/profile',
        data: request.toJson(),
        requiresAuth: true,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final updatedUser = User.fromJson(data);

        // Update stored user data
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_userKey, json.encode(updatedUser.toJson()));

        log('Profile update successful');
        return updatedUser;
      } else {
        try {
          final error = json.decode(response.body);
          throw Exception(error['message'] ?? 'Profile update failed');
        } catch (e) {
          throw Exception('Profile update failed');
        }
      }
    } catch (e) {
      log('Profile update error: $e');
      rethrow;
    }
  }

  // Change password
  Future<bool> changePassword(ChangePasswordRequest request) async {
    try {
      log('Changing password');

      final response = await _apiClient.post(
        '/auth/change-password',
        data: request.toJson(),
        requiresAuth: true,
      );

      if (response.statusCode == 200) {
        log('Password change successful');
        return true;
      } else {
        try {
          final error = json.decode(response.body);
          throw Exception(error['message'] ?? 'Password change failed');
        } catch (e) {
          throw Exception('Password change failed');
        }
      }
    } catch (e) {
      log('Password change error: $e');
      rethrow;
    }
  }

  // Forgot password
  Future<bool> forgotPassword(String email) async {
    try {
      log('Sending forgot password request for: $email');

      final response = await _apiClient.post(
        '/auth/forgot-password',
        data: {'email': email},
      );

      if (response.statusCode == 200) {
        log('Forgot password request successful');
        return true;
      }

      return false;
    } catch (e) {
      log('Forgot password error: $e');
      rethrow;
    }
  }

  // Reset password
  Future<bool> resetPassword(ResetPasswordRequest request) async {
    try {
      log('Resetting password');

      final response = await _apiClient.post(
        '/auth/reset-password',
        data: request.toJson(),
      );

      if (response.statusCode == 200) {
        log('Password reset successful');
        return true;
      }

      return false;
    } catch (e) {
      log('Password reset error: $e');
      rethrow;
    }
  }
}
