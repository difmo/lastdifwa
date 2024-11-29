import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Save bottle data to Firebase
  Future<void> addBottleData(int size, double price, double vacantPrice) async {
    final userId = _auth.currentUser?.uid;

    if (userId == null) {
      throw Exception("User not logged in.");
    }

    try {
      await _firestore.collection('bottleItems').add({
        'userId': userId,
        'size': size,
        'price': price,
        'vacantPrice': vacantPrice,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception("Failed to add bottle data: $e");
    }
  }

  // Fetch all bottle data for the current user
  Stream<List<Map<String, dynamic>>> fetchBottleItems() {
    final userId = _auth.currentUser?.uid;

    if (userId == null) {
      return const Stream.empty();
    }

    return _firestore
        .collection('bottleItems')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((querySnapshot) {
      return querySnapshot.docs.map((doc) {
        return {
          'id': doc.id,
          'size': doc['size'],
          'price': doc['price'],
          'vacantPrice': doc['vacantPrice'],
        };
      }).toList();
    });
  }

  // Update bottle data
  Future<void> updateBottleData(
      String docId, int size, double price, double vacantPrice) async {
    try {
      await _firestore.collection('bottleItems').doc(docId).update({
        'size': size,
        'price': price,
        'vacantPrice': vacantPrice,
      });
    } catch (e) {
      throw Exception("Failed to update bottle data: $e");
    }
  }

  // Delete bottle data
  Future<void> deleteBottleData(String docId) async {
    try {
      await _firestore.collection('bottleItems').doc(docId).delete();
    } catch (e) {
      throw Exception("Failed to delete bottle data: $e");
    }
  }
}
