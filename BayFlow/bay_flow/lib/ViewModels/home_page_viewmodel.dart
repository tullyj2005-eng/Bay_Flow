import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:bay_flow/Models/bay.dart';

class HomePageViewModel extends ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  List<Bay> bays = [];
  bool isLoading = true;
  String? shopId;

  HomePageViewModel() {
    print ('HomePageViewModel constructor called');
    _init();
  }

  Future<void> _init() async {
    print('_init called');
    final uid = _auth.currentUser?.uid;
    print('UID: $uid');

    if (uid == null) {
      print('UID is null — not logged in');
      isLoading = false;
      notifyListeners();
      return;
    }

    // test 1 — read specific document
    try {
      final testDoc = await _db
          .collection('userIndex')
          .doc(uid)
          .get();
      print('Direct read exists: ${testDoc.exists}');
      print('Direct read data: ${testDoc.data()}');
    } catch (e) {
      print('Direct read ERROR: $e');
    }

    // test 2 — list entire collection
    try {
      final collection = await _db.collection('userIndex').get();
      print('userIndex total docs: ${collection.docs.length}');
      for (var doc in collection.docs) {
        print('Doc: ${doc.id} → ${doc.data()}');
      }
    } catch (e) {
      print('Collection list ERROR: $e');
    }

    // actual lookup
    final indexDoc = await _db.collection('userIndex').doc(uid).get();
    print('Index doc exists: ${indexDoc.exists}');

    if (!indexDoc.exists) {
      print('User not found in userIndex');
      isLoading = false;
      notifyListeners();
      return;
    }

    shopId = indexDoc.data()?['shopId'];
    print('ShopId loaded: $shopId');

    if (shopId != null) {
      fetchBays();
    } else {
      print('shopId is null in userIndex document');
      isLoading = false;
      notifyListeners();
    }
  }

  void fetchBays() {
    print('fetchBays called for shopId: $shopId');
    _db
        .collection('shops')
        .doc(shopId)
        .collection('bays')
        .snapshots()
        .listen((snapshot) {
          print('Bays found: ${snapshot.docs.length}');
          bays = snapshot.docs
              .map((doc) => Bay.fromMap(doc.data(), doc.id))
              .toList();
          isLoading = false;
          notifyListeners();
        }, onError: (error) {
          print('Bay fetch error: $error');
          isLoading = false;
          notifyListeners();
        });
  }
}