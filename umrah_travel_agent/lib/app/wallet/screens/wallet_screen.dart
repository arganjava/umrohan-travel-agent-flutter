import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart'; // For currency and date formatting

import '../services/wallet_service.dart';
import '../models/wallet_model.dart';
import '../models/wallet_transaction_model.dart';
import 'deposit_screen.dart'; // Placeholder
import 'withdrawal_screen.dart'; // Placeholder

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  final WalletService _walletService = WalletService();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? _currentUser;

  @override
  void initState() {
    super.initState();
    _currentUser = _auth.currentUser;
    // If currentUser is null, you might want to handle it here, e.g., by
    // navigating to a login screen, but for now, we'll let the build method handle it.
  }

  @override
  Widget build(BuildContext context) {
    if (_currentUser == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('My Wallet')),
        body: const Center(
          child: Text('Please log in to view your wallet.'),
        ),
      );
    }

    final currencyFormat = NumberFormat.currency(locale: 'en_US', symbol: '\$');
    final dateFormat = DateFormat('dd MMM yyyy, HH:mm');

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Wallet'),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          // Trigger a refresh of the streams by rebuilding the widget if necessary
          // For streams, this is often handled automatically by new data,
          // but if direct re-fetch is needed, service methods could be called.
          setState(() {
            // This will cause StreamBuilders to re-evaluate their streams
            // if the streams are dependent on something that changes here.
            // Or, you could call a specific refresh method in your service if designed so.
          });
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              // Balance Display
              StreamBuilder<Wallet?>(
                stream: _walletService.getWalletStream(_currentUser!.uid),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text('Error loading wallet: ${snapshot.error}'));
                  }
                  if (!snapshot.hasData || snapshot.data == null) {
                    return const Center(child: Text('Wallet not available.'));
                  }
                  final wallet = snapshot.data!;
                  return Card(
                    elevation: 4.0,
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        children: [
                          Text('Current Balance', style: Theme.of(context).textTheme.titleMedium),
                          const SizedBox(height: 8),
                          Text(
                            currencyFormat.format(wallet.balance),
                            style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
                          ),
                           if (wallet.lastTransactionDate != null) ...[
                            const SizedBox(height: 8),
                            Text(
                              'Last updated: ${dateFormat.format(wallet.lastTransactionDate!)}',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ]
                        ],
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),

              // Action Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  ElevatedButton.icon(
                    icon: const Icon(Icons.add_card),
                    label: const Text('Deposit'),
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (context) => const DepositScreen()),
                      );
                    },
                     style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                  ),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.remove_card),
                    label: const Text('Withdraw'),
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (context) => const WithdrawalScreen()),
                      );
                    },
                     style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Transaction List
              Text(
                'Recent Transactions',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const Divider(),
              StreamBuilder<List<WalletTransaction>>(
                stream: _walletService.getTransactions(_currentUser!.uid, 20), // Limit to 20 recent
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: CircularProgressIndicator(),
                    ));
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text('Error loading transactions: ${snapshot.error}'));
                  }
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text('No transactions found.'),
                    ));
                  }

                  final transactions = snapshot.data!;
                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(), // To disable scrolling within SingleChildScrollView
                    itemCount: transactions.length,
                    itemBuilder: (context, index) {
                      final transaction = transactions[index];
                      final isDeposit = transaction.amount >= 0; // Assuming positive for deposit/refund

                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 4.0),
                        child: ListTile(
                          leading: Icon(
                            isDeposit ? Icons.arrow_downward : Icons.arrow_upward,
                            color: isDeposit ? Colors.green : Colors.red,
                          ),
                          title: Text(transaction.type),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(transaction.description ?? 'N/A'),
                              Text(dateFormat.format(transaction.date)),
                            ],
                          ),
                          trailing: Text(
                            '${isDeposit ? '+' : ''}${currencyFormat.format(transaction.amount)}',
                            style: TextStyle(
                              color: isDeposit ? Colors.green : Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
