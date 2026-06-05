import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:bay_flow/Models/staff.dart';

class StaffViewModel extends ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  List<Staff> staffList = [];
  bool isLoading = true;
  String? shopId;

  StaffViewModel() {
    _init();
  }

  Future<void> _init() async {
    print('StaffViewModel _init called');
    final uid = _auth.currentUser?.uid;
    if (uid == null) {
      isLoading = false;
      notifyListeners();
      return;
    }

    // look up shopId from userIndex
    final indexDoc = await _db.collection('userIndex').doc(uid).get();
    if (!indexDoc.exists) {
      isLoading = false;
      notifyListeners();
      return;
    }

    shopId = indexDoc.data()?['shopId'];
    print('StaffViewModel shopId: $shopId');

    if (shopId != null) {
      fetchStaff();
    } else {
      isLoading = false;
      notifyListeners();
    }
  }

  void fetchStaff() {
    _db
        .collection('shops')
        .doc(shopId)
        .collection('users')
        .snapshots()
        .listen((snapshot) {
          print('Staff found: ${snapshot.docs.length}');
          staffList = snapshot.docs
              .map((doc) => Staff.fromMap(doc.data(), doc.id))
              .toList();
          isLoading = false;
          notifyListeners();
        }, onError: (error) {
          print('Staff fetch error: $error');
          isLoading = false;
          notifyListeners();
        });
  }
}