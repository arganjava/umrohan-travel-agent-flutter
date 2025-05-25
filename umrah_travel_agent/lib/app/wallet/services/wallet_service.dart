import 'packagepackage:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart'; // For kDebugMode

import '../models/wallet_model.dart';
import '../models/wallet_transaction_model.dart';

class WalletService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  late final CollectionReference _walletsCollection;

  WalletService() {
    _walletsCollection = _firestore.collection('wallets');
  }

  String? get currentUserId => _auth.currentUser?.uid;

  // --- Wallet Methods ---

  Future<void> createWallet(String userId, {double initialBalance = 0}) async {
    try {
      final wallet = Wallet(
        id: userId,
        balance: initialBalance,
        lastTransactionDate: null, // No transactions yet
      );
      await _walletsCollection.doc(userId).set(wallet.toJson());
      if (kDebugMode) {
        print('Wallet created for user $userId with initial balance $initialBalance');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error creating wallet for user $userId: $e');
      }
      rethrow;
    }
  }

  Future<Wallet?> getWallet([String? userId]) async {
    final targetUserId = userId ?? currentUserId;
    if (targetUserId == null) {
      if (kDebugMode) print('User ID is null, cannot fetch wallet.');
      return null;
    }

    try {
      DocumentSnapshot doc = await _walletsCollection.doc(targetUserId).get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>?;
        return data != null ? Wallet.fromJson(data, doc.id) : null;
      } else {
        // Wallet doesn't exist, create one with default balance
        if (kDebugMode) print('Wallet not found for user $targetUserId. Creating one.');
        await createWallet(targetUserId);
        // Fetch the newly created wallet
        doc = await _walletsCollection.doc(targetUserId).get();
         if (doc.exists) {
            final data = doc.data() as Map<String, dynamic>?;
            return data != null ? Wallet.fromJson(data, doc.id) : null;
         }
         return null; // Should not happen if creation was successful
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error getting wallet for user $targetUserId: $e');
      }
      return null; // Or rethrow depending on desired error handling
    }
  }

  Stream<Wallet?> getWalletStream([String? userId]) {
    final targetUserId = userId ?? currentUserId;
    if (targetUserId == null) {
      if (kDebugMode) print('User ID is null, cannot fetch wallet stream.');
      return Stream.value(null); // Or Stream.error()
    }

    return _walletsCollection.doc(targetUserId).snapshots().asyncMap((doc) async {
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>?;
        return data != null ? Wallet.fromJson(data, doc.id) : null;
      } else {
         // Wallet doesn't exist, create one.
        if (kDebugMode) print('Wallet not found in stream for user $targetUserId. Creating one.');
        try {
          await createWallet(targetUserId);
          // After creation, Firestore listener should pick up the new document.
          // However, the current snapshot is for a non-existent doc.
          // We return a default wallet or null for this emission, subsequent emissions will have the created wallet.
          // For more immediate reflection, one might need to re-trigger the stream or use a different pattern.
          // For simplicity, Firestore's own update mechanism will eventually provide the created wallet.
          // Let's return a Wallet object directly after creation for this specific emission.
          return Wallet(id: targetUserId, balance: 0, lastTransactionDate: null);

        } catch (e) {
          if (kDebugMode) print('Error creating wallet from stream for $targetUserId: $e');
          return null; // Error during creation
        }
      }
    }).handleError((error) {
      if (kDebugMode) {
        print('Error in wallet stream for user $targetUserId: $error');
      }
      return null; // Or rethrow
    });
  }
  
  // Private method to update wallet balance and last transaction date.
  // IMPORTANT: This method is NOT transactional by itself.
  // For production, ensure this is called within a Firestore transaction
  // or use Cloud Functions with transactions for robust balance updates.
  Future<void> _updateWalletBalance(String userId, double newBalance, DateTime transactionDate) async {
    if (userId.isEmpty) {
       if (kDebugMode) print('User ID is empty, cannot update wallet balance.');
       throw ArgumentError('User ID cannot be empty for updating balance.');
    }
    try {
      await _walletsCollection.doc(userId).update({
        'balance': newBalance,
        'lastTransactionDate': Timestamp.fromDate(transactionDate),
      });
      if (kDebugMode) {
        print('Wallet balance updated for user $userId to $newBalance');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error updating wallet balance for user $userId: $e');
      }
      rethrow;
    }
  }


  // --- Wallet Transaction Methods ---

  CollectionReference _transactionsCollection(String walletId) {
    if (walletId.isEmpty) {
      throw ArgumentError("Wallet ID cannot be empty when getting transactions collection.");
    }
    return _walletsCollection.doc(walletId).collection('transactions');
  }

  // IMPORTANT: This implementation of addTransaction is NOT a true Firestore transaction.
  // It involves multiple separate operations (read wallet, write transaction, update wallet).
  // This can lead to race conditions and data inconsistency under concurrent operations.
  // For production, this MUST be implemented as an atomic Firestore transaction
  // or handled by a Cloud Function that performs the transaction.
  Future<void> addTransaction(WalletTransaction transaction) async {
    if (transaction.walletId.isEmpty) {
      if (kDebugMode) print('Wallet ID in transaction is empty.');
      throw ArgumentError('Wallet ID in transaction cannot be empty.');
    }

    try {
      // 1. Add the transaction document first
      final transactionRef = await _transactionsCollection(transaction.walletId).add(transaction.toJson());
      if (kDebugMode) {
        print('Transaction ${transactionRef.id} added for wallet ${transaction.walletId}');
      }

      // 2. Read the current wallet
      // Note: Using getWallet which might create a default wallet if none exists.
      // This might not be desired if a transaction is for a non-existent wallet.
      // Consider if a wallet MUST exist before a transaction can be added.
      final currentWallet = await getWallet(transaction.walletId);
      
      if (currentWallet == null) {
        // This case should ideally be handled based on business logic.
        // If getWallet creates a wallet, this might mean the creation failed or there's an issue.
        // If getWallet doesn't create, then this means the wallet doesn't exist.
        if (kDebugMode) print('Wallet not found for ID ${transaction.walletId} after attempting to get/create it. Cannot update balance.');
        throw Exception('Wallet not found for ID ${transaction.walletId}, cannot update balance.');
      }

      // 3. Calculate the new balance
      // Amount is positive for deposits/refunds, negative for withdrawals/payouts
      final newBalance = currentWallet.balance + transaction.amount;

      // 4. Update the wallet document with the new balance and last transaction date
      // This uses the _updateWalletBalance method which is not transactional.
      await _updateWalletBalance(transaction.walletId, newBalance, transaction.date);
      
      if (kDebugMode) {
        print('Wallet ${transaction.walletId} balance updated to $newBalance after transaction ${transactionRef.id}');
      }

    } catch (e) {
      if (kDebugMode) {
        print('Error adding transaction and updating wallet for walletId ${transaction.walletId}: $e');
      }
      rethrow; // Rethrow to allow UI to handle
    }
  }


  Stream<List<WalletTransaction>> getTransactions([String? userId, int limit = 50]) {
    final targetUserId = userId ?? currentUserId;
    if (targetUserId == null) {
      if (kDebugMode) print('User ID is null, cannot fetch transactions.');
      return Stream.value([]); // Or Stream.error()
    }

    return _transactionsCollection(targetUserId)
        .orderBy('date', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) {
      try {
        return snapshot.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>?;
          if (data == null) {
             if (kDebugMode) print('Skipping transaction document with ID ${doc.id} due to null data.');
            return null;
          }
          return WalletTransaction.fromJson(data, doc.id);
        }).where((transaction) => transaction != null).cast<WalletTransaction>().toList();
      } catch (e) {
        if (kDebugMode) print('Error mapping transactions for user $targetUserId: $e');
        return [];
      }
    }).handleError((error) {
      if (kDebugMode) print('Error in getTransactions stream for user $targetUserId: $error');
      return [];
    });
  }
}
