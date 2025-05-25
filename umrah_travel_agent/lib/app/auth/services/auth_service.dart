import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart'; // For kDebugMode

class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  // Register with email, password, and update display name
  Future<UserCredential?> registerWithEmailAndPassword(
      String email, String password, String name) async {
    try {
      UserCredential userCredential = await _firebaseAuth
          .createUserWithEmailAndPassword(email: email, password: password);
      
      // Update display name
      if (userCredential.user != null) {
        await userCredential.user!.updateDisplayName(name);
        // Reload the user to get the updated information
        await userCredential.user!.reload(); 
        // It's good practice to return the user credential with the updated user
        // However, the User object within userCredential might not be automatically updated
        // The most reliable way is to get the currentUser after reload
        // For simplicity, we return the original credential, but be mindful of this.
      }
      if (kDebugMode) {
        print('Registration successful for: ${userCredential.user?.email}, name: ${userCredential.user?.displayName}');
      }
      return userCredential;
    } on FirebaseAuthException catch (e) {
      if (kDebugMode) {
        print('Firebase Auth Exception during registration: ${e.message}');
        print('Error code: ${e.code}');
      }
      // Depending on the error, you might want to throw specific exceptions
      // or return a custom error object. For now, returning null.
      return null;
    } catch (e) {
      if (kDebugMode) {
        print('An unexpected error occurred during registration: $e');
      }
      return null;
    }
  }

  // Sign in with email and password
  Future<UserCredential?> signInWithEmailAndPassword(
      String email, String password) async {
    try {
      UserCredential userCredential = await _firebaseAuth
          .signInWithEmailAndPassword(email: email, password: password);
      if (kDebugMode) {
        print('Sign-in successful for: ${userCredential.user?.email}');
      }
      return userCredential;
    } on FirebaseAuthException catch (e) {
      if (kDebugMode) {
        print('Firebase Auth Exception during sign-in: ${e.message}');
        print('Error code: ${e.code}');
      }
      return null;
    } catch (e) {
      if (kDebugMode) {
        print('An unexpected error occurred during sign-in: $e');
      }
      return null;
    }
  }

  // Send password reset email
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
      if (kDebugMode) {
        print('Password reset email sent to: $email');
      }
    } on FirebaseAuthException catch (e) {
      if (kDebugMode) {
        print('Firebase Auth Exception during password reset: ${e.message}');
        print('Error code: ${e.code}');
      }
      // You might want to throw an exception or return a boolean status
    } catch (e) {
      if (kDebugMode) {
        print('An unexpected error occurred during password reset: $e');
      }
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _firebaseAuth.signOut();
      if (kDebugMode) {
        print('User signed out successfully.');
      }
    } on FirebaseAuthException catch (e) {
      if (kDebugMode) {
        print('Firebase Auth Exception during sign-out: ${e.message}');
        print('Error code: ${e.code}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('An unexpected error occurred during sign-out: $e');
      }
    }
  }

  // Get current user (optional, but often useful)
  User? getCurrentUser() {
    return _firebaseAuth.currentUser;
  }

  // Auth state changes stream (optional, for listening to auth state)
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();
}
