import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:bay_flow/Models/staff.dart';

class AuthViewModel extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Staff? currentStaff;
  bool isLoading = false;
  String? errorMessage;

  User? get currentUser => _auth.currentUser;
  bool get isLoggedIn => _auth.currentUser != null;

  Future<void> loadCurrentStaff() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    // step 1 — get shopId from userIndex
    final indexDoc = await _db.collection('userIndex').doc(uid).get();
    if (!indexDoc.exists) {
      print('loadCurrentStaff: userIndex doc not found');
      return;
    }

    final shopId = indexDoc.data()?['shopId'];
    if (shopId == null) {
      print('loadCurrentStaff: shopId is null in userIndex');
      return;
    }

    // step 2 — get user profile from shop subcollection
    final userDoc = await _db
        .collection('shops')
        .doc(shopId)
        .collection('users')
        .doc(uid)
        .get();

    if (userDoc.exists) {
      currentStaff = Staff.fromMap(userDoc.data()!, userDoc.id);
      print('Staff loaded: ${currentStaff?.name} role: ${currentStaff?.role}');
      notifyListeners();
    } else {
      print('loadCurrentStaff: user doc not found');
    }
  }

  Future<bool> login(String email, String password) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      await loadCurrentStaff();
      isLoading = false;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      isLoading = false;
      errorMessage = _handleAuthError(e.code);
      notifyListeners();
      return false;
    }
  }

  Future<bool> register({
    required String name,
    required String email,
    required String password,
    required String inviteCode,
  }) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      // step 1 — verify invite code matches a shop
      final shopQuery = await _db
          .collection('shops')
          .where('inviteCode', isEqualTo: inviteCode)
          .get();

      if (shopQuery.docs.isEmpty) {
        isLoading = false;
        errorMessage = 'Invalid invite code';
        notifyListeners();
        return false;
      }

      final shopId = shopQuery.docs.first.id;

      // step 2 — create Firebase Auth account
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final uid = credential.user!.uid;

      // step 3 — write user doc under the shop
      await _db
          .collection('shops')
          .doc(shopId)
          .collection('users')
          .doc(uid)
          .set({
            'name': name,
            'email': email,
            'role': 'tech',
            'shopId': shopId,
            'status': 'available',
            'assignedBayId': null,
            'createdAt': FieldValue.serverTimestamp(),
          });

      // step 4 — write userIndex for fast shopId lookup on login
      await _db.collection('userIndex').doc(uid).set({
        'shopId': shopId,
      });

      await loadCurrentStaff();
      isLoading = false;
      notifyListeners();
      return true;

    } on FirebaseAuthException catch (e) {
      isLoading = false;
      errorMessage = _handleAuthError(e.code);
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
    currentStaff = null;
    notifyListeners();
  }

  String _handleAuthError(String code) {
    switch (code) {
      case 'user-not-found':
        return 'No account found with that email';
      case 'wrong-password':
        return 'Incorrect password';
      case 'email-already-in-use':
        return 'An account already exists with that email';
      case 'weak-password':
        return 'Password must be at least 6 characters';
      case 'invalid-email':
        return 'Please enter a valid email address';
      default:
        return 'Something went wrong. Please try again';
    }
  }
}