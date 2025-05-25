import 'package:flutter/material.dart';
import '../services/package_service.dart';
import '../models/package_model.dart';

class AddPackageScreen extends StatefulWidget {
  const AddPackageScreen({super.key});

  @override
  State<AddPackageScreen> createState() => _AddPackageScreenState();
}

class _AddPackageScreenState extends State<AddPackageScreen> {
  final PackageService _packageService = PackageService();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  // TextEditingControllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _minimalDownPaymentController = TextEditingController();
  final TextEditingController _scheduleController = TextEditingController();
  final TextEditingController _itineraryController = TextEditingController();
  final TextEditingController _quotaController = TextEditingController();
  final TextEditingController _durationController = TextEditingController();
  final TextEditingController _facilitiesController = TextEditingController(); // Comma-separated
  final TextEditingController _imageUrlController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _minimalDownPaymentController.dispose();
    _scheduleController.dispose();
    _itineraryController.dispose();
    _quotaController.dispose();
    _durationController.dispose();
    _facilitiesController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    setState(() {
      _isLoading = true;
    });

    try {
      final newPackage = UmrahPackage(
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        price: double.tryParse(_priceController.text.trim()) ?? 0.0,
        minimalDownPayment: double.tryParse(_minimalDownPaymentController.text.trim()) ?? 0.0,
        schedule: _scheduleController.text.trim(),
        itinerary: _itineraryController.text.trim(),
        quota: int.tryParse(_quotaController.text.trim()) ?? 0,
        duration: _durationController.text.trim(),
        facilities: _facilitiesController.text.trim().split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList(),
        imageUrl: _imageUrlController.text.trim().isEmpty ? null : _imageUrlController.text.trim(),
      );

      await _packageService.addPackage(newPackage);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Package added successfully!')),
        );
        Navigator.of(context).pop(); // Go back to PackagesListScreen
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add package: ${e.toString()}')),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Package'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Package Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter package name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter package description';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _priceController,
                decoration: const InputDecoration(labelText: 'Price (\$)'),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the price';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid number for price';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _minimalDownPaymentController,
                decoration: const InputDecoration(labelText: 'Minimal Down Payment (\$)'),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                 validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter minimal down payment';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                   if ((double.tryParse(value) ?? 0) > (double.tryParse(_priceController.text) ?? 0)) {
                    return 'Down payment cannot exceed total price';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _scheduleController,
                decoration: const InputDecoration(labelText: 'Schedule (e.g., Every Monday)'),
                 validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the schedule';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _itineraryController,
                decoration: const InputDecoration(labelText: 'Itinerary (brief)'),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the itinerary';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _quotaController,
                decoration: const InputDecoration(labelText: 'Quota / Pax'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the quota';
                  }
                  if (int.tryParse(value) == null || (int.tryParse(value) ?? 0) <= 0) {
                    return 'Please enter a valid positive number for quota';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _durationController,
                decoration: const InputDecoration(labelText: 'Duration (e.g., 9 Days)'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the duration';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _facilitiesController,
                decoration: const InputDecoration(labelText: 'Facilities (comma-separated)'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter facilities';
                  }
                   if (value.trim().split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList().isEmpty) {
                    return 'Please enter at least one facility';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _imageUrlController,
                decoration: const InputDecoration(labelText: 'Image URL (optional)'),
                keyboardType: TextInputType.url,
                validator: (value) {
                  if (value != null && value.isNotEmpty) {
                    if (!Uri.tryParse(value)?.hasAbsolutePath ?? true) {
                       return 'Please enter a valid URL';
                    }
                  }
                  return null;
                }
              ),
              const SizedBox(height: 24),
              if (_isLoading)
                const Center(child: CircularProgressIndicator())
              else
                ElevatedButton(
                  onPressed: _submitForm,
                  child: const Text('Add Package'),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
