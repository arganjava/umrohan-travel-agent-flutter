import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart'; // For kDebugMode
import '../models/package_model.dart';

class PackageService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late final CollectionReference _packagesCollection;

  PackageService() {
    _packagesCollection = _firestore.collection('packages');
  }

  // Add a new UmrahPackage
  Future<void> addPackage(UmrahPackage package) async {
    try {
      // The toJson method in UmrahPackage should exclude the ID
      await _packagesCollection.add(package.toJson());
      if (kDebugMode) {
        print('Package added successfully: ${package.name}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error adding package: $e');
      }
      // Optionally rethrow or handle more gracefully
    }
  }

  // Update an existing UmrahPackage
  Future<void> updatePackage(UmrahPackage package) async {
    if (package.id == null) {
      if (kDebugMode) {
        print('Error: Package ID is null, cannot update.');
      }
      return; // Or throw an error
    }
    try {
      await _packagesCollection.doc(package.id).update(package.toJson());
      if (kDebugMode) {
        print('Package updated successfully: ${package.id}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error updating package ${package.id}: $e');
      }
    }
  }

  // Delete an UmrahPackage by its ID
  Future<void> deletePackage(String packageId) async {
    try {
      await _packagesCollection.doc(packageId).delete();
      if (kDebugMode) {
        print('Package deleted successfully: $packageId');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error deleting package $packageId: $e');
      }
    }
  }

  // Get a stream of all UmrahPackages
  Stream<List<UmrahPackage>> getPackages() {
    return _packagesCollection.snapshots().map((snapshot) {
      try {
        return snapshot.docs.map((doc) {
          // Ensure data is not null and is of the correct type
          final data = doc.data() as Map<String, dynamic>?;
          if (data == null) {
            // Handle cases where data might be null if a document is malformed or empty
            // This might involve logging an error or skipping the document
            if (kDebugMode) {
              print('Skipping document with ID ${doc.id} due to null data.');
            }
            return null; 
          }
          return UmrahPackage.fromJson(data, doc.id);
        }).where((package) => package != null).cast<UmrahPackage>().toList(); // Filter out nulls before casting
      } catch (e) {
        if (kDebugMode) {
          print('Error mapping packages from snapshot: $e');
        }
        return []; // Return empty list on error
      }
    }).handleError((error) {
      // Handle errors from the stream itself (e.g., permission issues)
      if (kDebugMode) {
        print('Error in getPackages stream: $error');
      }
      return []; // Return an empty list or rethrow
    });
  }

  // Get a single UmrahPackage by its ID
  Future<UmrahPackage?> getPackageById(String packageId) async {
    try {
      DocumentSnapshot doc = await _packagesCollection.doc(packageId).get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>?;
        if (data != null) {
           return UmrahPackage.fromJson(data, doc.id);
        } else {
          if (kDebugMode) {
            print('Document ${doc.id} exists but data is null.');
          }
          return null;
        }
      } else {
        if (kDebugMode) {
          print('Package not found with ID: $packageId');
        }
        return null;
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error getting package by ID $packageId: $e');
      }
      return null;
    }
  }
}
