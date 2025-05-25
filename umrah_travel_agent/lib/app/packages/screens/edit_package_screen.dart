import 'package:flutter/material.dart';
import '../services/package_service.dart';
import '../models/package_model.dart';

class EditPackageScreen extends StatefulWidget {
  final UmrahPackage package;

  const EditPackageScreen({super.key, required this.package});

  @override
  State<EditPackageScreen> createState() => _EditPackageScreenState();
}

class _EditPackageScreenState extends State<EditPackageScreen> {
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
  void initState() {
    super.initState();
    // Initialize controllers with the package data
    _nameController.text = widget.package.name;
    _descriptionController.text = widget.package.description;
    _priceController.text = widget.package.price.toString();
    _minimalDownPaymentController.text = widget.package.minimalDownPayment.toString();
    _scheduleController.text = widget.package.schedule;
    _itineraryController.text = widget.package.itinerary;
    _quotaController.text = widget.package.quota.toString();
    _durationController.text = widget.package.duration;
    _facilitiesController.text = widget.package.facilities.join(', ');
    _imageUrlController.text = widget.package.imageUrl ?? '';
  }

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
      final updatedPackage = UmrahPackage(
        id: widget.package.id, // Crucial: Pass the original package ID
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

      await _packageService.updatePackage(updatedPackage);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Package updated successfully!')),
        );
        Navigator.of(context).pop(); // Go back to PackagesListScreen
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update package: ${e.toString()}')),
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

  Future<void> _deletePackage() async {
    // Ensure package ID is available
    if (widget.package.id == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error: Package ID is missing. Cannot delete.')),
      );
      return;
    }

    // Show confirmation dialog
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Delete Package?'),
          content: Text("Are you sure you want to delete '${widget.package.name}'? This action cannot be undone."),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(dialogContext).pop(false); // User cancelled
              },
            ),
            TextButton(
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Delete'),
              onPressed: () {
                Navigator.of(dialogContext).pop(true); // User confirmed
              },
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      setState(() {
        _isLoading = true; // Show loading indicator on the screen
      });

      try {
        await _packageService.deletePackage(widget.package.id!);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Package deleted successfully!')),
          );
          // Pop twice: once for the dialog (if not already popped by confirmation), once for EditPackageScreen
          // Navigator.of(context).pop(); // Pop EditPackageScreen, dialog is already popped by its buttons
          Navigator.of(context).popUntil((route) => route.isFirst); // Go back to the first screen in stack (usually list)
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to delete package: ${e.toString()}')),
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Package'),
        actions: <Widget>[
          if (_isLoading) // Show loading indicator in AppBar if busy
            const Padding(
              padding: EdgeInsets.only(right: 16.0),
              child: Center(child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2.0, color: Colors.white)))),
          else
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: _deletePackage, // Call delete method
              tooltip: 'Delete Package',
            ),
        ],
      ),
      body: _isLoading 
          ? const Center(child: CircularProgressIndicator()) 
          : SingleChildScrollView(
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
                  child: const Text('Update Package'), // Changed button text
                ),
            ],
          ),
        ),
      ),
    );
  }
}
