import 'package:flutter/foundation.dart'; // For @required or general utilities

// Note on Account Number Security:
// In a real application, sensitive data like accountNumber should be handled with
// extreme care. This might include:
// - Encrypting the data at rest in the database.
// - Using secure methods for transmitting this data.
// - Applying appropriate access controls and audit trails.
// - Potentially integrating with secure third-party payment processors or vault services
//   instead of storing raw account numbers directly.
// For this example, it's stored as a plain string, but this is NOT production-ready.

class BankAccount {
  final String id; // Assumed to be the same as the userId (agent's ID)
  final String bankName;
  final String accountHolderName;
  final String accountNumber; // See security note above
  final String? branchCode; // e.g., Swift/BIC, IFSC
  final String country;

  BankAccount({
    required this.id,
    required this.bankName,
    required this.accountHolderName,
    required this.accountNumber,
    this.branchCode,
    required this.country,
  });

  BankAccount copyWith({
    String? id,
    String? bankName,
    String? accountHolderName,
    String? accountNumber,
    String? branchCode,
    String? country,
    bool setBranchCodeToNull = false,
  }) {
    return BankAccount(
      id: id ?? this.id,
      bankName: bankName ?? this.bankName,
      accountHolderName: accountHolderName ?? this.accountHolderName,
      accountNumber: accountNumber ?? this.accountNumber,
      branchCode: setBranchCodeToNull ? null : (branchCode ?? this.branchCode),
      country: country ?? this.country,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      // 'id' is the document ID, not typically stored as a field if it's the same as doc ID.
      // If you intend for 'id' to be a field, uncomment the line below.
      // 'id': id, 
      'bankName': bankName,
      'accountHolderName': accountHolderName,
      'accountNumber': accountNumber, // See security note above
      'branchCode': branchCode,
      'country': country,
    };
  }

  factory BankAccount.fromJson(Map<String, dynamic> json, String documentId) {
    return BankAccount(
      id: documentId, // Using documentId as the primary ID for the BankAccount object
      bankName: json['bankName'] as String,
      accountHolderName: json['accountHolderName'] as String,
      accountNumber: json['accountNumber'] as String, // See security note above
      branchCode: json['branchCode'] as String?,
      country: json['country'] as String,
    );
  }

  @override
  String toString() {
    return 'BankAccount(id: $id, bankName: $bankName, accountHolderName: $accountHolderName, country: $country)';
  }
}
