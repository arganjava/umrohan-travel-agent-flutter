import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For date formatting

import '../services/booking_service.dart';
import '../models/booking_model.dart';
import '../models/pilgrim_model.dart';
import 'add_pilgrim_screen.dart';
import 'pilgrim_details_screen.dart';

class BookingDetailsScreen extends StatefulWidget {
  final String bookingId;

  const BookingDetailsScreen({super.key, required this.bookingId});

  @override
  State<BookingDetailsScreen> createState() => _BookingDetailsScreenState();
}

class _BookingDetailsScreenState extends State<BookingDetailsScreen> {
  final BookingService _bookingService = BookingService();
  Future<Booking?>? _bookingFuture;

  @override
  void initState() {
    super.initState();
    _bookingFuture = _bookingService.getBookingById(widget.bookingId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Booking Details'),
      ),
      body: FutureBuilder<Booking?>(
        future: _bookingFuture,
        builder: (context, bookingSnapshot) {
          if (bookingSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (bookingSnapshot.hasError) {
            return Center(child: Text('Error loading booking: ${bookingSnapshot.error}'));
          }
          if (!bookingSnapshot.hasData || bookingSnapshot.data == null) {
            return const Center(child: Text('Booking not found.'));
          }

          final booking = bookingSnapshot.data!;
          final formattedDate = DateFormat('dd MMM yyyy, HH:mm').format(booking.bookingDate);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Card(
                  elevation: 4.0,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        Text('Package: ${booking.packageName}', style: Theme.of(context).textTheme.titleLarge),
                        const SizedBox(height: 8),
                        Text('Booking Date: $formattedDate', style: Theme.of(context).textTheme.titleMedium),
                        const SizedBox(height: 8),
                        Text('Total Price: \$${booking.totalPrice.toStringAsFixed(2)}', style: Theme.of(context).textTheme.titleMedium),
                        const SizedBox(height: 8),
                        Text('Status: ${booking.status}', style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: booking.status == 'Confirmed' ? Colors.green : (booking.status == 'Pending' ? Colors.orange : Colors.red)
                        )),
                        if (booking.downPaymentMade != null) ...[
                           const SizedBox(height: 8),
                           Text('Down Payment: \$${booking.downPaymentMade!.toStringAsFixed(2)}', style: Theme.of(context).textTheme.titleMedium),
                        ]
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Pilgrims',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const Divider(),
                StreamBuilder<List<Pilgrim>>(
                  stream: _bookingService.getPilgrims(widget.bookingId),
                  builder: (context, pilgrimSnapshot) {
                    if (pilgrimSnapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (pilgrimSnapshot.hasError) {
                      return Center(child: Text('Error loading pilgrims: ${pilgrimSnapshot.error}'));
                    }
                    if (!pilgrimSnapshot.hasData || pilgrimSnapshot.data!.isEmpty) {
                      return const Center(child: Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text('No pilgrims added to this booking yet.'),
                      ));
                    }

                    final pilgrims = pilgrimSnapshot.data!;
                    return ListView.builder(
                      shrinkWrap: true, // Important for ListView inside SingleChildScrollView
                      physics: const NeverScrollableScrollPhysics(), // Disable scrolling for inner list
                      itemCount: pilgrims.length,
                      itemBuilder: (context, index) {
                        final pilgrim = pilgrims[index];
                        return ListTile(
                          title: Text(pilgrim.fullName),
                          subtitle: Text('Status: ${pilgrim.status}'),
                          trailing: const Icon(Icons.arrow_forward_ios),
                          onTap: () {
                            if (pilgrim.id != null) {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => PilgrimDetailsScreen(
                                    bookingId: widget.bookingId,
                                    pilgrimId: pilgrim.id!,
                                  ),
                                ),
                              );
                            } else {
                               ScaffoldMessenger.of(context).showSnackBar(
                                 SnackBar(content: Text('Error: Pilgrim ID is missing for ${pilgrim.fullName}.')),
                               );
                            }
                          },
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => AddPilgrimScreen(bookingId: widget.bookingId),
            ),
          );
        },
        tooltip: 'Add Pilgrim',
        child: const Icon(Icons.person_add),
      ),
    );
  }
}
