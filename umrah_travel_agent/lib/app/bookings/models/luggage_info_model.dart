import 'package:flutter/foundation.dart'; // For @required or general utilities

class LuggageInfo {
  final String? id;
  final String pilgrimId; // Or bookingId if luggage is per booking rather than per pilgrim
  final String type; // e.g., "Checked Bag", "Carry-on"
  final double weight; // in kg
  final int quantity;
  final String? tagNumber;

  LuggageInfo({
    this.id,
    required this.pilgrimId,
    required this.type,
    required this.weight,
    required this.quantity,
    this.tagNumber,
  });

  LuggageInfo copyWith({
    String? id,
    String? pilgrimId,
    String? type,
    double? weight,
    int? quantity,
    String? tagNumber,
  }) {
    return LuggageInfo(
      id: id ?? this.id,
      pilgrimId: pilgrimId ?? this.pilgrimId,
      type: type ?? this.type,
      weight: weight ?? this.weight,
      quantity: quantity ?? this.quantity,
      tagNumber: tagNumber ?? this.tagNumber,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'pilgrimId': pilgrimId,
      'type': type,
      'weight': weight,
      'quantity': quantity,
      'tagNumber': tagNumber,
    };
  }

  factory LuggageInfo.fromJson(Map<String, dynamic> json, String documentId) {
    return LuggageInfo(
      id: documentId,
      pilgrimId: json['pilgrimId'] as String,
      type: json['type'] as String,
      weight: (json['weight'] as num).toDouble(),
      quantity: json['quantity'] as int,
      tagNumber: json['tagNumber'] as String?,
    );
  }

  @override
  String toString() {
    return 'LuggageInfo(id: $id, pilgrimId: $pilgrimId, type: $type, quantity: $quantity)';
  }
}
