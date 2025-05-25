import 'package:cloud_firestore/cloud_firestore.dart'; // For Timestamp
import 'package:flutter/foundation.dart'; // For @required or general utilities

class Pilgrim {
  final String? id;
  final String bookingId;
  final String fullName;
  final String gender;
  final DateTime dateOfBirth;
  final String passportNumber;
  final DateTime passportExpiryDate;
  final String nationality;
  final String? contactNumber;
  final String? email;
  final String status; // e.g., "Application Received", "Visa Processing", "Confirmed", "Cancelled"
  final String? flightTicketId;
  final String? visaId;
  final List<String>? luggageInfoIds;

  Pilgrim({
    this.id,
    required this.bookingId,
    required this.fullName,
    required this.gender,
    required this.dateOfBirth,
    required this.passportNumber,
    required this.passportExpiryDate,
    required this.nationality,
    this.contactNumber,
    this.email,
    required this.status,
    this.flightTicketId,
    this.visaId,
    this.luggageInfoIds,
  });

  Pilgrim copyWith({
    String? id,
    String? bookingId,
    String? fullName,
    String? gender,
    DateTime? dateOfBirth,
    String? passportNumber,
    DateTime? passportExpiryDate,
    String? nationality,
    String? contactNumber,
    String? email,
    String? status,
    String? flightTicketId,
    String? visaId,
    List<String>? luggageInfoIds,
  }) {
    return Pilgrim(
      id: id ?? this.id,
      bookingId: bookingId ?? this.bookingId,
      fullName: fullName ?? this.fullName,
      gender: gender ?? this.gender,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      passportNumber: passportNumber ?? this.passportNumber,
      passportExpiryDate: passportExpiryDate ?? this.passportExpiryDate,
      nationality: nationality ?? this.nationality,
      contactNumber: contactNumber ?? this.contactNumber,
      email: email ?? this.email,
      status: status ?? this.status,
      flightTicketId: flightTicketId ?? this.flightTicketId,
      visaId: visaId ?? this.visaId,
      luggageInfoIds: luggageInfoIds ?? this.luggageInfoIds,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'bookingId': bookingId,
      'fullName': fullName,
      'gender': gender,
      'dateOfBirth': Timestamp.fromDate(dateOfBirth),
      'passportNumber': passportNumber,
      'passportExpiryDate': Timestamp.fromDate(passportExpiryDate),
      'nationality': nationality,
      'contactNumber': contactNumber,
      'email': email,
      'status': status,
      'flightTicketId': flightTicketId,
      'visaId': visaId,
      'luggageInfoIds': luggageInfoIds,
    };
  }

  factory Pilgrim.fromJson(Map<String, dynamic> json, String documentId) {
    return Pilgrim(
      id: documentId,
      bookingId: json['bookingId'] as String,
      fullName: json['fullName'] as String,
      gender: json['gender'] as String,
      dateOfBirth: (json['dateOfBirth'] as Timestamp).toDate(),
      passportNumber: json['passportNumber'] as String,
      passportExpiryDate: (json['passportExpiryDate'] as Timestamp).toDate(),
      nationality: json['nationality'] as String,
      contactNumber: json['contactNumber'] as String?,
      email: json['email'] as String?,
      status: json['status'] as String,
      flightTicketId: json['flightTicketId'] as String?,
      visaId: json['visaId'] as String?,
      luggageInfoIds: json['luggageInfoIds'] != null
          ? List<String>.from(json['luggageInfoIds'] as List<dynamic>)
          : null,
    );
  }

  @override
  String toString() {
    return 'Pilgrim(id: $id, fullName: $fullName, bookingId: $bookingId, status: $status)';
  }
}
