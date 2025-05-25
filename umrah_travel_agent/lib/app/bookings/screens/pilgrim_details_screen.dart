import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For date formatting

import '../services/booking_service.dart';
import '../models/pilgrim_model.dart';
import '../models/flight_ticket_model.dart';
import '../models/visa_model.dart';
import '../models/luggage_info_model.dart';

import 'manage_flight_ticket_screen.dart';
import 'manage_visa_screen.dart';
import 'add_luggage_screen.dart';
import 'edit_pilgrim_screen.dart';


class PilgrimDetailsScreen extends StatefulWidget {
  final String bookingId;
  final String pilgrimId;

  const PilgrimDetailsScreen({
    super.key,
    required this.bookingId,
    required this.pilgrimId,
  });

  @override
  State<PilgrimDetailsScreen> createState() => _PilgrimDetailsScreenState();
}

class _PilgrimDetailsScreenState extends State<PilgrimDetailsScreen> {
  final BookingService _bookingService = BookingService();
  Future<Pilgrim?>? _pilgrimFuture;

  @override
  void initState() {
    super.initState();
    _loadPilgrimData();
  }

  void _loadPilgrimData() {
    _pilgrimFuture = _bookingService.getPilgrimById(widget.bookingId, widget.pilgrimId);
  }

  void _refreshPilgrimData() {
    setState(() {
      _loadPilgrimData();
    });
  }


  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Text(
        title,
        style: Theme.of(context).textTheme.headlineSmall,
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context, Pilgrim pilgrim) {
    final dateFormat = DateFormat('dd MMM yyyy');
    return Card(
      elevation: 4.0,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text('Name: ${pilgrim.fullName}', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text('Gender: ${pilgrim.gender}'),
            Text('Date of Birth: ${dateFormat.format(pilgrim.dateOfBirth)}'),
            Text('Passport No: ${pilgrim.passportNumber}'),
            Text('Passport Expiry: ${dateFormat.format(pilgrim.passportExpiryDate)}'),
            Text('Nationality: ${pilgrim.nationality}'),
            if (pilgrim.contactNumber != null) Text('Contact: ${pilgrim.contactNumber}'),
            if (pilgrim.email != null) Text('Email: ${pilgrim.email}'),
            const SizedBox(height: 8),
            Text('Status: ${pilgrim.status}', style: TextStyle(
              fontWeight: FontWeight.bold,
              color: pilgrim.status == 'Confirmed' ? Colors.green : (pilgrim.status == 'Visa Processing' ? Colors.blue : Colors.orange)
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildFlightTicketSection(BuildContext context, Pilgrim pilgrim) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(context, 'Flight Ticket'),
        StreamBuilder<List<FlightTicket>>(
          stream: _bookingService.getFlightTickets(widget.bookingId, widget.pilgrimId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Text('Error loading flight ticket: ${snapshot.error}');
            }
            final tickets = snapshot.data ?? [];
            final ticket = tickets.isNotEmpty ? tickets.first : null;

            if (ticket == null) {
              return Center(
                child: ElevatedButton(
                  child: const Text('Add Flight Ticket'),
                  onPressed: () async {
                    await Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => ManageFlightTicketScreen(
                        bookingId: widget.bookingId,
                        pilgrimId: widget.pilgrimId,
                      ),
                    ));
                    _refreshPilgrimData(); // Refresh data after potential add/edit
                  },
                ),
              );
            }
            final dateFormat = DateFormat('dd MMM yyyy, HH:mm');
            return Card(
              child: ListTile(
                title: Text('${ticket.airline} - ${ticket.flightNumber}'),
                subtitle: Text(
                    'Dep: ${ticket.departureAirport} at ${dateFormat.format(ticket.departureDateTime)}\n'
                    'Arr: ${ticket.arrivalAirport} at ${dateFormat.format(ticket.arrivalDateTime)}\n'
                    'Status: ${ticket.status}'),
                trailing: IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () async {
                     await Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => ManageFlightTicketScreen(
                        bookingId: widget.bookingId,
                        pilgrimId: widget.pilgrimId,
                        flightTicketId: ticket.id,
                      ),
                    ));
                    _refreshPilgrimData();
                  },
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildVisaSection(BuildContext context, Pilgrim pilgrim) {
     return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(context, 'Visa Information'),
        StreamBuilder<List<Visa>>(
          stream: _bookingService.getVisas(widget.bookingId, widget.pilgrimId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Text('Error loading visa information: ${snapshot.error}');
            }
            final visas = snapshot.data ?? [];
            final visa = visas.isNotEmpty ? visas.first : null;

            if (visa == null) {
              return Center(
                child: ElevatedButton(
                  child: const Text('Add Visa Information'),
                  onPressed: () async {
                    await Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => ManageVisaScreen(
                        bookingId: widget.bookingId,
                        pilgrimId: widget.pilgrimId,
                      ),
                    ));
                     _refreshPilgrimData();
                  },
                ),
              );
            }
            final dateFormat = DateFormat('dd MMM yyyy');
            return Card(
              child: ListTile(
                title: Text('Visa No: ${visa.visaNumber} (${visa.type})'),
                subtitle: Text(
                    'Issue Date: ${dateFormat.format(visa.issueDate)}\n'
                    'Expiry Date: ${dateFormat.format(visa.expiryDate)}\n'
                    'Status: ${visa.status}'),
                trailing: IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () async {
                    await Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => ManageVisaScreen(
                        bookingId: widget.bookingId,
                        pilgrimId: widget.pilgrimId,
                        visaId: visa.id,
                      ),
                    ));
                    _refreshPilgrimData();
                  },
                ),
              ),
            );
          },
        ),
      ],
    );
  }

   Widget _buildLuggageSection(BuildContext context, Pilgrim pilgrim) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(context, 'Luggage'),
        StreamBuilder<List<LuggageInfo>>(
          stream: _bookingService.getLuggageInfos(widget.bookingId, widget.pilgrimId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Text('Error loading luggage information: ${snapshot.error}');
            }
            final luggageList = snapshot.data ?? [];

            if (luggageList.isEmpty) {
              return const Center(child: Text('No luggage information added.'));
            }
            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: luggageList.length,
              itemBuilder: (context, index) {
                final luggage = luggageList[index];
                return Card(
                  child: ListTile(
                    title: Text('${luggage.quantity} x ${luggage.type} (${luggage.weight} kg)'),
                    subtitle: luggage.tagNumber != null ? Text('Tag: ${luggage.tagNumber}') : null,
                    // Optionally add edit/delete for luggage items if needed
                  ),
                );
              },
            );
          },
        ),
         const SizedBox(height: 10),
        Center(
          child: ElevatedButton(
            child: const Text('Add Luggage Item'),
            onPressed: () async {
              await Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => AddLuggageScreen(
                  bookingId: widget.bookingId,
                  pilgrimId: widget.pilgrimId,
                ),
              ));
              _refreshPilgrimData(); // Potentially refresh if list is displayed directly
            },
          ),
        ),
      ],
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pilgrim Details'),
      ),
      body: FutureBuilder<Pilgrim?>(
        future: _pilgrimFuture,
        builder: (context, pilgrimSnapshot) {
          if (pilgrimSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (pilgrimSnapshot.hasError) {
            return Center(child: Text('Error loading pilgrim details: ${pilgrimSnapshot.error}'));
          }
          if (!pilgrimSnapshot.hasData || pilgrimSnapshot.data == null) {
            return const Center(child: Text('Pilgrim not found.'));
          }

          final pilgrim = pilgrimSnapshot.data!;

          return RefreshIndicator(
            onRefresh: () async {
              _refreshPilgrimData();
            },
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  _buildInfoCard(context, pilgrim),
                  _buildFlightTicketSection(context, pilgrim),
                  _buildVisaSection(context, pilgrim),
                  _buildLuggageSection(context, pilgrim),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FutureBuilder<Pilgrim?>(
         future: _pilgrimFuture, // Ensure FAB only builds if pilgrim data is available
         builder: (context, pilgrimSnapshot) {
            if (pilgrimSnapshot.hasData && pilgrimSnapshot.data != null) {
              return FloatingActionButton(
                onPressed: () async {
                  await Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => EditPilgrimScreen(
                        bookingId: widget.bookingId,
                        pilgrim: pilgrimSnapshot.data!,
                      ),
                    ),
                  );
                  _refreshPilgrimData(); // Refresh pilgrim data after editing
                },
                tooltip: 'Edit Pilgrim',
                child: const Icon(Icons.edit),
              );
            }
            return const SizedBox.shrink(); // Return empty if no pilgrim data for FAB
         }
      )
    );
  }
}
