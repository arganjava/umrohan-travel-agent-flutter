import 'package:cloud_firestore/cloud_firestore.dart'; // For Timestamp
import 'package:flutter/foundation.dart'; // For @required or general utilities

class WalletTransaction {
  final String? id; // Firestore document ID
  final String walletId; // same as userId
  final String type; // e.g., "DEPOSIT", "WITHDRAWAL", "REFUND", "PAYOUT"
  final double amount; // positive for deposits/refunds, negative for withdrawals/payouts
  final DateTime date;
  final String? description;
  final String? status; // e.g., "Pending", "Completed", "Failed"

  WalletTransaction({
    this.id,
    required this.walletId,
    required this.type,
    required this.amount,
    required this.date,
    this.description,
    this.status,
  });

  WalletTransaction copyWith({
    String? id,
    String? walletId,
    String? type,
    double? amount,
    DateTime? date,
    String? description,
    String? status,
    bool setDescriptionToNull = false,
    bool setStatusToNull = false,
  }) {
    return WalletTransaction(
      id: id ?? this.id,
      walletId: walletId ?? this.walletId,
      type: type ?? this.type,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      description: setDescriptionToNull ? null : (description ?? this.description),
      status: setStatusToNull ? null : (status ?? this.status),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'walletId': walletId,
      'type': type,
      'amount': amount,
      'date': Timestamp.fromDate(date),
      'description': description,
      'status': status,
    };
  }

  factory WalletTransaction.fromJson(Map<String, dynamic> json, String documentId) {
    return WalletTransaction(
      id: documentId,
      walletId: json['walletId'] as String,
      type: json['type'] as String,
      amount: (json['amount'] as num).toDouble(),
      date: (json['date'] as Timestamp).toDate(),
      description: json['description'] as String?,
      status: json['status'] as String?,
    );
  }

  @override
  String toString() {
    return 'WalletTransaction(id: $id, walletId: $walletId, type: $type, amount: $amount, date: $date, status: $status)';
  }
}
