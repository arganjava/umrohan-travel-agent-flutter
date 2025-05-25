import 'package:flutter/material.dart';
import '../services/booking_service.dart';
import '../models/luggage_info_model.dart';

class AddLuggageScreen extends StatefulWidget {
  final String bookingId;
  final String pilgrimId;

  const AddLuggageScreen({
    super.key,
    required this.bookingId,
    required this.pilgrimId,
  });

  @override
  State<AddLuggageScreen> createState() => _AddLuggageScreenState();
}

class _AddLuggageScreenState extends State<AddLuggageScreen> {
  final BookingService _bookingService = BookingService();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  // TextEditingControllers
  final TextEditingController _typeController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _tagNumberController = TextEditingController();

  @override
  void dispose() {
    _typeController.dispose();
    _weightController.dispose();
    _quantityController.dispose();
    _tagNumberController.dispose();
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
      final newLuggageInfo = LuggageInfo(
        pilgrimId: widget.pilgrimId, // Set pilgrimId
        type: _typeController.text.trim(),
        weight: double.tryParse(_weightController.text.trim()) ?? 0.0,
        quantity: int.tryParse(_quantityController.text.trim()) ?? 0,
        tagNumber: _tagNumberController.text.trim().isEmpty ? null : _tagNumberController.text.trim(),
      );

      await _bookingService.addLuggageInfo(widget.bookingId, widget.pilgrimId, newLuggageInfo);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Luggage item added successfully!')),
        );
        Navigator.of(context).pop(true); // Pop and indicate success
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add luggage item: ${e.toString()}')),
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
        title: const Text('Add Luggage'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              TextFormField(
                controller: _typeController,
                decoration: const InputDecoration(labelText: 'Luggage Type (e.g., Checked Bag, Carry-on)'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter luggage type';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _weightController,
                decoration: const InputDecoration(labelText: 'Weight (kg)'),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter weight';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid number for weight';
                  }
                   if ((double.tryParse(value) ?? 0) <= 0) {
                    return 'Weight must be greater than zero';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _quantityController,
                decoration: const InputDecoration(labelText: 'Quantity'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter quantity';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Please enter a valid number for quantity';
                  }
                  if ((int.tryParse(value) ?? 0) <= 0) {
                    return 'Quantity must be at least 1';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _tagNumberController,
                decoration: const InputDecoration(labelText: 'Tag Number (Optional)'),
              ),
              const SizedBox(height: 24),
              if (_isLoading)
                const Center(child: CircularProgressIndicator())
              else
                ElevatedButton(
                  onPressed: _submitForm,
                  child: const Text('Add Luggage'),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
