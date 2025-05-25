import 'package:cloud_firestore/cloud_firestore.dart'; // For Timestamp
import 'package:flutter/foundation.dart'; // For @required or general utilities

class Booking {
  final String? id;
  final String packageId;
  final String packageName; // Denormalized
  final String userId;
  final DateTime bookingDate;
  final double totalPrice;
  final double? downPaymentMade;
  final List<String> pilgrims; // List of pilgrim IDs
  final String status; // e.g., "Pending", "Confirmed", "Cancelled"

  Booking({
    this.id,
    required this.packageId,
    required this.packageName,
    required this.userId,
    required this.bookingDate,
    required this.totalPrice,
    this.downPaymentMade,
    required this.pilgrims,
    required this.status,
  });

  Booking copyWith({
    String? id,
    String? packageId,
    String? packageName,
    String? userId,
    DateTime? bookingDate,
    double? totalPrice,
    double? downPaymentMade,
    List<String>? pilgrims,
    String? status,
  }) {
    return Booking(
      id: id ?? this.id,
      packageId: packageId ?? this.packageId,
      packageName: packageName ?? this.packageName,
      userId: userId ?? this.userId,
      bookingDate: bookingDate ?? this.bookingDate,
      totalPrice: totalPrice ?? this.totalPrice,
      downPaymentMade: downPaymentMade ?? this.downPaymentMade,
      pilgrims: pilgrims ?? this.pilgrims,
      status: status ?? this.status,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'packageId': packageId,
      'packageName': packageName,
      'userId': userId,
      'bookingDate': Timestamp.fromDate(bookingDate), // Convert DateTime to Timestamp
      'totalPrice': totalPrice,
      'downPaymentMade': downPaymentMade,
      'pilgrims': pilgrims,
      'status': status,
    };
  }

  factory Booking.fromJson(Map<String, dynamic> json, String documentId) {
    return Booking(
      id: documentId,
      packageId: json['packageId'] as String,
      packageName: json['packageName'] as String,
      userId: json['userId'] as String,
      bookingDate: (json['bookingDate'] as Timestamp).toDate(), // Convert Timestamp to DateTime
      totalPrice: (json['totalPrice'] as num).toDouble(),
      downPaymentMade: (json['downPaymentMade'] as num?)?.toDouble(),
      pilgrims: List<String>.from(json['pilgrims'] as List<dynamic>),
      status: json['status'] as String,
    );
  }

  @override
  String toString() {
    return 'Booking(id: $id, packageId: $packageId, packageName: $packageName, userId: $userId, bookingDate: $bookingDate, status: $status)';
  }
}
