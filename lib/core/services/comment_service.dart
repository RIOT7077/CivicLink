import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CommentService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Stream<QuerySnapshot> getComments(String announcementId) {
    return _firestore
        .collection('announcements')
        .doc(announcementId)
        .collection('comments')
        .orderBy('createdAt', descending: false)
        .snapshots();
  }

  Future<void> addComment({
    required String announcementId,
    required String text,
    required String userRole,
  }) async {
    final user = _auth.currentUser;
    if (user == null) return;

    // 🔹 Fetch username from users collection
    final userDoc = await _firestore.collection('users').doc(user.uid).get();
    final data = userDoc.data();
    final userName =
        data != null &&
            data['name'] != null &&
            data['name'].toString().isNotEmpty
        ? data['name']
        : _auth.currentUser!.email!;


    await _firestore
        .collection('announcements')
        .doc(announcementId)
        .collection('comments')
        .add({
          'text': text,
          'userId': user.uid,
          'userName': userName, // ✅ STORED
          'userRole': userRole,
          'createdAt': FieldValue.serverTimestamp(),
        });
  }
}
