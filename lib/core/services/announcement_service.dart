import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AnnouncementService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // ✅ READ announcements (index-free)
  Stream<QuerySnapshot> getAnnouncements() {
    return _firestore
        .collection('announcements')
        .where('isActive', isEqualTo: true)
        .snapshots();
  }

  // ✅ CREATE announcement (Admin)
  Future<void> createAnnouncement({
    required String title,
    required String description,
    required String area,
  }) async {
    final user = _auth.currentUser;

    if (user == null) return;

    await _firestore.collection('announcements').add({
      'title': title,
      'description': description,
      'area': area,
      'isActive': true,
      'createdBy': user.uid,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // ✅ DEACTIVATE (soft delete)
  Future<void> deactivateAnnouncement(String announcementId) async {
    await _firestore.collection('announcements').doc(announcementId).update({
      'isActive': false,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}
