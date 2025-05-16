import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/create_tour_models.dart';
import '../../services/tour_service.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/custom_button.dart';

class AdminTourCreateScreen extends StatefulWidget {
  const AdminTourCreateScreen({super.key});

  @override
  State<AdminTourCreateScreen> createState() => _AdminTourCreateScreenState();
}

class _AdminTourCreateScreenState extends State<AdminTourCreateScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _scrollController = ScrollController();
  final TourService _tourService = TourService();

  // Form controllers
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _durationController = TextEditingController();
  final _locationController = TextEditingController();
  final _maxGroupSizeController = TextEditingController();
  final _mainImageUrlController = TextEditingController();
  final _categoryController = TextEditingController();

  String _selectedDifficulty = 'Easy';
  String _selectedActivityType = 'Outdoor';

  final List<CreateTourFeature> _features = [];
  final List<CreateItineraryItem> _itineraryItems = [];
  final List<CreateTourImage> _images = [];

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
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _durationController.dispose();
    _locationController.dispose();
    _maxGroupSizeController.dispose();
    _mainImageUrlController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  Future<void> _createTour() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isCreating = true;
      _errorMessage = null;
      _successMessage = null;
    });

    try {
      final request = CreateTourRequest(
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        price: double.parse(_priceController.text.trim()),
        durationInDays: int.parse(_durationController.text.trim()),
        location: _locationController.text.trim(),
        difficultyLevel: _selectedDifficulty,
        activityType: _selectedActivityType,
        category: _categoryController.text.trim(),
        maxGroupSize: int.parse(_maxGroupSizeController.text.trim()),
        mainImageUrl:
            _mainImageUrlController.text.trim().isNotEmpty
                ? _mainImageUrlController.text.trim()
                : null,
        features: _features,
        itineraryItems: _itineraryItems,
        images: _images,
      );

      final tour = await _tourService.createTour(request);

      setState(() {
        _successMessage = 'Tour "${tour.name}" created successfully!';
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
    _nameController.clear();
    _descriptionController.clear();
    _priceController.clear();
    _durationController.clear();
    _locationController.clear();
    _maxGroupSizeController.clear();
    _mainImageUrlController.clear();
    _categoryController.clear();
    _selectedDifficulty = 'Easy';
    _selectedActivityType = 'Outdoor';
    _features.clear();
    _itineraryItems.clear();
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

  void _addItineraryItem() {
    showDialog(
      context: context,
      builder:
          (context) => _ItineraryDialog(
            dayNumber: _itineraryItems.length + 1,
            onItemAdded: (item) {
              setState(() {
                _itineraryItems.add(item);
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
        title: const Text('Create New Tour'),
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
                          Icon(
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
                    icon: Icons.info_outline,
                    children: [
                      CustomTextField(
                        controller: _nameController,
                        label: 'Tour Name',
                        hint: 'Amazing City Tour',
                        prefixIcon: Icons.tour,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter tour name';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      CustomTextField(
                        controller: _descriptionController,
                        label: 'Description',
                        hint: 'Describe your tour in detail...',
                        prefixIcon: Icons.description,
                        maxLines: 4,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter tour description';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      CustomTextField(
                        controller: _categoryController,
                        label: 'Category',
                        hint: 'Cultural, Adventure, Beach, etc.',
                        prefixIcon: Icons.category,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter tour category';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Pricing and Duration Section
                  _buildSection(
                    title: 'Pricing & Duration',
                    icon: Icons.monetization_on,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: CustomTextField(
                              controller: _priceController,
                              label: 'Price (\$)',
                              hint: '99.99',
                              prefixIcon: Icons.attach_money,
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Enter price';
                                }
                                if (double.tryParse(value) == null) {
                                  return 'Invalid price';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: CustomTextField(
                              controller: _durationController,
                              label: 'Duration (Days)',
                              hint: '3',
                              prefixIcon: Icons.schedule,
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Enter duration';
                                }
                                if (int.tryParse(value) == null) {
                                  return 'Invalid duration';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      CustomTextField(
                        controller: _maxGroupSizeController,
                        label: 'Max Group Size',
                        hint: '15',
                        prefixIcon: Icons.group,
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Enter max group size';
                          }
                          if (int.tryParse(value) == null) {
                            return 'Invalid group size';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Location & Attributes Section
                  _buildSection(
                    title: 'Location & Attributes',
                    icon: Icons.location_on,
                    children: [
                      CustomTextField(
                        controller: _locationController,
                        label: 'Location',
                        hint: 'Paris, France',
                        prefixIcon: Icons.place,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter location';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _buildDropdown(
                              label: 'Difficulty Level',
                              value: _selectedDifficulty,
                              items: TourService.difficultyLevels,
                              onChanged: (value) {
                                setState(() {
                                  _selectedDifficulty = value!;
                                });
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildDropdown(
                              label: 'Activity Type',
                              value: _selectedActivityType,
                              items: TourService.activityTypes,
                              onChanged: (value) {
                                setState(() {
                                  _selectedActivityType = value!;
                                });
                              },
                            ),
                          ),
                        ],
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
                        hint: 'https://example.com/image.jpg',
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
                        title: 'Tour Features',
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

                  const SizedBox(height: 24),

                  // Itinerary Section
                  _buildSection(
                    title: 'Itinerary',
                    icon: Icons.route,
                    children: [
                      _buildListSection(
                        title: 'Itinerary Items',
                        items: _itineraryItems,
                        displayItem:
                            (item) => 'Day ${item.dayNumber}: ${item.title}',
                        onAdd: _addItineraryItem,
                        onRemove: (index) {
                          setState(() {
                            _itineraryItems.removeAt(index);
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
                      onPressed: _isCreating ? null : _createTour,
                      isLoading: _isCreating,
                      minimumSize: const Size(double.infinity, 56),
                      borderRadius: 16,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (!_isCreating) ...[
                            const Icon(Icons.create_rounded, size: 20),
                            const SizedBox(width: 8),
                          ],
                          Text(
                            _isCreating ? 'Creating Tour...' : 'Create Tour',
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

// Feature Dialog
class _FeatureDialog extends StatefulWidget {
  final void Function(CreateTourFeature) onFeatureAdded;

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
              hintText: 'Audio Guide',
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _descriptionController,
            decoration: const InputDecoration(
              labelText: 'Description (Optional)',
              hintText: 'Professional audio commentary',
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
                CreateTourFeature(
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

// Itinerary Dialog
class _ItineraryDialog extends StatefulWidget {
  final int dayNumber;
  final void Function(CreateItineraryItem) onItemAdded;

  const _ItineraryDialog({required this.dayNumber, required this.onItemAdded});

  @override
  State<_ItineraryDialog> createState() => _ItineraryDialogState();
}

class _ItineraryDialogState extends State<_ItineraryDialog> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  final _startTimeController = TextEditingController();
  final _endTimeController = TextEditingController();
  final _activityTypeController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _startTimeController.dispose();
    _endTimeController.dispose();
    _activityTypeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Add Day ${widget.dayNumber} Activity'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Activity Title',
                hintText: 'Morning Visit',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
                hintText: 'Visit the famous landmark',
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _locationController,
              decoration: const InputDecoration(
                labelText: 'Location (Optional)',
                hintText: 'Downtown',
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _startTimeController,
                    decoration: const InputDecoration(
                      labelText: 'Start Time (Optional)',
                      hintText: '09:00',
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextField(
                    controller: _endTimeController,
                    decoration: const InputDecoration(
                      labelText: 'End Time (Optional)',
                      hintText: '12:00',
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _activityTypeController,
              decoration: const InputDecoration(
                labelText: 'Activity Type (Optional)',
                hintText: 'Sightseeing',
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_titleController.text.trim().isNotEmpty &&
                _descriptionController.text.trim().isNotEmpty) {
              widget.onItemAdded(
                CreateItineraryItem(
                  dayNumber: widget.dayNumber,
                  title: _titleController.text.trim(),
                  description: _descriptionController.text.trim(),
                  location:
                      _locationController.text.trim().isNotEmpty
                          ? _locationController.text.trim()
                          : null,
                  startTime:
                      _startTimeController.text.trim().isNotEmpty
                          ? _startTimeController.text.trim()
                          : null,
                  endTime:
                      _endTimeController.text.trim().isNotEmpty
                          ? _endTimeController.text.trim()
                          : null,
                  activityType:
                      _activityTypeController.text.trim().isNotEmpty
                          ? _activityTypeController.text.trim()
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
  final void Function(CreateTourImage) onImageAdded;

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
              hintText: 'https://example.com/image.jpg',
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _captionController,
            decoration: const InputDecoration(
              labelText: 'Caption (Optional)',
              hintText: 'Beautiful view',
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
                CreateTourImage(
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
