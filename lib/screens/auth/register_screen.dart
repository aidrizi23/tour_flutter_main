import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../services/auth_service.dart';
import '../../widgets/custom_text_field.dart';
import '../../models/auth_models.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final AuthService _authService = AuthService();

  bool _isLoading = false;
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  String? _errorMessage;
  String? _successMessage;

  late AnimationController _animationController;
  late AnimationController _shakeController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.8),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );

    _shakeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _shakeController, curve: Curves.elasticIn),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _shakeController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) {
      _triggerShakeAnimation();
      return;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      setState(() {
        _errorMessage = 'Passwords do not match';
      });
      _triggerShakeAnimation();
      HapticFeedback.lightImpact();
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _successMessage = null;
    });

    try {
      final registerRequest = RegisterRequest(
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
        confirmPassword: _confirmPasswordController.text,
      );

      final response = await _authService.register(registerRequest);

      if (response != null && response.isSuccess) {
        setState(() {
          _successMessage =
              'Account created! Welcome to TourApp. Redirecting...';
        });

        // Show success message briefly
        await Future.delayed(const Duration(milliseconds: 1500));

        if (mounted) {
          Navigator.of(context).pushReplacementNamed('/');
        }
      }
    } catch (e) {
      setState(() {
        String errorStr = e.toString();
        if (errorStr.contains('Email already exists')) {
          _errorMessage =
              'This email is already registered. Please sign in instead.';
        } else if (errorStr.contains('validation') ||
            errorStr.contains('Password validation failed')) {
          _errorMessage = 'Please check your information and try again.';
        } else if (errorStr.contains('Connection') ||
            errorStr.contains('network')) {
          _errorMessage = 'Network error. Please check your connection.';
        } else if (errorStr.contains('server')) {
          _errorMessage = 'Server error. Please try again later.';
        } else {
          _errorMessage = 'Registration failed. Please try again.';
        }
      });

      _triggerShakeAnimation();
      HapticFeedback.lightImpact();
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _triggerShakeAnimation() {
    _shakeController.forward().then((_) {
      _shakeController.reverse();
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final colorScheme = Theme.of(context).colorScheme;
    final isMobile = screenWidth < 600;

    return Scaffold(
      backgroundColor:
          isMobile ? colorScheme.surface : colorScheme.surfaceContainerLowest,
      body: SafeArea(
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: !isMobile
              ? BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      colorScheme.surface,
                      colorScheme.surfaceContainerLow,
                    ],
                  ),
                )
              : null,
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: screenHeight - MediaQuery.of(context).padding.top,
              ),
              child: Container(
                width: isMobile ? double.infinity : 450,
                margin: isMobile
                    ? EdgeInsets.zero
                    : EdgeInsets.symmetric(
                        horizontal: (screenWidth - 450) / 2,
                        vertical: 20,
                      ),
                decoration: isMobile
                    ? null
                    : BoxDecoration(
                        color: colorScheme.surface,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: colorScheme.shadow.withOpacity(0.1),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: isMobile ? 24 : 32,
                    vertical: isMobile ? 24 : 32,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Logo and Welcome Section
                      FadeTransition(
                        opacity: _fadeAnimation,
                        child: SlideTransition(
                          position: _slideAnimation,
                          child: ScaleTransition(
                            scale: _scaleAnimation,
                            child: Column(
                              children: [
                                Container(
                                  width: 100,
                                  height: 100,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        colorScheme.primary,
                                        colorScheme.primary.withOpacity(0.8),
                                      ],
                                    ),
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: colorScheme.primary.withOpacity(
                                          0.3,
                                        ),
                                        blurRadius: 20,
                                        offset: const Offset(0, 10),
                                      ),
                                    ],
                                  ),
                                  child: Icon(
                                    Icons.person_add_rounded,
                                    size: 50,
                                    color: colorScheme.onPrimary,
                                  ),
                                ),
                                const SizedBox(height: 24),
                                Text(
                                  'Create Account',
                                  style: Theme.of(
                                    context,
                                  ).textTheme.headlineMedium?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: colorScheme.onSurface,
                                      ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Join us to discover amazing tours',
                                  style: Theme.of(
                                    context,
                                  ).textTheme.bodyLarge?.copyWith(
                                        color:
                                            colorScheme.onSurface.withOpacity(
                                          0.7,
                                        ),
                                      ),
                                ),
                                const SizedBox(height: 32),
                              ],
                            ),
                          ),
                        ),
                      ),

                      // Form Section
                      FadeTransition(
                        opacity: _fadeAnimation,
                        child: SlideTransition(
                          position: _slideAnimation,
                          child: AnimatedBuilder(
                            animation: _shakeAnimation,
                            builder: (context, child) {
                              return Transform.translate(
                                offset: Offset(
                                  _shakeAnimation.value *
                                      10 *
                                      (1 - _shakeAnimation.value),
                                  0,
                                ),
                                child: Form(
                                  key: _formKey,
                                  child: Column(
                                    children: [
                                      // Success Message
                                      if (_successMessage != null)
                                        AnimatedContainer(
                                          duration: const Duration(
                                            milliseconds: 300,
                                          ),
                                          width: double.infinity,
                                          padding: const EdgeInsets.all(16),
                                          margin: const EdgeInsets.only(
                                            bottom: 24,
                                          ),
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              colors: [
                                                Colors.green.withOpacity(0.1),
                                                Colors.green.withOpacity(0.05),
                                              ],
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              16,
                                            ),
                                            border: Border.all(
                                              color: Colors.green.withOpacity(
                                                0.2,
                                              ),
                                            ),
                                          ),
                                          child: Row(
                                            children: [
                                              const Icon(
                                                Icons.check_circle_outline,
                                                color: Colors.green,
                                                size: 20,
                                              ),
                                              const SizedBox(width: 12),
                                              Expanded(
                                                child: Text(
                                                  _successMessage!,
                                                  style: TextStyle(
                                                    color:
                                                        Colors.green.shade700,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),

                                      // Error Message
                                      if (_errorMessage != null)
                                        AnimatedContainer(
                                          duration: const Duration(
                                            milliseconds: 300,
                                          ),
                                          width: double.infinity,
                                          padding: const EdgeInsets.all(16),
                                          margin: const EdgeInsets.only(
                                            bottom: 24,
                                          ),
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              colors: [
                                                colorScheme.error.withOpacity(
                                                  0.1,
                                                ),
                                                colorScheme.error.withOpacity(
                                                  0.05,
                                                ),
                                              ],
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              16,
                                            ),
                                            border: Border.all(
                                              color: colorScheme.error
                                                  .withOpacity(0.2),
                                            ),
                                          ),
                                          child: Row(
                                            children: [
                                              Icon(
                                                Icons.warning_rounded,
                                                color: colorScheme.error,
                                                size: 20,
                                              ),
                                              const SizedBox(width: 12),
                                              Expanded(
                                                child: Text(
                                                  _errorMessage!,
                                                  style: TextStyle(
                                                    color: colorScheme.error,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),

                                      // Name Fields Row
                                      Row(
                                        children: [
                                          Expanded(
                                            child: CustomTextField(
                                              controller: _firstNameController,
                                              label: 'First Name',
                                              hint: 'Your first name',
                                              prefixIcon: Icons.person_outline,
                                              textInputAction:
                                                  TextInputAction.next,
                                              validator: (value) {
                                                if (value == null ||
                                                    value.isEmpty) {
                                                  return 'Required';
                                                }
                                                if (value.length < 2) {
                                                  return 'Too short';
                                                }
                                                if (!RegExp(
                                                  r'^[a-zA-Z\s]+$',
                                                ).hasMatch(value)) {
                                                  return 'Letters only';
                                                }
                                                return null;
                                              },
                                            ),
                                          ),
                                          const SizedBox(width: 16),
                                          Expanded(
                                            child: CustomTextField(
                                              controller: _lastNameController,
                                              label: 'Last Name',
                                              hint: 'Your last name',
                                              prefixIcon: Icons.person_outline,
                                              textInputAction:
                                                  TextInputAction.next,
                                              validator: (value) {
                                                if (value == null ||
                                                    value.isEmpty) {
                                                  return 'Required';
                                                }
                                                if (value.length < 2) {
                                                  return 'Too short';
                                                }
                                                if (!RegExp(
                                                  r'^[a-zA-Z\s]+$',
                                                ).hasMatch(value)) {
                                                  return 'Letters only';
                                                }
                                                return null;
                                              },
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 24),

                                      // Email Field
                                      CustomTextField(
                                        controller: _emailController,
                                        label: 'Email',
                                        hint: 'Enter your email',
                                        prefixIcon: Icons.email_outlined,
                                        keyboardType:
                                            TextInputType.emailAddress,
                                        textInputAction: TextInputAction.next,
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return 'Please enter your email';
                                          }
                                          if (!RegExp(
                                            r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                                          ).hasMatch(value)) {
                                            return 'Please enter a valid email';
                                          }
                                          return null;
                                        },
                                      ),
                                      const SizedBox(height: 24),

                                      // Password Field
                                      CustomTextField(
                                        controller: _passwordController,
                                        label: 'Password',
                                        hint: 'Enter your password',
                                        prefixIcon: Icons.lock_outline,
                                        isPassword: !_isPasswordVisible,
                                        textInputAction: TextInputAction.next,
                                        suffixIcon: IconButton(
                                          onPressed: () {
                                            setState(() {
                                              _isPasswordVisible =
                                                  !_isPasswordVisible;
                                            });
                                          },
                                          icon: Icon(
                                            _isPasswordVisible
                                                ? Icons.visibility_off_rounded
                                                : Icons.visibility_rounded,
                                          ),
                                        ),
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return 'Please enter a password';
                                          }
                                          if (value.length < 6) {
                                            return 'Password must be at least 6 characters';
                                          }
                                          /*if (!RegExp(
                                            r'(?=.*[a-z])(?=.*[A-Z])(?=.*\d)',
                                          ).hasMatch(value)) {
                                            return 'Include uppercase, lowercase, and number';
                                          }*/
                                          return null;
                                        },
                                      ),
                                      const SizedBox(height: 24),

                                      // Confirm Password Field
                                      CustomTextField(
                                        controller: _confirmPasswordController,
                                        label: 'Confirm Password',
                                        hint: 'Re-enter your password',
                                        prefixIcon: Icons.lock_outline,
                                        isPassword: !_isConfirmPasswordVisible,
                                        textInputAction: TextInputAction.done,
                                        suffixIcon: IconButton(
                                          onPressed: () {
                                            setState(() {
                                              _isConfirmPasswordVisible =
                                                  !_isConfirmPasswordVisible;
                                            });
                                          },
                                          icon: Icon(
                                            _isConfirmPasswordVisible
                                                ? Icons.visibility_off_rounded
                                                : Icons.visibility_rounded,
                                          ),
                                        ),
                                        onFieldSubmitted: (_) => _register(),
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return 'Please confirm your password';
                                          }
                                          if (value !=
                                              _passwordController.text) {
                                            return 'Passwords do not match';
                                          }
                                          return null;
                                        },
                                      ),
                                      const SizedBox(height: 32),

                                      // Register Button
                                      SizedBox(
                                        width: double.infinity,
                                        height: 56,
                                        child: _isLoading
                                            ? Container(
                                                decoration: BoxDecoration(
                                                  gradient: LinearGradient(
                                                    colors: [
                                                      colorScheme.primary
                                                          .withOpacity(0.7),
                                                      colorScheme.primary
                                                          .withOpacity(0.5),
                                                    ],
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                    16,
                                                  ),
                                                ),
                                                child: Center(
                                                  child: SizedBox(
                                                    width: 24,
                                                    height: 24,
                                                    child:
                                                        CircularProgressIndicator(
                                                      color:
                                                          colorScheme.onPrimary,
                                                      strokeWidth: 2,
                                                    ),
                                                  ),
                                                ),
                                              )
                                            : ElevatedButton(
                                                onPressed: _register,
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor:
                                                      colorScheme.primary,
                                                  foregroundColor:
                                                      colorScheme.onPrimary,
                                                  elevation: 0,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                      16,
                                                    ),
                                                  ),
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                    vertical: 16,
                                                  ),
                                                ),
                                                child: const Text(
                                                  'Create Account',
                                                  style: TextStyle(
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ),
                                      ),
                                      const SizedBox(height: 24),

                                      // Terms and Conditions
                                      Container(
                                        padding: const EdgeInsets.all(16),
                                        decoration: BoxDecoration(
                                          color: colorScheme.surfaceContainerLow
                                              .withOpacity(0.5),
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        child: Text(
                                          'By creating an account, you agree to our Terms of Service and Privacy Policy',
                                          textAlign: TextAlign.center,
                                          style: Theme.of(
                                            context,
                                          ).textTheme.bodySmall?.copyWith(
                                                color: colorScheme.onSurface
                                                    .withOpacity(0.6),
                                              ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),

                      // Sign In Link
                      const SizedBox(height: 32),
                      FadeTransition(
                        opacity: _fadeAnimation,
                        child: Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: colorScheme.surfaceContainerLow,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "Already have an account? ",
                                style: Theme.of(
                                  context,
                                ).textTheme.bodyMedium?.copyWith(
                                      color: colorScheme.onSurface
                                          .withOpacity(0.7),
                                    ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  Navigator.of(
                                    context,
                                  ).pushReplacementNamed('/login');
                                },
                                child: Text(
                                  'Sign In',
                                  style: TextStyle(
                                    color: colorScheme.primary,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
