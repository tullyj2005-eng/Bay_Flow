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
    print('HomePageViewModel created');
    _init();
  }

  Future<void> _init() async {
    print('HomePageViewModel _init called');
    final uid = _auth.currentUser?.uid;
    print('UID: $uid');

    if (uid == null) {
      print('UID is null');
      isLoading = false;
      notifyListeners();
      return;
    }

    // look up shopId from userIndex
    final indexDoc = await _db.collection('userIndex').doc(uid).get();
    print('userIndex exists: ${indexDoc.exists}');
    print('userIndex data: ${indexDoc.data()}');

    if (!indexDoc.exists) {
      print('userIndex doc not found');
      isLoading = false;
      notifyListeners();
      return;
    }

    shopId = indexDoc.data()?['shopId'];
    print('ShopId loaded: $shopId');

    if (shopId != null) {
      fetchBays();
    } else {
      print('shopId is null in userIndex');
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