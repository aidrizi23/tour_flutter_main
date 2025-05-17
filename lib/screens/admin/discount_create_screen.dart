import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

  // Animation controllers
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

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
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeOut));
    _fadeController.forward();
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
        });
      }
    } catch (e) {
      // Handle error silently
    }
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final initialDate = isStartDate ? _startDate : _endDate;
    final firstDate = isStartDate ? DateTime.now() : _startDate;
    final lastDate = DateTime.now().add(const Duration(days: 365 * 2));

    final pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
      builder: (context, child) {
        return Theme(
          data: Theme.of(
            context,
          ).copyWith(colorScheme: Theme.of(context).colorScheme),
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
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
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
      }

      if (mounted) {
        ModernSnackBar.show(
          context,
          message:
              _isEditMode
                  ? 'Discount updated successfully'
                  : 'Discount created successfully',
          type: SnackBarType.success,
        );
        Navigator.of(context).pop(true);
      }
    } catch (e) {
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditMode ? 'Edit Discount' : 'Create Discount'),
        elevation: 0,
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildBasicInfoSection(),
              const SizedBox(height: 24),
              _buildDiscountDetailsSection(),
              const SizedBox(height: 24),
              _buildValiditySection(),
              const SizedBox(height: 24),
              _buildCategoriesSection(),
              const SizedBox(height: 24),
              _buildPreviewSection(),
              const SizedBox(height: 32),
              _buildActionButtons(),
              const SizedBox(height: 32),
            ],
          ),
        ),
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
                child: ModernChip(
                  label: 'Percentage',
                  selected: _selectedType == DiscountType.percentage,
                  icon: Icons.percent,
                  onTap:
                      _isEditMode
                          ? null
                          : () => setState(
                            () => _selectedType = DiscountType.percentage,
                          ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ModernChip(
                  label: 'Fixed Amount',
                  selected: _selectedType == DiscountType.fixedAmount,
                  icon: Icons.attach_money,
                  onTap:
                      _isEditMode
                          ? null
                          : () => setState(
                            () => _selectedType = DiscountType.fixedAmount,
                          ),
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

          // Start Date
          GestureDetector(
            onTap: () => _selectDate(context, true),
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
                    Icons.calendar_today,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Start Date',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withOpacity(0.7),
                        ),
                      ),
                      Text(
                        '${_startDate.day}/${_startDate.month}/${_startDate.year}',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const Spacer(),
                  const Icon(Icons.chevron_right),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          // End Date
          GestureDetector(
            onTap: () => _selectDate(context, false),
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
                    Icons.event,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'End Date',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withOpacity(0.7),
                        ),
                      ),
                      Text(
                        '${_endDate.day}/${_endDate.month}/${_endDate.year}',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const Spacer(),
                  const Icon(Icons.chevron_right),
                ],
              ),
            ),
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
              Text(
                'Applicable Categories',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Select which categories this discount applies to. Leave empty for all categories.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 16),

          if (_availableCategories.isEmpty)
            const Center(child: CircularProgressIndicator())
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
    return ModernCard(
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerLow,
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
                  Icons.preview,
                  color: Theme.of(context).colorScheme.primary,
                ),
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

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(
                          context,
                        ).colorScheme.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        _codeController.text.toUpperCase(),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ModernTag(
                      label: _isActive ? 'Active' : 'Inactive',
                      backgroundColor:
                          _isActive
                              ? Colors.green.withOpacity(0.1)
                              : Colors.grey.withOpacity(0.1),
                      textColor: _isActive ? Colors.green : Colors.grey,
                      icon: _isActive ? Icons.check_circle : Icons.pause_circle,
                      isSmall: true,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  _nameController.text.isNotEmpty
                      ? _nameController.text
                      : 'Discount Name',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (_descriptionController.text.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    _descriptionController.text,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                ],
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(
                      _selectedType.icon,
                      size: 16,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _valueController.text.isNotEmpty
                          ? (_selectedType == DiscountType.percentage
                              ? '${_valueController.text}% OFF'
                              : '\$${_valueController.text} OFF')
                          : 'Value not set',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                if (_minimumAmountController.text.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Minimum order: \$${_minimumAmountController.text}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
                if (_usageLimitController.text.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Limited to ${_usageLimitController.text} uses',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
                const SizedBox(height: 8),
                Text(
                  'Valid: ${_startDate.day}/${_startDate.month}/${_startDate.year} - ${_endDate.day}/${_endDate.month}/${_endDate.year}',
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
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: CustomButton(
            onPressed: () => Navigator.of(context).pop(),
            text: 'Cancel',
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: CustomButton(
            onPressed: _saveDiscount,
            text: _isEditMode ? 'Update Discount' : 'Create Discount',
            isLoading: _isLoading,
            icon: _isEditMode ? Icons.update : Icons.add,
          ),
        ),
      ],
    );
  }
}
