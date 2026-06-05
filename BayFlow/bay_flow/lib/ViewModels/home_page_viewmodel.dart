import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:bay_flow/Models/bay.dart';

class HomePageViewModel extends ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // hardcoded for now — later this will come from login
  final String shopId = 'fEuCsQa2AjVPNQSO73zk';

  List<Bay> bays = [];
  bool isLoading = true;

  HomePageViewModel() {
    fetchBays();
  }

  void fetchBays() {
    // path: shops → shopId → bays
    _db
        .collection('shops')
        .doc(shopId)
        .collection('bays')
        .snapshots()
        .listen((snapshot) {
      bays = snapshot.docs
          .map((doc) => Bay.fromMap(doc.data(), doc.id))
          .toList();

      isLoading = false;
      notifyListeners();
    });
  }
}