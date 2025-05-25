import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/account_service.dart';
import '../models/bank_account_model.dart';

class ManageBankAccountScreen extends StatefulWidget {
  const ManageBankAccountScreen({super.key});

  @override
  State<ManageBankAccountScreen> createState() => _ManageBankAccountScreenState();
}

class _ManageBankAccountScreenState extends State<ManageBankAccountScreen> {
  final AccountService _accountService = AccountService();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final _formKey = GlobalKey<FormState>();

  BankAccount? _bankAccount;
  bool _isLoading = true; // True for initial data load and during submissions
  bool _isEditMode = false;

  // TextEditingControllers
  final TextEditingController _bankNameController = TextEditingController();
  final TextEditingController _accountHolderNameController = TextEditingController();
  final TextEditingController _accountNumberController = TextEditingController();
  final TextEditingController _branchCodeController = TextEditingController();
  final TextEditingController _countryController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadBankAccountData();
  }

  Future<void> _loadBankAccountData() async {
    setState(() {
      _isLoading = true;
    });
    final String? currentUserId = _auth.currentUser?.uid;
    if (currentUserId == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User not logged in. Cannot load bank account.')),
        );
        setState(() {
          _isLoading = false;
        });
      }
      return;
    }

    try {
      _bankAccount = await _accountService.getBankAccount(currentUserId);
      if (mounted && _bankAccount != null) {
        _bankNameController.text = _bankAccount!.bankName;
        _accountHolderNameController.text = _bankAccount!.accountHolderName;
        _accountNumberController.text = _bankAccount!.accountNumber;
        _branchCodeController.text = _bankAccount!.branchCode ?? '';
        _countryController.text = _bankAccount!.country;
        setState(() {
          _isEditMode = true;
        });
      } else {
         setState(() {
          _isEditMode = false;
        });
         // Optionally clear fields if no account exists or was deleted prior
        _clearFormFields();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading bank account: ${e.toString()}')),
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
  
  void _clearFormFields() {
    _bankNameController.clear();
    _accountHolderNameController.clear();
    _accountNumberController.clear();
    _branchCodeController.clear();
    _countryController.clear();
  }


  Future<void> _saveBankAccount() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final String? currentUserId = _auth.currentUser?.uid;
    if (currentUserId == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User not logged in. Cannot save bank account.')),
        );
      }
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final bankAccount = BankAccount(
        id: currentUserId, // ID is the current user's ID
        bankName: _bankNameController.text.trim(),
        accountHolderName: _accountHolderNameController.text.trim(),
        accountNumber: _accountNumberController.text.trim(),
        branchCode: _branchCodeController.text.trim().isEmpty ? null : _branchCodeController.text.trim(),
        country: _countryController.text.trim(),
      );

      await _accountService.saveBankAccount(bankAccount);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Bank account saved successfully!')),
        );
        _loadBankAccountData(); // Reload data to reflect changes and update _isEditMode
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save bank account: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        // _isLoading is already set by _loadBankAccountData if called
        // but if _loadBankAccountData wasn't called (e.g. error before it), ensure it's false
        if (_isLoading) { 
            setState(() { _isLoading = false; });
        }
      }
    }
  }

  Future<void> _deleteBankAccount() async {
    final String? currentUserId = _auth.currentUser?.uid;
    if (currentUserId == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User not logged in. Cannot delete bank account.')),
        );
      }
      return;
    }

    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Delete Bank Account?'),
          content: const Text("Are you sure you want to delete your bank account details? This action cannot be undone."),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(dialogContext).pop(false),
            ),
            TextButton(
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Delete'),
              onPressed: () => Navigator.of(dialogContext).pop(true),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      setState(() {
        _isLoading = true;
      });
      try {
        await _accountService.deleteBankAccount(currentUserId);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Bank account deleted successfully.')),
          );
          _clearFormFields();
          setState(() {
            _isEditMode = false;
            _bankAccount = null; 
          });
          // _loadBankAccountData(); // Or simply reset state, as data is now null
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to delete bank account: ${e.toString()}')),
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
  }


  @override
  void dispose() {
    _bankNameController.dispose();
    _accountHolderNameController.dispose();
    _accountNumberController.dispose();
    _branchCodeController.dispose();
    _countryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Bank Account'),
      ),
      body: _isLoading && _bankAccount == null && !_isEditMode // Show loader on initial load if no data yet
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    TextFormField(
                      controller: _bankNameController,
                      decoration: const InputDecoration(labelText: 'Bank Name'),
                      validator: (value) => value == null || value.isEmpty ? 'Please enter bank name' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _accountHolderNameController,
                      decoration: const InputDecoration(labelText: 'Account Holder Name'),
                      validator: (value) => value == null || value.isEmpty ? 'Please enter account holder name' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _accountNumberController,
                      decoration: const InputDecoration(labelText: 'Account Number'),
                      validator: (value) => value == null || value.isEmpty ? 'Please enter account number' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _branchCodeController,
                      decoration: const InputDecoration(labelText: 'Branch Code / SWIFT / BIC (Optional)'),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _countryController,
                      decoration: const InputDecoration(labelText: 'Country'),
                      validator: (value) => value == null || value.isEmpty ? 'Please enter country' : null,
                    ),
                    const SizedBox(height: 24),
                    if (_isLoading && (_bankAccount != null || _isEditMode)) // Show loader inline with button if submitting
                      const Center(child: Padding(padding: EdgeInsets.all(8.0), child: CircularProgressIndicator()))
                    else
                      ElevatedButton(
                        onPressed: _isLoading ? null : _saveBankAccount, // Disable button when loading
                        child: const Text('Save Bank Account'),
                      ),
                    if (_isEditMode && !_isLoading) // Show delete button only in edit mode and not when loading
                      TextButton(
                        onPressed: _deleteBankAccount,
                        style: TextButton.styleFrom(foregroundColor: Colors.red),
                        child: const Text('Delete Bank Account'),
                      ),
                  ],
                ),
              ),
            ),
    );
  }
}
