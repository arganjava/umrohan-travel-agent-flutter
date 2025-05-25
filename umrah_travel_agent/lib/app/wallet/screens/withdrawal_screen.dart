import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart'; // For currency formatting
import '../services/wallet_service.dart';
import '../models/wallet_model.dart';
import '../models/wallet_transaction_model.dart';

class WithdrawalScreen extends StatefulWidget {
  const WithdrawalScreen({super.key});

  @override
  State<WithdrawalScreen> createState() => _WithdrawalScreenState();
}

class _WithdrawalScreenState extends State<WithdrawalScreen> {
  final WalletService _walletService = WalletService();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _isFetchingBalance = true; // For initial balance load
  double _currentBalance = 0.0;

  // TextEditingControllers
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _bankAccountDetailsController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchWalletBalance();
  }

  Future<void> _fetchWalletBalance() async {
    setState(() {
      _isFetchingBalance = true;
    });
    final String? currentUserId = _auth.currentUser?.uid;
    if (currentUserId == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error: User not logged in.')),
        );
        setState(() {
          _isFetchingBalance = false;
        });
      }
      return;
    }
    try {
      final wallet = await _walletService.getWallet(currentUserId);
      if (mounted && wallet != null) {
        setState(() {
          _currentBalance = wallet.balance;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error fetching balance: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isFetchingBalance = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _bankAccountDetailsController.dispose();
    super.dispose();
  }

  Future<void> _submitWithdrawalRequest() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final String? currentUserId = _auth.currentUser?.uid;
    if (currentUserId == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error: User not logged in. Please log in and try again.')),
        );
      }
      return;
    }
    
    final double requestedAmount = double.tryParse(_amountController.text.trim()) ?? 0.0;
    // Validation for amount against balance is already in the TextFormField validator.

    setState(() {
      _isLoading = true;
    });

    try {
      // Amount stored as negative for withdrawal requests as per instruction
      final transaction = WalletTransaction(
        walletId: currentUserId,
        type: "WITHDRAWAL_REQUEST",
        amount: -requestedAmount, // Storing as negative
        date: DateTime.now(),
        description: "Withdrawal Request to: ${_bankAccountDetailsController.text.trim()}",
        status: "Pending",
      );

      await _walletService.addTransaction(transaction);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Withdrawal request submitted successfully.')),
        );
        // Refresh balance after submission
        await _fetchWalletBalance(); 
        if (mounted) Navigator.of(context).pop(true); // Pop and indicate success
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to submit withdrawal request: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(locale: 'en_US', symbol: '\$');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Request Withdrawal'),
      ),
      body: _isFetchingBalance 
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Text(
                      'Current Balance: ${currencyFormat.format(_currentBalance)}',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _amountController,
                      decoration: const InputDecoration(
                        labelText: 'Withdrawal Amount',
                        prefixText: '\$ ',
                      ),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter the amount';
                        }
                        final double? amount = double.tryParse(value);
                        if (amount == null) {
                          return 'Please enter a valid number';
                        }
                        if (amount <= 0) {
                          return 'Amount must be greater than zero';
                        }
                        if (amount > _currentBalance) {
                          return 'Amount exceeds current balance';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _bankAccountDetailsController,
                      decoration: const InputDecoration(
                        labelText: 'Bank Account Details',
                        hintText: 'e.g., Bank Name, Account Number, SWIFT/BIC',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter bank account details';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),
                    if (_isLoading)
                      const Center(child: CircularProgressIndicator())
                    else
                      ElevatedButton(
                        onPressed: _submitWithdrawalRequest,
                        child: const Text('Submit Withdrawal Request'),
                      ),
                  ],
                ),
              ),
            ),
    );
  }
}
