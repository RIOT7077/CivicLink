import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/issue_model.dart';

class IssueService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> submitIssue(Issue issue) async {
    await _firestore.collection('issues').add(issue.toMap());
  }

  Stream<QuerySnapshot> getMyIssues() {
    return _firestore
        .collection('issues')
        .where('submittedBy', isEqualTo: currentUserId)
        .snapshots();
  }

  Stream<QuerySnapshot> getIssuesByDepartment(String department) {
    return _firestore
        .collection('issues')
        .where('assignedTo', isEqualTo: department)
        .snapshots();
  }

  String get currentUserId => _auth.currentUser!.uid;
  Stream<QuerySnapshot> getAdminIssues() {
    return _firestore
        .collection('issues')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  // 🔹 Update issue status
  Future<void> updateIssueStatus(String issueId, String status) async {
    await _firestore.collection('issues').doc(issueId).update({
      'status': status,
    });

    await _addStatusHistory(issueId, status);
  }

  // 🔹 Assign issue to department
  Future<void> assignIssueToDepartment(
    String issueId,
    String department,
  ) async {
    final doc = await _firestore.collection('issues').doc(issueId).get();

    if (!doc.exists) {
      throw 'Issue not found';
    }

    final data = doc.data() as Map<String, dynamic>;

    // 🔒 Ensure only verified issues are assigned
    if (data['status'] != 'Verified') {
      throw 'Issue must be verified before assignment';
    }

    // ✅ FINAL ASSIGNMENT UPDATE (PASTE THIS PART)
    await _firestore.collection('issues').doc(issueId).update({
      'assignedTo': department,
      'status': 'Assigned',
      'updatedAt': Timestamp.now(),
    });

    // Optional but recommended: status history
    await _firestore.collection('issues').doc(issueId).update({
      'statusHistory': FieldValue.arrayUnion([
        {'status': 'Assigned', 'timestamp': Timestamp.now()},
      ]),
    });
  }

  // 🔹 Get issues assigned to a department
  Stream<QuerySnapshot> getDepartmentIssues(String department) {
    return _firestore
        .collection('issues')
        .where('assignedTo', isEqualTo: department)
        .snapshots();
  }

  // 🔹 Department updates issue status
  Future<void> updateDepartmentIssueStatus(
    String issueId,
    String status,
  ) async {
    final doc = await _firestore.collection('issues').doc(issueId).get();
    if (!doc.exists) return;

    final data = doc.data()!;
    final slaStatus = calculateSlaStatus(
      createdAt: data['createdAt'],
      issueType: data['issueType'],
      status: status,
    );

    await _firestore.collection('issues').doc(issueId).update({
      'status': status,
      'slaStatus': slaStatus,
      'updatedAt': Timestamp.now(),
    });
  }

  Future<void> updateDepartmentIssue(
    String issueId,
    String status,
    String remark,
  ) async {
    await _firestore.collection('issues').doc(issueId).update({
      'status': status,
      'departmentRemark': remark,
      'updatedAt': Timestamp.now(),
      if (status == 'Resolved') 'resolvedAt': Timestamp.now(),
    });

    await _addStatusHistory(issueId, status);
  }

  Future<void> _addStatusHistory(String issueId, String status) async {
    await _firestore.collection('issues').doc(issueId).update({
      'statusHistory': FieldValue.arrayUnion([
        {'status': status, 'timestamp': Timestamp.now()},
      ]),
    });
  }

  Future<void> resolveIssueWithImage({
    required String issueId,
    required String status,
    required String remark,
    required String? resolvedImageUrl,
  }) async {
    await _firestore.collection('issues').doc(issueId).update({
      'status': status,
      'departmentRemark': remark,
      'resolvedImageUrl': resolvedImageUrl,
      'resolvedAt': Timestamp.now(),
    });

    await _addStatusHistory(issueId, status);
  }

  Stream<QuerySnapshot> getAllPublicIssues() {
    return FirebaseFirestore.instance
        .collection('issues')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  Future<void> toggleUpvote(String issueId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final issueRef = FirebaseFirestore.instance
        .collection('issues')
        .doc(issueId);

    await FirebaseFirestore.instance.runTransaction((transaction) async {
      final snapshot = await transaction.get(issueRef);
      if (!snapshot.exists) return;

      final data = snapshot.data() as Map<String, dynamic>;

      final List upvotedBy = data['upvotedBy'] ?? [];
      final int currentUpvotes = data['upvoteCount'] ?? 0;
      final String status = data['status'] ?? '';
      final bool priorityOverride = data['priorityOverride'] ?? false;

      // 🔒 Lock upvotes after resolution
      if (status == 'Resolved') {
        return;
      }

      int newUpvotes;

      if (upvotedBy.contains(user.uid)) {
        // 🔽 Remove upvote
        newUpvotes = currentUpvotes - 1;

        final Map<String, dynamic> updateData = {
          'upvotedBy': FieldValue.arrayRemove([user.uid]),
          'upvoteCount': FieldValue.increment(-1),
        };

        if (!priorityOverride) {
          updateData['priority'] = calculatePriority(newUpvotes);
        }

        transaction.update(issueRef, updateData);
      } else {
        // 🔼 Add upvote
        newUpvotes = currentUpvotes + 1;

        final Map<String, dynamic> updateData = {
          'upvotedBy': FieldValue.arrayUnion([user.uid]),
          'upvoteCount': FieldValue.increment(1),
        };

        if (!priorityOverride) {
          updateData['priority'] = calculatePriority(newUpvotes);
        }

        transaction.update(issueRef, updateData);
      }
    });
  }

  String calculatePriority(int upvotes) {
    if (upvotes >= 30) return 'Critical';
    if (upvotes >= 15) return 'High';
    if (upvotes >= 5) return 'Medium';
    return 'Low';
  }

  Future<void> overridePriority({
    required String issueId,
    required String newPriority,
  }) async {
    final doc = await _firestore.collection('issues').doc(issueId).get();

    if (!doc.exists) {
      throw 'Issue not found';
    }

    final data = doc.data() as Map<String, dynamic>;

    // 🔒 Lock after resolution
    if (data['status'] == 'Resolved') {
      throw 'Cannot change priority of a resolved issue';
    }

    await _firestore.collection('issues').doc(issueId).update({
      'priority': newPriority,
      'priorityOverride': true,
      'updatedAt': Timestamp.now(),
    });
  }

  int _getSlaDays(String issueType) {
    switch (issueType) {
      case 'Pothole':
        return 7;
      case 'Garbage':
        return 2;
      case 'Water Leakage':
        return 3;
      case 'Street Light':
        return 2;
      default:
        return 5;
    }
  }

  String calculateSlaStatus({
    required Timestamp createdAt,
    required String issueType,
    required String status,
  }) {
    // Resolved issues are always On Time
    if (status == 'Resolved') return 'On Time';

    final slaDays = _getSlaDays(issueType);
    final now = DateTime.now();
    final created = createdAt.toDate();

    final elapsedDays = now.difference(created).inDays;

    if (elapsedDays >= slaDays) {
      return 'Delayed';
    } else if (elapsedDays >= (slaDays - 1)) {
      return 'Near Delay';
    } else {
      return 'On Time';
    }
  }

  Future<void> reassignIssue({
    required String issueId,
    required String newDepartment,
    required String adminId,
  }) async {
    final issueRef = _firestore.collection('issues').doc(issueId);
    final doc = await issueRef.get();

    if (!doc.exists) throw 'Issue not found';

    final data = doc.data()!;

    // ❌ Do not allow reassignment if resolved
    if (data['status'] == 'Resolved') {
      throw 'Resolved issues cannot be reassigned';
    }

    await issueRef.update({
      'assignedTo': newDepartment,
      'status': 'Assigned',
      'updatedAt': Timestamp.now(),
      'statusHistory': FieldValue.arrayUnion([
        {
          'status': 'Reassigned to $newDepartment',
          'timestamp': Timestamp.now(),
          'by': adminId,
        },
      ]),
    });
  }
}
