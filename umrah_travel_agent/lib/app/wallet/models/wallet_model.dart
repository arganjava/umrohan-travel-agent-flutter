import 'package:cloud_firestore/cloud_firestore.dart'; // For Timestamp
import 'package:flutter/foundation.dart'; // For @required or general utilities

class Wallet {
  final String id; // Should be the same as the userId of the agent
  final double balance;
  final DateTime? lastTransactionDate;

  Wallet({
    required this.id,
    required this.balance,
    this.lastTransactionDate,
  });

  Wallet copyWith({
    String? id,
    double? balance,
    DateTime? lastTransactionDate,
    bool setLastTransactionDateToNull = false, // To explicitly set it to null
  }) {
    return Wallet(
      id: id ?? this.id,
      balance: balance ?? this.balance,
      lastTransactionDate: setLastTransactionDateToNull 
          ? null 
          : (lastTransactionDate ?? this.lastTransactionDate),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      // 'id' is the document ID, so it's not typically stored as a field within the document itself.
      // However, if you choose to store it, it would be: 'id': id,
      'balance': balance,
      'lastTransactionDate': lastTransactionDate != null 
          ? Timestamp.fromDate(lastTransactionDate!) 
          : null,
    };
  }

  factory Wallet.fromJson(Map<String, dynamic> json, String documentId) {
    return Wallet(
      id: documentId, // Use the document ID from Firestore as the wallet's ID
      balance: (json['balance'] as num).toDouble(),
      lastTransactionDate: (json['lastTransactionDate'] as Timestamp?)?.toDate(),
    );
  }

  @override
  String toString() {
    return 'Wallet(id: $id, balance: $balance, lastTransactionDate: $lastTransactionDate)';
  }
}
