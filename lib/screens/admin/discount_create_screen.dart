import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../../models/discount_models.dart';
import '../../services/discount_service.dart';
import '../../widgets/modern_widgets.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/custom_button.dart';

class DiscountCreateScreen extends StatefulWidget {
  final Discount? discount;

  const DiscountCreateScreen({super.key, this.discount});

  @override
  State<DiscountCreateScreen> createState() => _DiscountCreateScreenState();
}

class _DiscountCreateScreenState extends State<DiscountCreateScreen>
    with TickerProviderStateMixin {
  final DiscountService _discountService = DiscountService();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final ScrollController _scrollController = ScrollController();

  // Controllers
  final TextEditingController _codeController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _valueController = TextEditingController();
  final TextEditingController _minimumAmountController =
      TextEditingController();
  final TextEditingController _usageLimitController = TextEditingController();

  // State variables
  DiscountType _selectedType = DiscountType.percentage;
  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now().add(const Duration(days: 30));
  bool _isActive = true;
  List<String> _selectedCategories = [];
  List<String> _availableCategories = [];
  bool _isLoading = false;
  bool _isEditMode = false;
  String? _errorMessage;
  String? _successMessage;

  // Animation controllers
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _isEditMode = widget.discount != null;
    _setupAnimations();
    _loadCategories();
    _initializeData();
  }

  void _setupAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeOut));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.05),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
    );

    _fadeController.forward();
    _slideController.forward();
  }

  void _initializeData() {
    if (widget.discount != null) {
      final discount = widget.discount!;
      _codeController.text = discount.code;
      _nameController.text = discount.name;
      _descriptionController.text = discount.description ?? '';
      _valueController.text = discount.value.toString();
      _minimumAmountController.text = discount.minimumAmount?.toString() ?? '';
      _usageLimitController.text = discount.usageLimit?.toString() ?? '';
      _selectedType = discount.type;
      _startDate = discount.startDate;
      _endDate = discount.endDate;
      _isActive = discount.isActive;
      _selectedCategories = discount.applicableCategories ?? [];
    }
  }

  Future<void> _loadCategories() async {
    try {
      final categories = await _discountService.getDiscountCategories();
      if (mounted) {
        setState(() {
          _availableCategories = categories;
          // If we're in edit mode and have categories that don't exist in available categories, add them
          if (_isEditMode && _selectedCategories.isNotEmpty) {
            for (final category in _selectedCategories) {
              if (!_availableCategories.contains(category)) {
                _availableCategories.add(category);
              }
            }
          }
        });
      }
    } catch (e) {
      // Handle error silently or show in a non-intrusive way
      debugPrint('Error loading categories: $e');
    }
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final initialDate = isStartDate ? _startDate : _endDate;
    final firstDate = isStartDate ? DateTime.now() : _startDate;
    final lastDate = DateTime.now().add(const Duration(days: 365 * 2));

    final ThemeData theme = Theme.of(context);
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: theme.colorScheme,
            dialogBackgroundColor: theme.colorScheme.surface,
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null) {
      setState(() {
        if (isStartDate) {
          _startDate = pickedDate;
          // Ensure end date is after start date
          if (_endDate.isBefore(_startDate)) {
            _endDate = _startDate.add(const Duration(days: 1));
          }
        } else {
          _endDate = pickedDate;
        }
      });
    }
  }

  Future<void> _saveDiscount() async {
    if (!_formKey.currentState!.validate()) {
      // Scroll to the first error
      _scrollToFirstError();
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _successMessage = null;
    });

    try {
      if (_isEditMode) {
        // Update existing discount
        final request = UpdateDiscountRequest(
          name: _nameController.text.trim(),
          description:
              _descriptionController.text.trim().isEmpty
                  ? null
                  : _descriptionController.text.trim(),
          value: double.parse(_valueController.text),
          minimumAmount:
              _minimumAmountController.text.isEmpty
                  ? null
                  : double.parse(_minimumAmountController.text),
          usageLimit:
              _usageLimitController.text.isEmpty
                  ? null
                  : int.parse(_usageLimitController.text),
          startDate: _startDate,
          endDate: _endDate,
          isActive: _isActive,
          applicableCategories:
              _selectedCategories.isEmpty ? null : _selectedCategories,
        );

        await _discountService.updateDiscount(widget.discount!.id, request);
        setState(() {
          _successMessage = 'Discount updated successfully!';
        });
      } else {
        // Create new discount
        final request = CreateDiscountRequest(
          code: _codeController.text.trim().toUpperCase(),
          name: _nameController.text.trim(),
          description:
              _descriptionController.text.trim().isEmpty
                  ? null
                  : _descriptionController.text.trim(),
          type: _selectedType,
          value: double.parse(_valueController.text),
          minimumAmount:
              _minimumAmountController.text.isEmpty
                  ? null
                  : double.parse(_minimumAmountController.text),
          usageLimit:
              _usageLimitController.text.isEmpty
                  ? null
                  : int.parse(_usageLimitController.text),
          startDate: _startDate,
          endDate: _endDate,
          isActive: _isActive,
          applicableCategories:
              _selectedCategories.isEmpty ? null : _selectedCategories,
        );

        await _discountService.createDiscount(request);
        setState(() {
          _successMessage = 'Discount created successfully!';
        });
      }

      // Scroll to top to show success message
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );

      // Provide haptic feedback for success
      HapticFeedback.lightImpact();

      if (mounted) {
        ModernSnackBar.show(
          context,
          message:
              _isEditMode
                  ? 'Discount updated successfully'
                  : 'Discount created successfully',
          type: SnackBarType.success,
        );

        // Wait a bit before closing the screen to let the user see the success message
        Future.delayed(const Duration(milliseconds: 1200), () {
          if (mounted) Navigator.of(context).pop(true);
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });

      // Scroll to top to show error message
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );

      // Provide haptic feedback for error
      HapticFeedback.mediumImpact();

      if (mounted) {
        ModernSnackBar.show(
          context,
          message: 'Error: ${e.toString()}',
          type: SnackBarType.error,
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _scrollToFirstError() {
    // This helps scroll to the first validation error
    final FormState form = _formKey.currentState!;
    form.save();

    // Scroll to the top to show validation errors
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  String? _validateCode(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Discount code is required';
    }
    if (value.trim().length < 3) {
      return 'Code must be at least 3 characters';
    }
    if (value.trim().length > 20) {
      return 'Code must be less than 20 characters';
    }
    // Check for invalid characters
    if (!RegExp(r'^[A-Z0-9_-]+$').hasMatch(value.trim().toUpperCase())) {
      return 'Code can only contain letters, numbers, hyphens, and underscores';
    }
    return null;
  }

  String? _validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Discount name is required';
    }
    if (value.trim().length > 100) {
      return 'Name must be less than 100 characters';
    }
    return null;
  }

  String? _validateValue(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Discount value is required';
    }
    final val = double.tryParse(value);
    if (val == null || val <= 0) {
      return 'Value must be greater than 0';
    }
    if (_selectedType == DiscountType.percentage && val > 100) {
      return 'Percentage cannot be more than 100%';
    }
    if (_selectedType == DiscountType.fixedAmount && val > 10000) {
      return 'Fixed amount cannot exceed \$10,000';
    }
    return null;
  }

  String? _validateMinimumAmount(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    final val = double.tryParse(value);
    if (val == null || val < 0) {
      return 'Minimum amount must be 0 or greater';
    }
    return null;
  }

  String? _validateUsageLimit(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    final val = int.tryParse(value);
    if (val == null || val <= 0) {
      return 'Usage limit must be greater than 0';
    }
    return null;
  }

  @override
  void dispose() {
    _codeController.dispose();
    _nameController.dispose();
    _descriptionController.dispose();
    _valueController.dispose();
    _minimumAmountController.dispose();
    _usageLimitController.dispose();
    _fadeController.dispose();
    _slideController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isSmallScreen = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditMode ? 'Edit Discount' : 'Create Discount'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Reset Form',
            onPressed: () {
              showDialog(
                context: context,
                builder:
                    (context) => AlertDialog(
                      title: const Text('Reset Form?'),
                      content: const Text(
                        'This will clear all entered data. Are you sure?',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Cancel'),
                        ),
                        FilledButton(
                          onPressed: () {
                            Navigator.pop(context);
                            _initializeData();
                          },
                          child: const Text('Reset'),
                        ),
                      ],
                    ),
              );
            },
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              colorScheme.background,
              colorScheme.surfaceContainerLowest.withOpacity(0.9),
            ],
            stops: const [0, 0.95],
          ),
        ),
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: Form(
              key: _formKey,
              child: ListView(
                controller: _scrollController,
                padding: const EdgeInsets.all(16),
                children: [
                  // Success/Error messages
                  if (_successMessage != null || _errorMessage != null)
                    _buildStatusMessage(),

                  // Main content
                  isSmallScreen ? _buildMobileLayout() : _buildDesktopLayout(),
                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomBar(isSmallScreen),
    );
  }

  Widget _buildStatusMessage() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child:
          _successMessage != null
              ? _buildSuccessMessage()
              : _buildErrorMessage(),
    );
  }

  Widget _buildSuccessMessage() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: Colors.green),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _successMessage!,
              style: const TextStyle(
                color: Colors.green,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorMessage() {
    if (_errorMessage == null) return const SizedBox.shrink();

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: Colors.red),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _errorMessage!,
              style: const TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileLayout() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildBasicInfoSection(),
        const SizedBox(height: 16),
        _buildDiscountDetailsSection(),
        const SizedBox(height: 16),
        _buildValiditySection(),
        const SizedBox(height: 16),
        _buildCategoriesSection(),
        const SizedBox(height: 16),
        _buildPreviewSection(),
        const SizedBox(
          height: 60,
        ), // Extra space at bottom for floating buttons
      ],
    );
  }

  Widget _buildDesktopLayout() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left column (2/3 width)
        Expanded(
          flex: 2,
          child: Column(
            children: [
              _buildBasicInfoSection(),
              const SizedBox(height: 16),
              _buildDiscountDetailsSection(),
              const SizedBox(height: 16),
              _buildValiditySection(),
              const SizedBox(height: 16),
              _buildCategoriesSection(),
            ],
          ),
        ),
        const SizedBox(width: 16),
        // Right column (1/3 width)
        Expanded(flex: 1, child: Column(children: [_buildPreviewSection()])),
      ],
    );
  }

  Widget _buildBottomBar(bool isSmallScreen) {
    return Container(
      padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.close),
              label: const Text('Cancel'),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: CustomButton(
              onPressed: _isLoading ? null : _saveDiscount,
              text: _isEditMode ? 'Update Discount' : 'Create Discount',
              icon: _isEditMode ? Icons.update : Icons.check,
              isLoading: _isLoading,
              showLoadingText: true,
              loadingText: _isEditMode ? 'Updating...' : 'Creating...',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBasicInfoSection() {
    return ModernCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.info_outline,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(width: 16),
              Text(
                'Basic Information',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Discount Code
          CustomTextField(
            controller: _codeController,
            label: 'Discount Code',
            hint: 'e.g., SAVE20, SUMMER2024',
            prefixIcon: Icons.confirmation_number,
            enabled: !_isEditMode, // Code cannot be changed in edit mode
            validator: _validateCode,
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9_-]')),
              TextInputFormatter.withFunction((oldValue, newValue) {
                return newValue.copyWith(text: newValue.text.toUpperCase());
              }),
            ],
          ),
          const SizedBox(height: 16),

          // Discount Name
          CustomTextField(
            controller: _nameController,
            label: 'Discount Name',
            hint: 'e.g., Summer Sale, Early Bird Discount',
            prefixIcon: Icons.label_outline,
            validator: _validateName,
          ),
          const SizedBox(height: 16),

          // Description
          CustomTextField(
            controller: _descriptionController,
            label: 'Description (Optional)',
            hint: 'Brief description of the discount',
            prefixIcon: Icons.description_outlined,
            maxLines: 3,
            maxLength: 200,
          ),
        ],
      ),
    );
  }

  Widget _buildDiscountDetailsSection() {
    return ModernCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.discount, color: Colors.green),
              ),
              const SizedBox(width: 16),
              Text(
                'Discount Details',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Discount Type
          Text(
            'Discount Type',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildTypeOption(
                  title: 'Percentage',
                  description: 'Discount as % off',
                  icon: Icons.percent,
                  value: DiscountType.percentage,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildTypeOption(
                  title: 'Fixed Amount',
                  description: 'Discount as \$ off',
                  icon: Icons.attach_money,
                  value: DiscountType.fixedAmount,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Discount Value
          CustomTextField(
            controller: _valueController,
            label:
                _selectedType == DiscountType.percentage
                    ? 'Percentage (%)'
                    : 'Fixed Amount (\$)',
            hint: _selectedType == DiscountType.percentage ? '20' : '50.00',
            prefixIcon: _selectedType.icon,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            validator: _validateValue,
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
            ],
          ),
          const SizedBox(height: 16),

          // Minimum Amount
          CustomTextField(
            controller: _minimumAmountController,
            label: 'Minimum Order Amount (Optional)',
            hint: '0.00',
            prefixIcon: Icons.shopping_cart_outlined,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            validator: _validateMinimumAmount,
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
            ],
          ),
          const SizedBox(height: 16),

          // Usage Limit
          CustomTextField(
            controller: _usageLimitController,
            label: 'Usage Limit (Optional)',
            hint: 'Unlimited',
            prefixIcon: Icons.people_outline,
            keyboardType: TextInputType.number,
            validator: _validateUsageLimit,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          ),
        ],
      ),
    );
  }

  Widget _buildTypeOption({
    required String title,
    required String description,
    required IconData icon,
    required DiscountType value,
  }) {
    final isSelected = _selectedType == value;
    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: _isEditMode ? null : () => setState(() => _selectedType = value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color:
              isSelected
                  ? colorScheme.primary.withOpacity(0.1)
                  : colorScheme.surfaceContainerLow,
          border: Border.all(
            color:
                isSelected
                    ? colorScheme.primary
                    : colorScheme.outline.withOpacity(0.3),
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  color:
                      isSelected
                          ? colorScheme.primary
                          : colorScheme.onSurface.withOpacity(0.7),
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color:
                        isSelected
                            ? colorScheme.primary
                            : colorScheme.onSurface,
                  ),
                ),
                const Spacer(),
                if (isSelected)
                  Icon(
                    Icons.check_circle,
                    color: colorScheme.primary,
                    size: 18,
                  ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              description,
              style: TextStyle(
                fontSize: 12,
                color: colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildValiditySection() {
    return ModernCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.schedule, color: Colors.orange),
              ),
              const SizedBox(width: 16),
              Text(
                'Validity Period',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Start Date & End Date (responsive layout)
          LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth > 500;

              if (isWide) {
                return Row(
                  children: [
                    Expanded(child: _buildDatePicker(true)),
                    const SizedBox(width: 16),
                    Expanded(child: _buildDatePicker(false)),
                  ],
                );
              } else {
                return Column(
                  children: [
                    _buildDatePicker(true),
                    const SizedBox(height: 12),
                    _buildDatePicker(false),
                  ],
                );
              }
            },
          ),
          const SizedBox(height: 16),

          // Active Toggle
          SwitchListTile(
            title: const Text('Active'),
            subtitle: const Text('Discount can be used when active'),
            value: _isActive,
            onChanged: (value) => setState(() => _isActive = value),
            contentPadding: EdgeInsets.zero,
          ),
        ],
      ),
    );
  }

  Widget _buildDatePicker(bool isStartDate) {
    final date = isStartDate ? _startDate : _endDate;
    final formatter = DateFormat('MMM d, yyyy');

    return GestureDetector(
      onTap: () => _selectDate(context, isStartDate),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.5),
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(
              isStartDate ? Icons.calendar_today : Icons.event,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isStartDate ? 'Start Date' : 'End Date',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                  Text(
                    formatter.format(date),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoriesSection() {
    return ModernCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.purple.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.category_outlined,
                  color: Colors.purple,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Applicable Categories',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Select which categories this discount applies to. Leave empty for all categories.',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          if (_availableCategories.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: CircularProgressIndicator(),
              ),
            )
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children:
                  _availableCategories.map((category) {
                    final isSelected = _selectedCategories.contains(category);
                    return ModernChip(
                      label: category,
                      selected: isSelected,
                      onTap: () {
                        setState(() {
                          if (isSelected) {
                            _selectedCategories.remove(category);
                          } else {
                            _selectedCategories.add(category);
                          }
                        });
                      },
                    );
                  }).toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildPreviewSection() {
    final colorScheme = Theme.of(context).colorScheme;

    return ModernCard(
      backgroundColor: colorScheme.surfaceContainerLow,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.preview, color: colorScheme.primary),
              ),
              const SizedBox(width: 16),
              Text(
                'Preview',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 16),

          _buildDiscountCard(),
        ],
      ),
    );
  }

  Widget _buildDiscountCard() {
    final colorScheme = Theme.of(context).colorScheme;
    final formatter = DateFormat('MMM d, yyyy');
    final code =
        _codeController.text.isNotEmpty
            ? _codeController.text.toUpperCase()
            : 'CODE';
    final name =
        _nameController.text.isNotEmpty
            ? _nameController.text
            : 'Discount Name';
    final description = _descriptionController.text;

    // Get value from controller or show placeholder
    final valueText =
        _valueController.text.isNotEmpty
            ? (_selectedType == DiscountType.percentage
                ? '${_valueController.text}% OFF'
                : '\$${_valueController.text} OFF')
            : (_selectedType == DiscountType.percentage
                ? '20% OFF'
                : '\$10 OFF');

    // Get minimum amount text
    final minAmountText =
        _minimumAmountController.text.isNotEmpty
            ? 'Min. order: \$${_minimumAmountController.text}'
            : 'No minimum';

    // Get usage limit text
    final usageLimitText =
        _usageLimitController.text.isNotEmpty
            ? 'Limited to ${_usageLimitController.text} uses'
            : 'Unlimited uses';

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colorScheme.surface,
            colorScheme.surfaceContainerHigh.withOpacity(0.7),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header with code and status
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colorScheme.primary.withOpacity(0.1),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: colorScheme.primary,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      code,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color:
                        _isActive
                            ? Colors.green.withOpacity(0.1)
                            : Colors.grey.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color:
                          _isActive
                              ? Colors.green.withOpacity(0.3)
                              : Colors.grey.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _isActive
                            ? Icons.check_circle_outline
                            : Icons.block_outlined,
                        color: _isActive ? Colors.green : Colors.grey,
                        size: 14,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _isActive ? 'Active' : 'Inactive',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: _isActive ? Colors.green : Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                if (description.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 14,
                      color: colorScheme.onSurface.withOpacity(0.7),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                const SizedBox(height: 16),

                // Discount value
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color:
                            _selectedType == DiscountType.percentage
                                ? Colors.purple.withOpacity(0.1)
                                : Colors.green.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _selectedType.icon,
                        color:
                            _selectedType == DiscountType.percentage
                                ? Colors.purple
                                : Colors.green,
                        size: 16,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      valueText,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                        color: colorScheme.primary,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                const Divider(),

                const SizedBox(height: 12),

                // Footer details
                Row(
                  children: [
                    Expanded(
                      child: _buildPreviewDetail(
                        'Applies to:',
                        _selectedCategories.isEmpty
                            ? 'All categories'
                            : _selectedCategories.length > 1
                            ? '${_selectedCategories.length} categories'
                            : _selectedCategories.first,
                        Icons.category_outlined,
                      ),
                    ),
                    Expanded(
                      child: _buildPreviewDetail(
                        'Limits:',
                        '$minAmountText, $usageLimitText',
                        Icons.info_outline,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Date range
                _buildPreviewDetail(
                  'Valid:',
                  '${formatter.format(_startDate)} - ${formatter.format(_endDate)}',
                  Icons.event_outlined,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreviewDetail(String label, String value, IconData icon) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 12,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
