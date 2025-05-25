import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart'; // For kDebugMode

import '../models/bank_account_model.dart';

class AccountService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  late final CollectionReference _bankAccountsCollection;

  AccountService() {
    _bankAccountsCollection = _firestore.collection('bank_accounts');
  }

  String? get currentUserId => _auth.currentUser?.uid;

  // --- BankAccount Methods ---

  Future<void> saveBankAccount(BankAccount account) async {
    final targetUserId = account.id; // Assuming account.id is the userId
    
    if (targetUserId.isEmpty) {
      if (kDebugMode) print('Error: User ID (account.id) is empty. Cannot save bank account.');
      throw ArgumentError('User ID (account.id) cannot be empty when saving a bank account.');
    }
    if (targetUserId != currentUserId && currentUserId != null) {
        // This check might be relevant if you want to restrict an agent
        // from saving bank account details for another agent.
        // For now, we allow saving based on account.id, assuming it's correctly set.
        if (kDebugMode) print('Warning: Saving bank account for a User ID (${account.id}) that might not be the current user ($currentUserId). Ensure this is intended.');
    }


    try {
      // Using account.id as the document ID, which should match the userId
      await _bankAccountsCollection.doc(account.id).set(account.toJson());
      if (kDebugMode) {
        print('Bank account saved successfully for user ${account.id}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error saving bank account for user ${account.id}: $e');
      }
      rethrow;
    }
  }

  Future<BankAccount?> getBankAccount([String? userId]) async {
    final targetUserId = userId ?? currentUserId;
    if (targetUserId == null) {
      if (kDebugMode) print('User ID is null, cannot fetch bank account.');
      return null;
    }

    try {
      DocumentSnapshot doc = await _bankAccountsCollection.doc(targetUserId).get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>?;
        return data != null ? BankAccount.fromJson(data, doc.id) : null;
      } else {
        if (kDebugMode) print('Bank account not found for user $targetUserId.');
        return null; // No bank account found
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error getting bank account for user $targetUserId: $e');
      }
      return null;
    }
  }

  Stream<BankAccount?> getBankAccountStream([String? userId]) {
    final targetUserId = userId ?? currentUserId;
    if (targetUserId == null) {
      if (kDebugMode) print('User ID is null, cannot fetch bank account stream.');
      return Stream.value(null);
    }

    return _bankAccountsCollection.doc(targetUserId).snapshots().map((doc) {
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>?;
         return data != null ? BankAccount.fromJson(data, doc.id) : null;
      } else {
        if (kDebugMode) print('Bank account not found in stream for user $targetUserId.');
        return null;
      }
    }).handleError((error) {
      if (kDebugMode) {
        print('Error in bank account stream for user $targetUserId: $error');
      }
      return null;
    });
  }

  Future<void> deleteBankAccount([String? userId]) async {
    final targetUserId = userId ?? currentUserId;
    if (targetUserId == null) {
      if (kDebugMode) print('User ID is null, cannot delete bank account.');
      throw ArgumentError('User ID must be provided to delete a bank account.');
    }

    try {
      await _bankAccountsCollection.doc(targetUserId).delete();
      if (kDebugMode) {
        print('Bank account deleted successfully for user $targetUserId');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error deleting bank account for user $targetUserId: $e');
      }
      rethrow;
    }
  }
}
