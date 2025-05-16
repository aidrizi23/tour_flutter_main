import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import '../services/auth_service.dart';

class BillingDetailsHelper {
  static Future<BillingDetails?> getUserBillingDetails() async {
    try {
      final authService = AuthService();
      final user = await authService.getCurrentUser();

      if (user != null) {
        return BillingDetails(
          email: user.email,
          name: user.userName,
          // Add more details if available in your user model
          // phone: user.phone,
          // address: Address(
          //   city: user.city,
          //   country: user.country,
          //   line1: user.addressLine1,
          //   line2: user.addressLine2,
          //   postalCode: user.postalCode,
          //   state: user.state,
          // ),
        );
      }

      return null;
    } catch (e) {
      print('Error getting billing details: $e');
      return null;
    }
  }

  static BillingDetails createBillingDetails({
    String? email,
    String? name,
    String? phone,
    String? addressLine1,
    String? addressLine2,
    String? city,
    String? state,
    String? postalCode,
    String? country,
  }) {
    return BillingDetails(
      email: email,
      name: name,
      phone: phone,
      address: Address(
        city: city,
        country: country,
        line1: addressLine1,
        line2: addressLine2,
        postalCode: postalCode,
        state: state,
      ),
    );
  }

  static Widget buildBillingForm({
    required Function(BillingDetails) onChanged,
    BillingDetails? initialDetails,
  }) {
    return BillingDetailsForm(
      onChanged: onChanged,
      initialDetails: initialDetails,
    );
  }
}

class BillingDetailsForm extends StatefulWidget {
  final Function(BillingDetails) onChanged;
  final BillingDetails? initialDetails;

  const BillingDetailsForm({
    super.key,
    required this.onChanged,
    this.initialDetails,
  });

  @override
  State<BillingDetailsForm> createState() => _BillingDetailsFormState();
}

class _BillingDetailsFormState extends State<BillingDetailsForm> {
  late TextEditingController _emailController;
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _addressLine1Controller;
  late TextEditingController _addressLine2Controller;
  late TextEditingController _cityController;
  late TextEditingController _stateController;
  late TextEditingController _postalCodeController;
  late TextEditingController _countryController;

  @override
  void initState() {
    super.initState();

    _emailController = TextEditingController(
      text: widget.initialDetails?.email ?? '',
    );
    _nameController = TextEditingController(
      text: widget.initialDetails?.name ?? '',
    );
    _phoneController = TextEditingController(
      text: widget.initialDetails?.phone ?? '',
    );
    _addressLine1Controller = TextEditingController(
      text: widget.initialDetails?.address?.line1 ?? '',
    );
    _addressLine2Controller = TextEditingController(
      text: widget.initialDetails?.address?.line2 ?? '',
    );
    _cityController = TextEditingController(
      text: widget.initialDetails?.address?.city ?? '',
    );
    _stateController = TextEditingController(
      text: widget.initialDetails?.address?.state ?? '',
    );
    _postalCodeController = TextEditingController(
      text: widget.initialDetails?.address?.postalCode ?? '',
    );
    _countryController = TextEditingController(
      text: widget.initialDetails?.address?.country ?? '',
    );

    // Listen to all controllers for changes
    _setupListeners();
  }

  void _setupListeners() {
    final controllers = [
      _emailController,
      _nameController,
      _phoneController,
      _addressLine1Controller,
      _addressLine2Controller,
      _cityController,
      _stateController,
      _postalCodeController,
      _countryController,
    ];

    for (final controller in controllers) {
      controller.addListener(_onFormChanged);
    }
  }

  void _onFormChanged() {
    final billingDetails = BillingDetails(
      email: _emailController.text.isEmpty ? null : _emailController.text,
      name: _nameController.text.isEmpty ? null : _nameController.text,
      phone: _phoneController.text.isEmpty ? null : _phoneController.text,
      address: Address(
        line1:
            _addressLine1Controller.text.isEmpty
                ? null
                : _addressLine1Controller.text,
        line2:
            _addressLine2Controller.text.isEmpty
                ? null
                : _addressLine2Controller.text,
        city: _cityController.text.isEmpty ? null : _cityController.text,
        state: _stateController.text.isEmpty ? null : _stateController.text,
        postalCode:
            _postalCodeController.text.isEmpty
                ? null
                : _postalCodeController.text,
        country:
            _countryController.text.isEmpty ? null : _countryController.text,
      ),
    );

    widget.onChanged(billingDetails);
  }

  @override
  void dispose() {
    _emailController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _addressLine1Controller.dispose();
    _addressLine2Controller.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _postalCodeController.dispose();
    _countryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outline.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: colorScheme.secondaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.person_rounded,
                  color: colorScheme.secondary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Billing Information',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Email and Name
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: 'Full Name',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Phone
          TextFormField(
            controller: _phoneController,
            decoration: InputDecoration(
              labelText: 'Phone (Optional)',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 12),

          // Address
          TextFormField(
            controller: _addressLine1Controller,
            decoration: InputDecoration(
              labelText: 'Address Line 1 (Optional)',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          const SizedBox(height: 12),

          TextFormField(
            controller: _addressLine2Controller,
            decoration: InputDecoration(
              labelText: 'Address Line 2 (Optional)',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // City, State, Postal Code
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _cityController,
                  decoration: InputDecoration(
                    labelText: 'City (Optional)',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  controller: _stateController,
                  decoration: InputDecoration(
                    labelText: 'State/Province (Optional)',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _postalCodeController,
                  decoration: InputDecoration(
                    labelText: 'Postal Code (Optional)',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  controller: _countryController,
                  decoration: InputDecoration(
                    labelText: 'Country (Optional)',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
