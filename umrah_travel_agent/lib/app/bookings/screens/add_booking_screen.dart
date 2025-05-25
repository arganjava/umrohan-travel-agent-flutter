import 'package:flutter/material.dart';

class AddBookingScreen extends StatelessWidget {
  const AddBookingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Booking'),
      ),
      body: const Center(
        child: Text('Add Booking Screen - Placeholder'),
      ),
    );
  }
}
