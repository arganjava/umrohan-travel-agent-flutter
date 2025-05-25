import 'package:flutter/material.dart';
import '../services/package_service.dart';
import '../models/package_model.dart';
import 'add_package_screen.dart'; 
import 'edit_package_screen.dart'; // Import the new edit screen

class PackagesListScreen extends StatefulWidget {
  const PackagesListScreen({super.key});

  @override
  State<PackagesListScreen> createState() => _PackagesListScreenState();
}

class _PackagesListScreenState extends State<PackagesListScreen> {
  final PackageService _packageService = PackageService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Umrah Packages'),
      ),
      body: StreamBuilder<List<UmrahPackage>>(
        stream: _packageService.getPackages(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
                child: Text('No packages available. Add one!'));
          }

          final packages = snapshot.data!;

          return ListView.builder(
            itemCount: packages.length,
            itemBuilder: (context, index) {
              final package = packages[index];
              return ListTile(
                title: Text(package.name),
                subtitle: Text(
                    'Price: \$${package.price.toStringAsFixed(2)} - Duration: ${package.duration}'),
                trailing: IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () {
                    if (package.id != null) {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => EditPackageScreen(package: package),
                        ),
                      );
                    } else {
                      // This case should ideally not happen if data is consistent
                      ScaffoldMessenger.of(context).showSnackBar(
                         SnackBar(content: Text('Error: Package ID is null for ${package.name}. Cannot edit.')),
                      );
                      print('Error: Package ID is null for ${package.name}');
                    }
                  },
                ),
                // You can add an onTap for navigating to a package details screen as well
                onTap: () {
                  // Navigation to PackageDetailsScreen (placeholder)
                   print('View package details for: ${package.name}');
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const AddPackageScreen()),
          );
        },
        tooltip: 'Add Package',
        child: const Icon(Icons.add),
      ),
    );
  }
}
