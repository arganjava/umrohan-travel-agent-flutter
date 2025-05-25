import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For date formatting
import '../services/booking_service.dart';
import '../models/pilgrim_model.dart';

class EditPilgrimScreen extends StatefulWidget {
  final String bookingId;
  final Pilgrim pilgrim;

  const EditPilgrimScreen({
    super.key,
    required this.bookingId,
    required this.pilgrim,
  });

  @override
  State<EditPilgrimScreen> createState() => _EditPilgrimScreenState();
}

class _EditPilgrimScreenState extends State<EditPilgrimScreen> {
  final BookingService _bookingService = BookingService();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  // TextEditingControllers
  late TextEditingController _fullNameController;
  late TextEditingController _passportNumberController;
  late TextEditingController _nationalityController;
  late TextEditingController _contactNumberController;
  late TextEditingController _emailController;
  late TextEditingController _statusController; // For pilgrim status

  // For DropdownButtonFormField (Gender)
  String? _selectedGender;
  final List<String> _genders = ['Male', 'Female', 'Other'];

  // For DateTime fields
  DateTime? _selectedDateOfBirth;
  DateTime? _selectedPassportExpiryDate;

  @override
  void initState() {
    super.initState();
    _fullNameController = TextEditingController(text: widget.pilgrim.fullName);
    _passportNumberController = TextEditingController(text: widget.pilgrim.passportNumber);
    _nationalityController = TextEditingController(text: widget.pilgrim.nationality);
    _contactNumberController = TextEditingController(text: widget.pilgrim.contactNumber ?? '');
    _emailController = TextEditingController(text: widget.pilgrim.email ?? '');
    _statusController = TextEditingController(text: widget.pilgrim.status);

    _selectedGender = widget.pilgrim.gender;
    _selectedDateOfBirth = widget.pilgrim.dateOfBirth;
    _selectedPassportExpiryDate = widget.pilgrim.passportExpiryDate;
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _passportNumberController.dispose();
    _nationalityController.dispose();
    _contactNumberController.dispose();
    _emailController.dispose();
    _statusController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context, Function(DateTime) onDateSelected, DateTime? initialDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != initialDate) {
      onDateSelected(picked);
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    if (_selectedDateOfBirth == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select Date of Birth.')),
      );
      return;
    }
    if (_selectedPassportExpiryDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select Passport Expiry Date.')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Use copyWith on the existing pilgrim object to preserve other fields like IDs
      final updatedPilgrim = widget.pilgrim.copyWith(
        fullName: _fullNameController.text.trim(),
        gender: _selectedGender!,
        dateOfBirth: _selectedDateOfBirth!,
        passportNumber: _passportNumberController.text.trim(),
        passportExpiryDate: _selectedPassportExpiryDate!,
        nationality: _nationalityController.text.trim(),
        contactNumber: _contactNumberController.text.trim().isEmpty ? null : _contactNumberController.text.trim(),
        email: _emailController.text.trim().isEmpty ? null : _emailController.text.trim(),
        status: _statusController.text.trim(), // Update status from controller
      );

      await _bookingService.updatePilgrim(widget.bookingId, updatedPilgrim);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Pilgrim details updated successfully!')),
        );
        Navigator.of(context).pop(true); // Pop and indicate success
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update pilgrim: ${e.toString()}')),
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
        title: const Text('Edit Pilgrim Details'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              TextFormField(
                controller: _fullNameController,
                decoration: const InputDecoration(labelText: 'Full Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter full name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _selectedGender,
                decoration: const InputDecoration(labelText: 'Gender'),
                items: _genders.map((String gender) {
                  return DropdownMenuItem<String>(
                    value: gender,
                    child: Text(gender),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    _selectedGender = newValue;
                  });
                },
                validator: (value) => value == null ? 'Please select gender' : null,
              ),
              const SizedBox(height: 12),
              _buildDatePickerField(
                context: context,
                labelText: 'Date of Birth',
                selectedDate: _selectedDateOfBirth,
                onDateSelected: (date) => setState(() => _selectedDateOfBirth = date),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _passportNumberController,
                decoration: const InputDecoration(labelText: 'Passport Number'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter passport number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
               _buildDatePickerField(
                context: context,
                labelText: 'Passport Expiry Date',
                selectedDate: _selectedPassportExpiryDate,
                onDateSelected: (date) => setState(() => _selectedPassportExpiryDate = date),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _nationalityController,
                decoration: const InputDecoration(labelText: 'Nationality'),
                 validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter nationality';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _contactNumberController,
                decoration: const InputDecoration(labelText: 'Contact Number (Optional)'),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email (Optional)'),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value != null && value.isNotEmpty && !value.contains('@')) {
                    return 'Please enter a valid email';
                  }
                  return null;
                }
              ),
              const SizedBox(height: 12),
              TextFormField( // Field for Pilgrim Status
                controller: _statusController,
                decoration: const InputDecoration(labelText: 'Pilgrim Status'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter pilgrim status';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              if (_isLoading)
                const Center(child: CircularProgressIndicator())
              else
                ElevatedButton(
                  onPressed: _submitForm,
                  child: const Text('Save Changes'),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDatePickerField({
    required BuildContext context,
    required String labelText,
    required DateTime? selectedDate,
    required Function(DateTime) onDateSelected,
  }) {
    return TextFormField(
      decoration: InputDecoration(
        labelText: labelText,
        suffixIcon: const Icon(Icons.calendar_today),
      ),
      readOnly: true,
      controller: TextEditingController(
        text: selectedDate == null ? '' : DateFormat('dd MMM yyyy').format(selectedDate),
      ),
      onTap: () => _selectDate(context, onDateSelected, selectedDate),
      validator: (value) {
        if (selectedDate == null) {
          return 'Please select $labelText';
        }
        return null;
      },
    );
  }
}
