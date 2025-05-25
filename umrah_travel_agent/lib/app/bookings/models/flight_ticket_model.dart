import 'package:cloud_firestore/cloud_firestore.dart'; // For Timestamp
import 'package:flutter/foundation.dart'; // For @required or general utilities

class FlightTicket {
  final String? id;
  final String pilgrimId;
  final String airline;
  final String flightNumber;
  final String departureAirport;
  final String arrivalAirport;
  final DateTime departureDateTime;
  final DateTime arrivalDateTime;
  final String? ticketNumber;
  final String? bookingReference;
  final String status; // e.g., "Booked", "Confirmed", "Cancelled"

  FlightTicket({
    this.id,
    required this.pilgrimId,
    required this.airline,
    required this.flightNumber,
    required this.departureAirport,
    required this.arrivalAirport,
    required this.departureDateTime,
    required this.arrivalDateTime,
    this.ticketNumber,
    this.bookingReference,
    required this.status,
  });

  FlightTicket copyWith({
    String? id,
    String? pilgrimId,
    String? airline,
    String? flightNumber,
    String? departureAirport,
    String? arrivalAirport,
    DateTime? departureDateTime,
    DateTime? arrivalDateTime,
    String? ticketNumber,
    String? bookingReference,
    String? status,
  }) {
    return FlightTicket(
      id: id ?? this.id,
      pilgrimId: pilgrimId ?? this.pilgrimId,
      airline: airline ?? this.airline,
      flightNumber: flightNumber ?? this.flightNumber,
      departureAirport: departureAirport ?? this.departureAirport,
      arrivalAirport: arrivalAirport ?? this.arrivalAirport,
      departureDateTime: departureDateTime ?? this.departureDateTime,
      arrivalDateTime: arrivalDateTime ?? this.arrivalDateTime,
      ticketNumber: ticketNumber ?? this.ticketNumber,
      bookingReference: bookingReference ?? this.bookingReference,
      status: status ?? this.status,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'pilgrimId': pilgrimId,
      'airline': airline,
      'flightNumber': flightNumber,
      'departureAirport': departureAirport,
      'arrivalAirport': arrivalAirport,
      'departureDateTime': Timestamp.fromDate(departureDateTime),
      'arrivalDateTime': Timestamp.fromDate(arrivalDateTime),
      'ticketNumber': ticketNumber,
      'bookingReference': bookingReference,
      'status': status,
    };
  }

  factory FlightTicket.fromJson(Map<String, dynamic> json, String documentId) {
    return FlightTicket(
      id: documentId,
      pilgrimId: json['pilgrimId'] as String,
      airline: json['airline'] as String,
      flightNumber: json['flightNumber'] as String,
      departureAirport: json['departureAirport'] as String,
      arrivalAirport: json['arrivalAirport'] as String,
      departureDateTime: (json['departureDateTime'] as Timestamp).toDate(),
      arrivalDateTime: (json['arrivalDateTime'] as Timestamp).toDate(),
      ticketNumber: json['ticketNumber'] as String?,
      bookingReference: json['bookingReference'] as String?,
      status: json['status'] as String,
    );
  }

  @override
  String toString() {
    return 'FlightTicket(id: $id, pilgrimId: $pilgrimId, flightNumber: $flightNumber, status: $status)';
  }
}
