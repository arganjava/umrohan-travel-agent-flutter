import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For date formatting
import '../services/booking_service.dart';
import '../models/booking_model.dart';
import 'add_booking_screen.dart'; // Placeholder for adding new bookings
// import 'booking_details_screen.dart'; // Will be created next

class BookingsListScreen extends StatefulWidget {
  const BookingsListScreen({super.key});

  @override
  State<BookingsListScreen> createState() => _BookingsListScreenState();
}

class _BookingsListScreenState extends State<BookingsListScreen> {
  final BookingService _bookingService = BookingService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('All Bookings'),
      ),
      body: StreamBuilder<List<Booking>>(
        stream: _bookingService.getBookings(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
                child: Text('No bookings available yet.'));
          }

          final bookings = snapshot.data!;

          return ListView.builder(
            itemCount: bookings.length,
            itemBuilder: (context, index) {
              final booking = bookings[index];
              final formattedDate = DateFormat('dd MMM yyyy, HH:mm').format(booking.bookingDate);
              return ListTile(
                title: Text(booking.packageName),
                subtitle: Text(
                    'Date: $formattedDate - Status: ${booking.status}'),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  if (booking.id != null) {
                    print('Navigate to details for booking ID: ${booking.id}');
                    // Navigator.of(context).push(
                    //   MaterialPageRoute(
                    //     builder: (context) => BookingDetailsScreen(bookingId: booking.id!),
                    //   ),
                    // );
                  } else {
                     print('Error: Booking ID is null for ${booking.packageName}');
                     ScaffoldMessenger.of(context).showSnackBar(
                       SnackBar(content: Text('Error: Booking ID is missing for ${booking.packageName}.')),
                     );
                  }
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const AddBookingScreen()),
          );
        },
        tooltip: 'Add Booking',
        child: const Icon(Icons.add),
      ),
    );
  }
}
