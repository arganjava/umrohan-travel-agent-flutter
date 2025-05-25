import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart'; // For kDebugMode

import '../models/booking_model.dart';
import '../models/pilgrim_model.dart';
import '../models/flight_ticket_model.dart';
import '../models/visa_model.dart';
import '../models/luggage_info_model.dart';

class BookingService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  late final CollectionReference _bookingsCollection;

  BookingService() {
    _bookingsCollection = _firestore.collection('bookings');
  }

  // --- Booking Methods ---

  Future<DocumentReference> addBooking(Booking booking) async {
    try {
      DocumentReference docRef = await _bookingsCollection.add(booking.toJson());
      if (kDebugMode) {
        print('Booking added with ID: ${docRef.id}');
      }
      return docRef;
    } catch (e) {
      if (kDebugMode) {
        print('Error adding booking: $e');
      }
      rethrow; // Rethrow to allow UI to handle
    }
  }

  Future<void> updateBooking(Booking booking) async {
    if (booking.id == null) {
      if (kDebugMode) print('Error: Booking ID is null, cannot update.');
      throw ArgumentError('Booking ID cannot be null for update.');
    }
    try {
      await _bookingsCollection.doc(booking.id).update(booking.toJson());
      if (kDebugMode) {
        print('Booking updated successfully: ${booking.id}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error updating booking ${booking.id}: $e');
      }
      rethrow;
    }
  }

  /// Deletes a booking document.
  /// Note: This does NOT automatically delete subcollections (pilgrims, etc.).
  /// True cascading deletes are best handled by Firebase Functions.
  Future<void> deleteBooking(String bookingId) async {
    try {
      await _bookingsCollection.doc(bookingId).delete();
      if (kDebugMode) {
        print('Booking deleted successfully: $bookingId. Subcollections (pilgrims, etc.) are not automatically deleted.');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error deleting booking $bookingId: $e');
      }
      rethrow;
    }
  }

  Stream<List<Booking>> getBookings() {
    return _bookingsCollection.snapshots().map((snapshot) {
      try {
        return snapshot.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>?;
          if (data == null) {
            if (kDebugMode) print('Skipping booking document with ID ${doc.id} due to null data.');
            return null;
          }
          return Booking.fromJson(data, doc.id);
        }).where((booking) => booking != null).cast<Booking>().toList();
      } catch (e) {
        if (kDebugMode) print('Error mapping bookings from snapshot: $e');
        return [];
      }
    }).handleError((error) {
      if (kDebugMode) print('Error in getBookings stream: $error');
      return [];
    });
  }

  Stream<List<Booking>> getBookingsForPackage(String packageId) {
    return _bookingsCollection
        .where('packageId', isEqualTo: packageId)
        .snapshots()
        .map((snapshot) {
      try {
        return snapshot.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>?;
           if (data == null) return null;
          return Booking.fromJson(data, doc.id);
        }).where((booking) => booking != null).cast<Booking>().toList();
      } catch (e) {
        if (kDebugMode) print('Error mapping bookings for package $packageId: $e');
        return [];
      }
    }).handleError((error) {
      if (kDebugMode) print('Error in getBookingsForPackage stream: $error');
      return [];
    });
  }

  Stream<List<Booking>> getBookingsForUser(String userId) {
    return _bookingsCollection
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
      try {
        return snapshot.docs.map((doc) {
           final data = doc.data() as Map<String, dynamic>?;
           if (data == null) return null;
          return Booking.fromJson(data, doc.id);
        }).where((booking) => booking != null).cast<Booking>().toList();
      } catch (e) {
        if (kDebugMode) print('Error mapping bookings for user $userId: $e');
        return [];
      }
    }).handleError((error) {
      if (kDebugMode) print('Error in getBookingsForUser stream: $error');
      return [];
    });
  }

  Future<Booking?> getBookingById(String bookingId) async {
    try {
      DocumentSnapshot doc = await _bookingsCollection.doc(bookingId).get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>?;
        return data != null ? Booking.fromJson(data, doc.id) : null;
      } else {
        if (kDebugMode) print('Booking not found with ID: $bookingId');
        return null;
      }
    } catch (e) {
      if (kDebugMode) print('Error getting booking by ID $bookingId: $e');
      return null;
    }
  }

  // --- Pilgrim Methods ---

  CollectionReference _pilgrimsCollection(String bookingId) {
    return _bookingsCollection.doc(bookingId).collection('pilgrims');
  }

  Future<DocumentReference> addPilgrim(String bookingId, Pilgrim pilgrim) async {
    try {
      DocumentReference docRef = await _pilgrimsCollection(bookingId).add(pilgrim.toJson());
      if (kDebugMode) print('Pilgrim added with ID: ${docRef.id} to booking $bookingId');
      return docRef;
    } catch (e) {
      if (kDebugMode) print('Error adding pilgrim to booking $bookingId: $e');
      rethrow;
    }
  }

  Future<void> updatePilgrim(String bookingId, Pilgrim pilgrim) async {
    if (pilgrim.id == null) {
      if (kDebugMode) print('Error: Pilgrim ID is null, cannot update.');
      throw ArgumentError('Pilgrim ID cannot be null for update.');
    }
    try {
      await _pilgrimsCollection(bookingId).doc(pilgrim.id).update(pilgrim.toJson());
      if (kDebugMode) print('Pilgrim ${pilgrim.id} updated in booking $bookingId');
    } catch (e) {
      if (kDebugMode) print('Error updating pilgrim ${pilgrim.id} in booking $bookingId: $e');
      rethrow;
    }
  }
  
  /// Deletes a pilgrim document.
  /// Note: This does NOT automatically delete subcollections (flightTickets, visas, etc.).
  Future<void> deletePilgrim(String bookingId, String pilgrimId) async {
    try {
      await _pilgrimsCollection(bookingId).doc(pilgrimId).delete();
      if (kDebugMode) print('Pilgrim $pilgrimId deleted from booking $bookingId. Subcollections are not automatically deleted.');
    } catch (e) {
      if (kDebugMode) print('Error deleting pilgrim $pilgrimId from booking $bookingId: $e');
      rethrow;
    }
  }

  Stream<List<Pilgrim>> getPilgrims(String bookingId) {
    return _pilgrimsCollection(bookingId).snapshots().map((snapshot) {
      try {
        return snapshot.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>?;
          if (data == null) return null;
          return Pilgrim.fromJson(data, doc.id);
        }).where((p) => p != null).cast<Pilgrim>().toList();
      } catch (e) {
        if (kDebugMode) print('Error mapping pilgrims for booking $bookingId: $e');
        return [];
      }
    }).handleError((error) {
      if (kDebugMode) print('Error in getPilgrims stream for booking $bookingId: $error');
      return [];
    });
  }

  Future<Pilgrim?> getPilgrimById(String bookingId, String pilgrimId) async {
    try {
      DocumentSnapshot doc = await _pilgrimsCollection(bookingId).doc(pilgrimId).get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>?;
        return data != null ? Pilgrim.fromJson(data, doc.id) : null;
      } else {
        if (kDebugMode) print('Pilgrim $pilgrimId not found in booking $bookingId');
        return null;
      }
    } catch (e) {
      if (kDebugMode) print('Error getting pilgrim $pilgrimId from booking $bookingId: $e');
      return null;
    }
  }

  // --- FlightTicket Methods ---

  CollectionReference _flightTicketsCollection(String bookingId, String pilgrimId) {
    return _pilgrimsCollection(bookingId).doc(pilgrimId).collection('flightTickets');
  }

  Future<DocumentReference> addFlightTicket(String bookingId, String pilgrimId, FlightTicket ticket) async {
    try {
      DocumentReference docRef = await _flightTicketsCollection(bookingId, pilgrimId).add(ticket.toJson());
      if (kDebugMode) print('FlightTicket added with ID: ${docRef.id} for pilgrim $pilgrimId');
      return docRef;
    } catch (e) {
      if (kDebugMode) print('Error adding FlightTicket for pilgrim $pilgrimId: $e');
      rethrow;
    }
  }

  Future<void> updateFlightTicket(String bookingId, String pilgrimId, FlightTicket ticket) async {
    if (ticket.id == null) {
      if (kDebugMode) print('Error: FlightTicket ID is null, cannot update.');
      throw ArgumentError('FlightTicket ID cannot be null for update.');
    }
    try {
      await _flightTicketsCollection(bookingId, pilgrimId).doc(ticket.id).update(ticket.toJson());
      if (kDebugMode) print('FlightTicket ${ticket.id} updated for pilgrim $pilgrimId');
    } catch (e) {
      if (kDebugMode) print('Error updating FlightTicket ${ticket.id} for pilgrim $pilgrimId: $e');
      rethrow;
    }
  }

  Future<void> deleteFlightTicket(String bookingId, String pilgrimId, String ticketId) async {
    try {
      await _flightTicketsCollection(bookingId, pilgrimId).doc(ticketId).delete();
      if (kDebugMode) print('FlightTicket $ticketId deleted for pilgrim $pilgrimId');
    } catch (e) {
      if (kDebugMode) print('Error deleting FlightTicket $ticketId for pilgrim $pilgrimId: $e');
      rethrow;
    }
  }

  Stream<List<FlightTicket>> getFlightTickets(String bookingId, String pilgrimId) {
    return _flightTicketsCollection(bookingId, pilgrimId).snapshots().map((snapshot) {
      try {
        return snapshot.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>?;
          if (data == null) return null;
          return FlightTicket.fromJson(data, doc.id);
        }).where((t) => t != null).cast<FlightTicket>().toList();
      } catch (e) {
        if (kDebugMode) print('Error mapping FlightTickets for pilgrim $pilgrimId: $e');
        return [];
      }
    }).handleError((error) {
      if (kDebugMode) print('Error in getFlightTickets stream for pilgrim $pilgrimId: $error');
      return [];
    });
  }

  Future<FlightTicket?> getFlightTicketById(String bookingId, String pilgrimId, String ticketId) async {
    try {
      DocumentSnapshot doc = await _flightTicketsCollection(bookingId, pilgrimId).doc(ticketId).get();
      if (doc.exists) {
         final data = doc.data() as Map<String, dynamic>?;
        return data != null ? FlightTicket.fromJson(data, doc.id) : null;
      } else {
        if (kDebugMode) print('FlightTicket $ticketId not found for pilgrim $pilgrimId');
        return null;
      }
    } catch (e) {
      if (kDebugMode) print('Error getting FlightTicket $ticketId for pilgrim $pilgrimId: $e');
      return null;
    }
  }

  // --- Visa Methods ---

  CollectionReference _visasCollection(String bookingId, String pilgrimId) {
    return _pilgrimsCollection(bookingId).doc(pilgrimId).collection('visas');
  }

  Future<DocumentReference> addVisa(String bookingId, String pilgrimId, Visa visa) async {
    try {
      DocumentReference docRef = await _visasCollection(bookingId, pilgrimId).add(visa.toJson());
      if (kDebugMode) print('Visa added with ID: ${docRef.id} for pilgrim $pilgrimId');
      return docRef;
    } catch (e) {
      if (kDebugMode) print('Error adding Visa for pilgrim $pilgrimId: $e');
      rethrow;
    }
  }

  Future<void> updateVisa(String bookingId, String pilgrimId, Visa visa) async {
    if (visa.id == null) {
      if (kDebugMode) print('Error: Visa ID is null, cannot update.');
      throw ArgumentError('Visa ID cannot be null for update.');
    }
    try {
      await _visasCollection(bookingId, pilgrimId).doc(visa.id).update(visa.toJson());
      if (kDebugMode) print('Visa ${visa.id} updated for pilgrim $pilgrimId');
    } catch (e) {
      if (kDebugMode) print('Error updating Visa ${visa.id} for pilgrim $pilgrimId: $e');
      rethrow;
    }
  }

  Future<void> deleteVisa(String bookingId, String pilgrimId, String visaId) async {
    try {
      await _visasCollection(bookingId, pilgrimId).doc(visaId).delete();
      if (kDebugMode) print('Visa $visaId deleted for pilgrim $pilgrimId');
    } catch (e) {
      if (kDebugMode) print('Error deleting Visa $visaId for pilgrim $pilgrimId: $e');
      rethrow;
    }
  }

  Stream<List<Visa>> getVisas(String bookingId, String pilgrimId) {
    return _visasCollection(bookingId, pilgrimId).snapshots().map((snapshot) {
      try {
        return snapshot.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>?;
          if (data == null) return null;
          return Visa.fromJson(data, doc.id);
        }).where((v) => v != null).cast<Visa>().toList();
      } catch (e) {
        if (kDebugMode) print('Error mapping Visas for pilgrim $pilgrimId: $e');
        return [];
      }
    }).handleError((error) {
      if (kDebugMode) print('Error in getVisas stream for pilgrim $pilgrimId: $error');
      return [];
    });
  }

  Future<Visa?> getVisaById(String bookingId, String pilgrimId, String visaId) async {
    try {
      DocumentSnapshot doc = await _visasCollection(bookingId, pilgrimId).doc(visaId).get();
      if (doc.exists) {
         final data = doc.data() as Map<String, dynamic>?;
        return data != null ? Visa.fromJson(data, doc.id) : null;
      } else {
        if (kDebugMode) print('Visa $visaId not found for pilgrim $pilgrimId');
        return null;
      }
    } catch (e) {
      if (kDebugMode) print('Error getting Visa $visaId for pilgrim $pilgrimId: $e');
      return null;
    }
  }

  // --- LuggageInfo Methods ---

  CollectionReference _luggageInfosCollection(String bookingId, String pilgrimId) {
    return _pilgrimsCollection(bookingId).doc(pilgrimId).collection('luggageInfos');
  }

  Future<DocumentReference> addLuggageInfo(String bookingId, String pilgrimId, LuggageInfo luggage) async {
    try {
      DocumentReference docRef = await _luggageInfosCollection(bookingId, pilgrimId).add(luggage.toJson());
      if (kDebugMode) print('LuggageInfo added with ID: ${docRef.id} for pilgrim $pilgrimId');
      return docRef;
    } catch (e) {
      if (kDebugMode) print('Error adding LuggageInfo for pilgrim $pilgrimId: $e');
      rethrow;
    }
  }

  Future<void> updateLuggageInfo(String bookingId, String pilgrimId, LuggageInfo luggage) async {
    if (luggage.id == null) {
      if (kDebugMode) print('Error: LuggageInfo ID is null, cannot update.');
      throw ArgumentError('LuggageInfo ID cannot be null for update.');
    }
    try {
      await _luggageInfosCollection(bookingId, pilgrimId).doc(luggage.id).update(luggage.toJson());
      if (kDebugMode) print('LuggageInfo ${luggage.id} updated for pilgrim $pilgrimId');
    } catch (e) {
      if (kDebugMode) print('Error updating LuggageInfo ${luggage.id} for pilgrim $pilgrimId: $e');
      rethrow;
    }
  }

  Future<void> deleteLuggageInfo(String bookingId, String pilgrimId, String luggageId) async {
    try {
      await _luggageInfosCollection(bookingId, pilgrimId).doc(luggageId).delete();
      if (kDebugMode) print('LuggageInfo $luggageId deleted for pilgrim $pilgrimId');
    } catch (e) {
      if (kDebugMode) print('Error deleting LuggageInfo $luggageId for pilgrim $pilgrimId: $e');
      rethrow;
    }
  }

  Stream<List<LuggageInfo>> getLuggageInfos(String bookingId, String pilgrimId) {
    return _luggageInfosCollection(bookingId, pilgrimId).snapshots().map((snapshot) {
      try {
        return snapshot.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>?;
          if (data == null) return null;
          return LuggageInfo.fromJson(data, doc.id);
        }).where((l) => l != null).cast<LuggageInfo>().toList();
      } catch (e) {
        if (kDebugMode) print('Error mapping LuggageInfos for pilgrim $pilgrimId: $e');
        return [];
      }
    }).handleError((error) {
      if (kDebugMode) print('Error in getLuggageInfos stream for pilgrim $pilgrimId: $error');
      return [];
    });
  }

  Future<LuggageInfo?> getLuggageInfoById(String bookingId, String pilgrimId, String luggageId) async {
    try {
      DocumentSnapshot doc = await _luggageInfosCollection(bookingId, pilgrimId).doc(luggageId).get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>?;
        return data != null ? LuggageInfo.fromJson(data, doc.id) : null;
      } else {
        if (kDebugMode) print('LuggageInfo $luggageId not found for pilgrim $pilgrimId');
        return null;
      }
    } catch (e) {
      if (kDebugMode) print('Error getting LuggageInfo $luggageId for pilgrim $pilgrimId: $e');
      return null;
    }
  }
}
