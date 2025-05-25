import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For date formatting
import '../services/booking_service.dart';
import '../models/flight_ticket_model.dart';

class ManageFlightTicketScreen extends StatefulWidget {
  final String bookingId;
  final String pilgrimId;
  final String? flightTicketId; // Nullable for adding new

  const ManageFlightTicketScreen({
    super.key,
    required this.bookingId,
    required this.pilgrimId,
    this.flightTicketId,
  });

  @override
  State<ManageFlightTicketScreen> createState() => _ManageFlightTicketScreenState();
}

class _ManageFlightTicketScreenState extends State<ManageFlightTicketScreen> {
  final BookingService _bookingService = BookingService();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  late bool _isEditMode;
  FlightTicket? _existingFlightTicket;

  // TextEditingControllers
  final TextEditingController _airlineController = TextEditingController();
  final TextEditingController _flightNumberController = TextEditingController();
  final TextEditingController _departureAirportController = TextEditingController();
  final TextEditingController _arrivalAirportController = TextEditingController();
  final TextEditingController _ticketNumberController = TextEditingController();
  final TextEditingController _bookingReferenceController = TextEditingController();
  
  // For DropdownButtonFormField (Status)
  String? _selectedStatus;
  final List<String> _statuses = ['Booked', 'Confirmed', 'Cancelled', 'Pending'];


  // For DateTime fields
  DateTime? _selectedDepartureDateTime;
  DateTime? _selectedArrivalDateTime;

  @override
  void initState() {
    super.initState();
    _isEditMode = widget.flightTicketId != null;
    if (_isEditMode) {
      _loadExistingFlightTicket();
    } else {
      _selectedStatus = 'Pending'; // Default for new tickets
    }
  }

  Future<void> _loadExistingFlightTicket() async {
    setState(() {
      _isLoading = true;
    });
    try {
      _existingFlightTicket = await _bookingService.getFlightTicketById(
        widget.bookingId,
        widget.pilgrimId,
        widget.flightTicketId!,
      );
      if (_existingFlightTicket != null) {
        _airlineController.text = _existingFlightTicket!.airline;
        _flightNumberController.text = _existingFlightTicket!.flightNumber;
        _departureAirportController.text = _existingFlightTicket!.departureAirport;
        _arrivalAirportController.text = _existingFlightTicket!.arrivalAirport;
        _ticketNumberController.text = _existingFlightTicket!.ticketNumber ?? '';
        _bookingReferenceController.text = _existingFlightTicket!.bookingReference ?? '';
        _selectedStatus = _existingFlightTicket!.status;
        _selectedDepartureDateTime = _existingFlightTicket!.departureDateTime;
        _selectedArrivalDateTime = _existingFlightTicket!.arrivalDateTime;
      } else {
         if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Failed to load existing flight ticket details.')),
            );
         }
      }
    } catch (e) {
       if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error loading ticket: ${e.toString()}')),
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
  void dispose() {
    _airlineController.dispose();
    _flightNumberController.dispose();
    _departureAirportController.dispose();
    _arrivalAirportController.dispose();
    _ticketNumberController.dispose();
    _bookingReferenceController.dispose();
    super.dispose();
  }

  Future<void> _selectDateTime(
    BuildContext context, 
    Function(DateTime) onDateTimeSelected, 
    DateTime? initialDate
  ) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (pickedDate == null) return;

    if (!mounted) return; // Check if the widget is still in the tree

    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initialDate ?? DateTime.now()),
    );
    if (pickedTime == null) return;

    onDateTimeSelected(DateTime(
      pickedDate.year,
      pickedDate.month,
      pickedDate.day,
      pickedTime.hour,
      pickedTime.minute,
    ));
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
     if (_selectedDepartureDateTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select Departure Date & Time.')),
      );
      return;
    }
    if (_selectedArrivalDateTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select Arrival Date & Time.')),
      );
      return;
    }
    if (_selectedArrivalDateTime!.isBefore(_selectedDepartureDateTime!)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Arrival time cannot be before departure time.')),
      );
      return;
    }


    setState(() {
      _isLoading = true;
    });

    try {
      final flightTicketData = FlightTicket(
        id: _isEditMode ? widget.flightTicketId : null,
        pilgrimId: widget.pilgrimId,
        airline: _airlineController.text.trim(),
        flightNumber: _flightNumberController.text.trim(),
        departureAirport: _departureAirportController.text.trim(),
        arrivalAirport: _arrivalAirportController.text.trim(),
        departureDateTime: _selectedDepartureDateTime!,
        arrivalDateTime: _selectedArrivalDateTime!,
        ticketNumber: _ticketNumberController.text.trim().isEmpty ? null : _ticketNumberController.text.trim(),
        bookingReference: _bookingReferenceController.text.trim().isEmpty ? null : _bookingReferenceController.text.trim(),
        status: _selectedStatus!,
      );

      if (_isEditMode) {
        await _bookingService.updateFlightTicket(widget.bookingId, widget.pilgrimId, flightTicketData);
      } else {
        await _bookingService.addFlightTicket(widget.bookingId, widget.pilgrimId, flightTicketData);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Flight ticket ${_isEditMode ? 'updated' : 'added'} successfully!')),
        );
        Navigator.of(context).pop(true); // Pop and indicate success
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to ${_isEditMode ? 'update' : 'add'} flight ticket: ${e.toString()}')),
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
        title: Text(_isEditMode ? 'Edit Flight Ticket' : 'Add Flight Ticket'),
      ),
      body: _isLoading && _isEditMode && _existingFlightTicket == null // Show loader only if editing and data isn't loaded yet
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    TextFormField(
                      controller: _airlineController,
                      decoration: const InputDecoration(labelText: 'Airline'),
                      validator: (value) => value == null || value.isEmpty ? 'Please enter airline' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _flightNumberController,
                      decoration: const InputDecoration(labelText: 'Flight Number'),
                      validator: (value) => value == null || value.isEmpty ? 'Please enter flight number' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _departureAirportController,
                      decoration: const InputDecoration(labelText: 'Departure Airport (e.g., JED)'),
                      validator: (value) => value == null || value.isEmpty ? 'Please enter departure airport' : null,
                    ),
                     const SizedBox(height: 12),
                    TextFormField(
                      controller: _arrivalAirportController,
                      decoration: const InputDecoration(labelText: 'Arrival Airport (e.g., MED)'),
                      validator: (value) => value == null || value.isEmpty ? 'Please enter arrival airport' : null,
                    ),
                    const SizedBox(height: 12),
                    _buildDateTimePickerField(
                      context: context,
                      labelText: 'Departure Date & Time',
                      selectedDateTime: _selectedDepartureDateTime,
                      onDateTimeSelected: (dateTime) => setState(() => _selectedDepartureDateTime = dateTime),
                    ),
                    const SizedBox(height: 12),
                    _buildDateTimePickerField(
                      context: context,
                      labelText: 'Arrival Date & Time',
                      selectedDateTime: _selectedArrivalDateTime,
                      onDateTimeSelected: (dateTime) => setState(() => _selectedArrivalDateTime = dateTime),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _ticketNumberController,
                      decoration: const InputDecoration(labelText: 'Ticket Number (Optional)'),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _bookingReferenceController,
                      decoration: const InputDecoration(labelText: 'Booking Reference (Optional)'),
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
                        child: Text(_isEditMode ? 'Update Flight Ticket' : 'Add Flight Ticket'),
                      ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildDateTimePickerField({
    required BuildContext context,
    required String labelText,
    required DateTime? selectedDateTime,
    required Function(DateTime) onDateTimeSelected,
  }) {
    return TextFormField(
      decoration: InputDecoration(
        labelText: labelText,
        suffixIcon: const Icon(Icons.calendar_today),
      ),
      readOnly: true,
      controller: TextEditingController(
        text: selectedDateTime == null ? '' : DateFormat('dd MMM yyyy, HH:mm').format(selectedDateTime),
      ),
      onTap: () => _selectDateTime(context, onDateTimeSelected, selectedDateTime),
       validator: (value) { 
        if (selectedDateTime == null) { 
          return 'Please select $labelText';
        }
        return null;
      },
    );
  }
}
