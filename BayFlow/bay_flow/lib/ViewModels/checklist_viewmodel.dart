import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:bay_flow/Models/job.dart';

class ChecklistViewModel extends ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  List<Job> queue = [];
  bool isLoading = true;
  String? shopId;

  ChecklistViewModel() {
    _init();
  }

  Future<void> _init() async {
    // get the current user's shopId from their profile
    final uid = _auth.currentUser?.uid;
    if (uid == null) {
      isLoading = false;
      notifyListeners();
      return;
    }

    final userDoc = await _db.collection('users').doc(uid).get();
    if (!userDoc.exists) {
      isLoading = false;
      notifyListeners();
      return;
    }

    shopId = userDoc.data()?['shopId'];
    print('ChecklistViewModel shopId: $shopId');

    if (shopId != null) {
      fetchQueue();
    } else {
      isLoading = false;
      notifyListeners();
    }
  }

  void fetchQueue() {
    _db
        .collection('shops')
        .doc(shopId)
        .collection('jobs')
        .orderBy('priority')
        .snapshots()
        .listen((snapshot) {
          print('Jobs found: ${snapshot.docs.length}');
          queue = snapshot.docs
              .map((doc) => Job.fromMap(doc.data(), doc.id))
              .toList();
          isLoading = false;
          notifyListeners();
        }, onError: (error) {
          print('Fetch error: $error');
          isLoading = false;
          notifyListeners();
        });
  }

  Future<void> addJob({
    required String customerName,
    required String vehicle,
    required String jobType,
    required String notes,
  }) async {
    if (shopId == null) return;

    try {
      final int nextPriority = queue.length;
      print('Adding job to shopId: $shopId');

      await _db
          .collection('shops')
          .doc(shopId)
          .collection('jobs')
          .add({
            'customerName': customerName,
            'vehicle': vehicle,
            'jobType': jobType,
            'notes': notes,
            'priority': nextPriority,
            'shopId': shopId,
            'status': 'queued',
            'createdAt': FieldValue.serverTimestamp(),
          });

      print('Job added successfully');
    } catch (e) {
      print('ERROR adding job: $e');
    }
  }

  void reorderQueue(int oldIndex, int newIndex) {
    if (newIndex > oldIndex) newIndex -= 1;
    final job = queue.removeAt(oldIndex);
    queue.insert(newIndex, job);
    notifyListeners();
    _updatePrioritiesInFirestore();
  }

  void _updatePrioritiesInFirestore() {
    if (shopId == null) return;
    final batch = _db.batch();
    for (int i = 0; i < queue.length; i++) {
      final docRef = _db
          .collection('shops')
          .doc(shopId)
          .collection('jobs')
          .doc(queue[i].id);
      batch.update(docRef, {'priority': i});
    }
    batch.commit();
  }
}