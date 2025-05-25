import 'package:cloud_firestore/cloud_firestore.dart'; // For Timestamp
import 'package:flutter/foundation.dart'; // For @required or general utilities

class Visa {
  final String? id;
  final String pilgrimId;
  final String visaNumber;
  final DateTime issueDate;
  final DateTime expiryDate;
  final String type; // e.g., "Umrah Visa", "Tourist Visa"
  final String status; // e.g., "Applied", "Approved", "Rejected"

  Visa({
    this.id,
    required this.pilgrimId,
    required this.visaNumber,
    required this.issueDate,
    required this.expiryDate,
    required this.type,
    required this.status,
  });

  Visa copyWith({
    String? id,
    String? pilgrimId,
    String? visaNumber,
    DateTime? issueDate,
    DateTime? expiryDate,
    String? type,
    String? status,
  }) {
    return Visa(
      id: id ?? this.id,
      pilgrimId: pilgrimId ?? this.pilgrimId,
      visaNumber: visaNumber ?? this.visaNumber,
      issueDate: issueDate ?? this.issueDate,
      expiryDate: expiryDate ?? this.expiryDate,
      type: type ?? this.type,
      status: status ?? this.status,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'pilgrimId': pilgrimId,
      'visaNumber': visaNumber,
      'issueDate': Timestamp.fromDate(issueDate),
      'expiryDate': Timestamp.fromDate(expiryDate),
      'type': type,
      'status': status,
    };
  }

  factory Visa.fromJson(Map<String, dynamic> json, String documentId) {
    return Visa(
      id: documentId,
      pilgrimId: json['pilgrimId'] as String,
      visaNumber: json['visaNumber'] as String,
      issueDate: (json['issueDate'] as Timestamp).toDate(),
      expiryDate: (json['expiryDate'] as Timestamp).toDate(),
      type: json['type'] as String,
      status: json['status'] as String,
    );
  }

  @override
  String toString() {
    return 'Visa(id: $id, pilgrimId: $pilgrimId, visaNumber: $visaNumber, status: $status)';
  }
}
