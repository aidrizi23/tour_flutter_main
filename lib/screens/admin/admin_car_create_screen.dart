import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/car_models.dart';
import '../../models/create_car_models.dart'
    hide CreateCarImage, CreateCarFeature, CreateCarRequest;
import '../../services/car_service.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/custom_button.dart';

class AdminCarCreateScreen extends StatefulWidget {
  const AdminCarCreateScreen({super.key});

  @override
  State<AdminCarCreateScreen> createState() => _AdminCarCreateScreenState();
}

class _AdminCarCreateScreenState extends State<AdminCarCreateScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _scrollController = ScrollController();
  final CarService _carService = CarService();

  // Form controllers
  final _makeController = TextEditingController();
  final _modelController = TextEditingController();
  final _yearController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _dailyRateController = TextEditingController();
  final _seatsController = TextEditingController();
  final _locationController = TextEditingController();
  final _mainImageUrlController = TextEditingController();

  String _selectedCategory = 'Economy';
  String _selectedTransmission = 'Automatic';
  String _selectedFuelType = 'Petrol';

  final List<CreateCarFeature> _features = [];
  final List<CreateCarImage> _images = [];

  bool _isCreating = false;
  String? _errorMessage;
  String? _successMessage;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _scrollController.dispose();
    _makeController.dispose();
    _modelController.dispose();
    _yearController.dispose();
    _descriptionController.dispose();
    _dailyRateController.dispose();
    _seatsController.dispose();
    _locationController.dispose();
    _mainImageUrlController.dispose();
    super.dispose();
  }

  Future<void> _createCar() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isCreating = true;
      _errorMessage = null;
      _successMessage = null;
    });

    try {
      final request = CreateCarRequest(
        make: _makeController.text.trim(),
        model: _modelController.text.trim(),
        year: int.parse(_yearController.text.trim()),
        description: _descriptionController.text.trim(),
        dailyRate: double.parse(_dailyRateController.text.trim()),
        category: _selectedCategory,
        transmission: _selectedTransmission,
        fuelType: _selectedFuelType,
        seats: int.parse(_seatsController.text.trim()),
        location: _locationController.text.trim(),
        mainImageUrl:
            _mainImageUrlController.text.trim().isNotEmpty
                ? _mainImageUrlController.text.trim()
                : null,
        features: _features,
        images: _images,
      );

      final car = await _carService.createCar(request);

      setState(() {
        _successMessage = 'Car "${car.displayName}" created successfully!';
      });

      HapticFeedback.heavyImpact();

      // Clear form after successful creation
      _clearForm();

      // Scroll to top to show success message
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeOut,
      );
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
      HapticFeedback.lightImpact();
    } finally {
      setState(() {
        _isCreating = false;
      });
    }
  }

  void _clearForm() {
    _makeController.clear();
    _modelController.clear();
    _yearController.clear();
    _descriptionController.clear();
    _dailyRateController.clear();
    _seatsController.clear();
    _locationController.clear();
    _mainImageUrlController.clear();
    _selectedCategory = 'Economy';
    _selectedTransmission = 'Automatic';
    _selectedFuelType = 'Petrol';
    _features.clear();
    _images.clear();
  }

  void _addFeature() {
    showDialog(
      context: context,
      builder:
          (context) => _FeatureDialog(
            onFeatureAdded: (feature) {
              setState(() {
                _features.add(feature);
              });
            },
          ),
    );
  }

  void _addImage() {
    showDialog(
      context: context,
      builder:
          (context) => _ImageDialog(
            displayOrder: _images.length + 1,
            onImageAdded: (image) {
              setState(() {
                _images.add(image);
              });
            },
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    return Scaffold(
      backgroundColor: colorScheme.surfaceContainerLowest,
      appBar: AppBar(
        title: const Text('Create New Car Listing'),
        backgroundColor: colorScheme.primaryContainer,
        foregroundColor: colorScheme.onPrimaryContainer,
        actions: [
          IconButton(
            icon: const Icon(Icons.clear),
            onPressed: _clearForm,
            tooltip: 'Clear Form',
          ),
        ],
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: SingleChildScrollView(
            controller: _scrollController,
            padding: EdgeInsets.all(isMobile ? 16 : 24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Success Message
                  if (_successMessage != null)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      margin: const EdgeInsets.only(bottom: 24),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.green.withOpacity(0.1),
                            Colors.green.withOpacity(0.05),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.green.withOpacity(0.2),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.check_circle_outline,
                            color: Colors.green,
                            size: 24,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              _successMessage!,
                              style: TextStyle(
                                color: Colors.green.shade700,
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                  // Error Message
                  if (_errorMessage != null)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      margin: const EdgeInsets.only(bottom: 24),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            colorScheme.error.withOpacity(0.1),
                            colorScheme.error.withOpacity(0.05),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: colorScheme.error.withOpacity(0.2),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.warning_rounded,
                            color: colorScheme.error,
                            size: 24,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              _errorMessage!,
                              style: TextStyle(
                                color: colorScheme.error,
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                  // Basic Information Section
                  _buildSection(
                    title: 'Basic Information',
                    icon: Icons.directions_car,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: CustomTextField(
                              controller: _makeController,
                              label: 'Make',
                              hint: 'Toyota',
                              prefixIcon: Icons.business,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter car make';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: CustomTextField(
                              controller: _modelController,
                              label: 'Model',
                              hint: 'Camry',
                              prefixIcon: Icons.drive_eta,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter car model';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: CustomTextField(
                              controller: _yearController,
                              label: 'Year',
                              hint: '2023',
                              prefixIcon: Icons.calendar_today,
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Enter year';
                                }
                                final year = int.tryParse(value);
                                if (year == null ||
                                    year < 1900 ||
                                    year > 2030) {
                                  return 'Enter valid year';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: CustomTextField(
                              controller: _seatsController,
                              label: 'Seats',
                              hint: '5',
                              prefixIcon: Icons.event_seat,
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Enter seats';
                                }
                                final seats = int.tryParse(value);
                                if (seats == null || seats < 2 || seats > 15) {
                                  return 'Enter valid seats (2-15)';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      CustomTextField(
                        controller: _descriptionController,
                        label: 'Description',
                        hint:
                            'Comfortable midsize sedan with excellent fuel economy...',
                        prefixIcon: Icons.description,
                        maxLines: 4,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter car description';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Pricing and Specifications Section
                  _buildSection(
                    title: 'Pricing & Specifications',
                    icon: Icons.monetization_on,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: CustomTextField(
                              controller: _dailyRateController,
                              label: 'Daily Rate (\$)',
                              hint: '75.00',
                              prefixIcon: Icons.attach_money,
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Enter daily rate';
                                }
                                if (double.tryParse(value) == null) {
                                  return 'Invalid rate';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildDropdown(
                              label: 'Category',
                              value: _selectedCategory,
                              items: CarService.categories,
                              onChanged: (value) {
                                setState(() {
                                  _selectedCategory = value!;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _buildDropdown(
                              label: 'Transmission',
                              value: _selectedTransmission,
                              items: CarService.transmissionTypes,
                              onChanged: (value) {
                                setState(() {
                                  _selectedTransmission = value!;
                                });
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildDropdown(
                              label: 'Fuel Type',
                              value: _selectedFuelType,
                              items: CarService.fuelTypes,
                              onChanged: (value) {
                                setState(() {
                                  _selectedFuelType = value!;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Location Section
                  _buildSection(
                    title: 'Location',
                    icon: Icons.location_on,
                    children: [
                      CustomTextField(
                        controller: _locationController,
                        label: 'Location',
                        hint: 'New York, NY',
                        prefixIcon: Icons.place,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter location';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Image Section
                  _buildSection(
                    title: 'Images',
                    icon: Icons.image,
                    children: [
                      CustomTextField(
                        controller: _mainImageUrlController,
                        label: 'Main Image URL (Optional)',
                        hint: 'https://example.com/car-image.jpg',
                        prefixIcon: Icons.image,
                      ),
                      const SizedBox(height: 16),
                      _buildListSection(
                        title: 'Additional Images',
                        items: _images,
                        displayItem:
                            (image) =>
                                '${image.caption ?? 'No caption'} (Order: ${image.displayOrder})',
                        onAdd: _addImage,
                        onRemove: (index) {
                          setState(() {
                            _images.removeAt(index);
                          });
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Features Section
                  _buildSection(
                    title: 'Features',
                    icon: Icons.star,
                    children: [
                      _buildListSection(
                        title: 'Car Features',
                        items: _features,
                        displayItem: (feature) => feature.name,
                        onAdd: _addFeature,
                        onRemove: (index) {
                          setState(() {
                            _features.removeAt(index);
                          });
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 40),

                  // Create Button
                  SizedBox(
                    width: double.infinity,
                    child: CustomButton(
                      onPressed: _isCreating ? null : _createCar,
                      isLoading: _isCreating,
                      minimumSize: const Size(double.infinity, 56),
                      borderRadius: 16,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (!_isCreating) ...[
                            const Icon(Icons.add_circle_outline, size: 20),
                            const SizedBox(width: 8),
                          ],
                          Text(
                            _isCreating
                                ? 'Creating Car...'
                                : 'Create Car Listing',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: colorScheme.primary, size: 24),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ...children,
        ],
      ),
    );
  }

  Widget _buildDropdown({
    required String label,
    required String value,
    required List<String> items,
    required void Function(String?) onChanged,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outline.withOpacity(0.3)),
      ),
      child: DropdownButtonFormField<String>(
        value: value,
        items:
            items.map((item) {
              return DropdownMenuItem<String>(value: item, child: Text(item));
            }).toList(),
        onChanged: onChanged,
        decoration: InputDecoration(
          labelText: label,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(16),
        ),
      ),
    );
  }

  Widget _buildListSection<T>({
    required String title,
    required List<T> items,
    required String Function(T) displayItem,
    required VoidCallback onAdd,
    required void Function(int) onRemove,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            ElevatedButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.add, size: 16),
              label: const Text('Add'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (items.isEmpty)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'No items added yet. Click "Add" to get started.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
          )
        else
          ...items.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerLow,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: colorScheme.outline.withOpacity(0.2)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      displayItem(item),
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                  IconButton(
                    onPressed: () => onRemove(index),
                    icon: Icon(Icons.delete, color: colorScheme.error),
                    iconSize: 20,
                  ),
                ],
              ),
            );
          }),
      ],
    );
  }
}

// Remove duplicate CreateCarRequest, CreateCarFeature, and CreateCarImage classes.
// Use the definitions from '../../services/car_service.dart' instead.

// Feature Dialog
class _FeatureDialog extends StatefulWidget {
  final void Function(CreateCarFeature) onFeatureAdded;

  const _FeatureDialog({required this.onFeatureAdded});

  @override
  State<_FeatureDialog> createState() => _FeatureDialogState();
}

class _FeatureDialogState extends State<_FeatureDialog> {
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Feature'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Feature Name',
              hintText: 'Air Conditioning',
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _descriptionController,
            decoration: const InputDecoration(
              labelText: 'Description (Optional)',
              hintText: 'Climate control system',
            ),
            maxLines: 3,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_nameController.text.trim().isNotEmpty) {
              widget.onFeatureAdded(
                CreateCarFeature(
                  name: _nameController.text.trim(),
                  description:
                      _descriptionController.text.trim().isNotEmpty
                          ? _descriptionController.text.trim()
                          : null,
                ),
              );
              Navigator.of(context).pop();
            }
          },
          child: const Text('Add'),
        ),
      ],
    );
  }
}

// Image Dialog
class _ImageDialog extends StatefulWidget {
  final int displayOrder;
  final void Function(CreateCarImage) onImageAdded;

  const _ImageDialog({required this.displayOrder, required this.onImageAdded});

  @override
  State<_ImageDialog> createState() => _ImageDialogState();
}

class _ImageDialogState extends State<_ImageDialog> {
  final _urlController = TextEditingController();
  final _captionController = TextEditingController();

  @override
  void dispose() {
    _urlController.dispose();
    _captionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Image'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _urlController,
            decoration: const InputDecoration(
              labelText: 'Image URL',
              hintText: 'https://example.com/car-image.jpg',
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _captionController,
            decoration: const InputDecoration(
              labelText: 'Caption (Optional)',
              hintText: 'Front view',
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_urlController.text.trim().isNotEmpty) {
              widget.onImageAdded(
                CreateCarImage(
                  imageUrl: _urlController.text.trim(),
                  caption:
                      _captionController.text.trim().isNotEmpty
                          ? _captionController.text.trim()
                          : null,
                  displayOrder: widget.displayOrder,
                ),
              );
              Navigator.of(context).pop();
            }
          },
          child: const Text('Add'),
        ),
      ],
    );
  }
}
