import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:bay_flow/Models/job.dart';

class ChecklistViewModel extends ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // hardcoded for now — will come from auth later
  final String shopId = 'fEuCsQa2AjVPNQSO73zk';

  List<Job> queue = [];
  bool isLoading = true;

  ChecklistViewModel() {
    fetchQueue();
  }

  void fetchQueue() {
    print('Starting fetch...');

  _db
      .collection('shops')
      .doc(shopId)
      .collection('jobs')        // ← now matches your actual structure
      .snapshots()
      .listen((snapshot) {
        print('Total jobs found: ${snapshot.docs.length}');
        for (var doc in snapshot.docs) {
          print('Job: ${doc.data()}');
        }
        queue = snapshot.docs
            .map((doc) => Job.fromMap(doc.data(), doc.id))
            .toList();
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
  final int nextPriority = queue.length;

  await _db
      .collection('shops')
      .doc(shopId)
      .collection('jobs')        // ← same path
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
}

  void reorderQueue(int oldIndex, int newIndex) {
    if (newIndex > oldIndex) newIndex -= 1;
    final job = queue.removeAt(oldIndex);
    queue.insert(newIndex, job);
    notifyListeners();
    _updatePrioritiesInFirestore();
  }

  void _updatePrioritiesInFirestore() {
    // batch write — all priority updates in one network call
    final batch = _db.batch();
    for (int i = 0; i < queue.length; i++) {
      final docRef = _db.collection('jobs').doc(queue[i].id);
      batch.update(docRef, {'priority': i});
    }
    batch.commit();
  }
}