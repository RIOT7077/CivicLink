import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../screens/citizen/citizen_home.dart';
import '../../screens/admins/admin_dashboard.dart';
import '../../screens/department/department_dashboard.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // =========================
  // LOGIN (ROLE-BASED)
  // =========================
  Future<void> login(
    BuildContext context,
    String email,
    String password,
  ) async {
    try {
      // 1️⃣ Firebase Auth login
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = credential.user;
      if (user == null) {
        throw 'Authentication failed';
      }

      // 2️⃣ Fetch user record from Firestore
      final userDoc = await _firestore.collection('users').doc(user.uid).get();

      if (!userDoc.exists) {
        // 🔒 Safety: logout immediately
        await _auth.signOut();
        throw 'User record not found';
      }

      final data = userDoc.data() as Map<String, dynamic>;

      // 3️⃣ BLOCK DISABLED USERS (CRITICAL)
      final bool isActive = data['isActive'] ?? true;
      if (!isActive) {
        await _auth.signOut(); // 🔒 force logout
        throw 'Your account has been disabled by admin';
      }

      // 4️⃣ Role-based navigation
      final role = data['role'];

      if (role == 'citizen') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const CitizenHome()),
        );
      } else if (role == 'admin') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const AdminDashboard()),
        );
      } else if (role == 'department') {
        final department = data['department'];
        if (department == null) {
          await _auth.signOut();
          throw 'Department not assigned';
        }

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => DepartmentDashboard(department: department),
          ),
        );
      } else {
        await _auth.signOut();
        throw 'Invalid user role';
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  // =========================
  // REGISTER (CITIZEN ONLY)
  // =========================
  Future<User?> register(
    String name,
    String email,
    String password,
    String phone,
  ) async {
    try {
      final cred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      await _firestore.collection('users').doc(cred.user!.uid).set({
        'uid': cred.user!.uid,
        'name': name,
        'email': email,
        'phone': phone,
        'role': 'citizen', // 🔒 default role
        'createdAt': FieldValue.serverTimestamp(),

      });

      return cred.user;
    } catch (e) {
      throw e.toString();
    }
  }

  // =========================
  // LOGOUT
  // =========================
  Future<void> logout() async {
    await _auth.signOut();
  }

  // =========================
  // ADMIN AUTHORIZATION CHECK
  // =========================
  Future<bool> isAdmin() async {
    final user = _auth.currentUser;
    if (user == null) return false;

    final doc = await _firestore.collection('users').doc(user.uid).get();

    return doc.exists && doc['role'] == 'admin';
  }
}
