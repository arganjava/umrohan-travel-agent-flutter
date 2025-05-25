import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For date formatting
import '../services/booking_service.dart';
import '../models/visa_model.dart';

class ManageVisaScreen extends StatefulWidget {
  final String bookingId;
  final String pilgrimId;
  final String? visaId; // Nullable for adding new

  const ManageVisaScreen({
    super.key,
    required this.bookingId,
    required this.pilgrimId,
    this.visaId,
  });

  @override
  State<ManageVisaScreen> createState() => _ManageVisaScreenState();
}

class _ManageVisaScreenState extends State<ManageVisaScreen> {
  final BookingService _bookingService = BookingService();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false; // For form submission
  bool _isFetchingData = false; // For loading existing data in edit mode
  late bool _isEditMode;
  Visa? _existingVisa;

  // TextEditingControllers
  final TextEditingController _visaNumberController = TextEditingController();
  final TextEditingController _typeController = TextEditingController();
  
  // For DropdownButtonFormField (Status)
  String? _selectedStatus;
  final List<String> _statuses = ['Applied', 'Approved', 'Rejected', 'Pending', 'Expired'];

  // For DateTime fields
  DateTime? _selectedIssueDate;
  DateTime? _selectedExpiryDate;

  @override
  void initState() {
    super.initState();
    _isEditMode = widget.visaId != null;
    if (_isEditMode) {
      _loadExistingVisaData();
    } else {
      _selectedStatus = 'Pending'; // Default for new visa
    }
  }

  Future<void> _loadExistingVisaData() async {
    setState(() {
      _isFetchingData = true;
    });
    try {
      _existingVisa = await _bookingService.getVisaById(
        widget.bookingId,
        widget.pilgrimId,
        widget.visaId!,
      );
      if (_existingVisa != null) {
        _visaNumberController.text = _existingVisa!.visaNumber;
        _typeController.text = _existingVisa!.type;
        _selectedStatus = _existingVisa!.status;
        _selectedIssueDate = _existingVisa!.issueDate;
        _selectedExpiryDate = _existingVisa!.expiryDate;
      } else {
         if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Failed to load existing visa details.')),
            );
         }
      }
    } catch (e) {
       if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error loading visa: ${e.toString()}')),
          );
       }
    } finally {
      if (mounted) {
        setState(() {
          _isFetchingData = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _visaNumberController.dispose();
    _typeController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context, Function(DateTime) onDateSelected, DateTime? initialDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate ?? DateTime.now(),
      firstDate: DateTime(2000), // Visas are generally not older than this
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
    if (_selectedIssueDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select Issue Date.')),
      );
      return;
    }
    if (_selectedExpiryDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select Expiry Date.')),
      );
      return;
    }
    if (_selectedExpiryDate!.isBefore(_selectedIssueDate!)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Expiry Date cannot be before Issue Date.')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final visaData = Visa(
        id: _isEditMode ? widget.visaId : null,
        pilgrimId: widget.pilgrimId,
        visaNumber: _visaNumberController.text.trim(),
        issueDate: _selectedIssueDate!,
        expiryDate: _selectedExpiryDate!,
        type: _typeController.text.trim(),
        status: _selectedStatus!,
      );

      if (_isEditMode) {
        await _bookingService.updateVisa(widget.bookingId, widget.pilgrimId, visaData);
      } else {
        await _bookingService.addVisa(widget.bookingId, widget.pilgrimId, visaData);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Visa information ${_isEditMode ? 'updated' : 'added'} successfully!')),
        );
        Navigator.of(context).pop(true); // Pop and indicate success
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to ${_isEditMode ? 'update' : 'add'} visa: ${e.toString()}')),
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
        title: Text(_isEditMode ? 'Edit Visa Information' : 'Add Visa Information'),
      ),
      body: _isFetchingData
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    TextFormField(
                      controller: _visaNumberController,
                      decoration: const InputDecoration(labelText: 'Visa Number'),
                      validator: (value) => value == null || value.isEmpty ? 'Please enter visa number' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField( // Using TextFormField for Type for flexibility
                      controller: _typeController,
                      decoration: const InputDecoration(labelText: 'Visa Type (e.g., Umrah Visa)'),
                      validator: (value) => value == null || value.isEmpty ? 'Please enter visa type' : null,
                    ),
                    const SizedBox(height: 12),
                    _buildDatePickerField(
                      context: context,
                      labelText: 'Issue Date',
                      selectedDate: _selectedIssueDate,
                      onDateSelected: (date) => setState(() => _selectedIssueDate = date),
                    ),
                    const SizedBox(height: 12),
                    _buildDatePickerField(
                      context: context,
                      labelText: 'Expiry Date',
                      selectedDate: _selectedExpiryDate,
                      onDateSelected: (date) => setState(() => _selectedExpiryDate = date),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: _selectedStatus,
                      decoration: const InputDecoration(labelText: 'Status'),
                      items: _statuses.map((String status) {
                        return DropdownMenuItem<String>(
                          value: status,
                          child: Text(status),
                        );
                      }).toList(),
                      onChanged: (newValue) {
                        setState(() {
                          _selectedStatus = newValue;
                        });
                      },
                      validator: (value) => value == null ? 'Please select status' : null,
                    ),
                    const SizedBox(height: 24),
                    if (_isLoading)
                      const Center(child: CircularProgressIndicator())
                    else
                      ElevatedButton(
                        onPressed: _submitForm,
                        child: Text(_isEditMode ? 'Update Visa' : 'Save Visa'),
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
