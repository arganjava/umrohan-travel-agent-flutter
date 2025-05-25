import 'package:flutter/foundation.dart'; // For @required if using older Flutter versions, or for general utilities

class UmrahPackage {
  final String? id; // Firestore document ID
  final String name;
  final String description;
  final double price;
  final double minimalDownPayment;
  final String schedule; // For now, String. Can be DateTime later.
  final String itinerary; // For now, String. Can be List<String> or complex object.
  final int quota;
  final String duration; // e.g., "10 days"
  final List<String> facilities;
  final String? imageUrl;

  UmrahPackage({
    this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.minimalDownPayment,
    required this.schedule,
    required this.itinerary,
    required this.quota,
    required this.duration,
    required this.facilities,
    this.imageUrl,
  });

  // CopyWith method
  UmrahPackage copyWith({
    String? id,
    String? name,
    String? description,
    double? price,
    double? minimalDownPayment,
    String? schedule,
    String? itinerary,
    int? quota,
    String? duration,
    List<String>? facilities,
    String? imageUrl,
  }) {
    return UmrahPackage(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      minimalDownPayment: minimalDownPayment ?? this.minimalDownPayment,
      schedule: schedule ?? this.schedule,
      itinerary: itinerary ?? this.itinerary,
      quota: quota ?? this.quota,
      duration: duration ?? this.duration,
      facilities: facilities ?? this.facilities,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }

  // ToJson method for Firestore
  Map<String, dynamic> toJson() {
    return {
      // 'id' is typically not stored as a field in the document itself, 
      // but rather is the document's ID. So, it's often excluded here.
      'name': name,
      'description': description,
      'price': price,
      'minimalDownPayment': minimalDownPayment,
      'schedule': schedule,
      'itinerary': itinerary,
      'quota': quota,
      'duration': duration,
      'facilities': facilities,
      'imageUrl': imageUrl,
    };
  }

  // FromJson factory constructor
  factory UmrahPackage.fromJson(Map<String, dynamic> json, String documentId) {
    return UmrahPackage(
      id: documentId,
      name: json['name'] as String,
      description: json['description'] as String,
      price: (json['price'] as num).toDouble(), // Firestore might store numbers as num
      minimalDownPayment: (json['minimalDownPayment'] as num).toDouble(),
      schedule: json['schedule'] as String,
      itinerary: json['itinerary'] as String,
      quota: json['quota'] as int,
      duration: json['duration'] as String,
      facilities: List<String>.from(json['facilities'] as List<dynamic>),
      imageUrl: json['imageUrl'] as String?,
    );
  }

  // For debugging purposes
  @override
  String toString() {
    return 'UmrahPackage(id: $id, name: $name, price: $price, quota: $quota, duration: $duration)';
  }
}
