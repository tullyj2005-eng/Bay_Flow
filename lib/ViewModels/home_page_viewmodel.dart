import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:bay_flow/Models/bay.dart';
import 'package:bay_flow/Models/job.dart';

class HomePageViewModel extends ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  List<Bay> bays = [];
  List<Job> queue = [];
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
      fetchQueue();
    } else {
      print('shopId is null in userIndex');
      isLoading = false;
      notifyListeners();
    }
  }

  // ── FETCH BAYS ───────────────────────────────────────
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

  // ── FETCH QUEUE ──────────────────────────────────────
  void fetchQueue() {
    _db
        .collection('shops')
        .doc(shopId)
        .collection('jobs')
        .where('status', isEqualTo: 'queued')
        .orderBy('priority')
        .snapshots()
        .listen((snapshot) {
          queue = snapshot.docs
              .map((doc) => Job.fromMap(doc.data(), doc.id))
              .toList();
          notifyListeners();
        }, onError: (error) {
          print('Queue fetch error: $error');
        });
  }

  // ── ADD BAY ──────────────────────────────────────────
  Future<void> addBay({
    required String bayName,
    required String type,
    required List<String> equipment,
  }) async {
    if (shopId == null) {
      print('Cannot add bay: shopId is null');
      return;
    }

    try {
      final docRef = await _db
          .collection('shops')
          .doc(shopId)
          .collection('bays')
          .add({
            'bayName': bayName,
            'type': type,
            'equipment': equipment,
            'status': 'available',
            'assignedJobId': null,
            'assignedTechId': null,
            'assignedTechName': null,
            'createdAt': FieldValue.serverTimestamp(),
          });
      print('Bay added with ID: ${docRef.id}');
    } catch (e) {
      print('Error adding bay: $e');
    }
  }

  // ── ASSIGN JOB TO BAY ────────────────────────────────
  Future<void> assignJob({
    required String bayId,
    required String jobId,
    required String techId,
    required String techName,
  }) async {
    if (shopId == null) return;

    try {
      final batch = _db.batch();

      final bayRef = _db
          .collection('shops')
          .doc(shopId)
          .collection('bays')
          .doc(bayId);
      batch.update(bayRef, {
        'status': 'in_progress',
        'assignedJobId': jobId,
        'assignedTechId': techId,
        'assignedTechName': techName,
        'startedAt': FieldValue.serverTimestamp(),
      });

      final jobRef = _db
          .collection('shops')
          .doc(shopId)
          .collection('jobs')
          .doc(jobId);
      batch.update(jobRef, {
        'status': 'in_progress',
        'assignedBayId': bayId,
        'assignedTechId': techId,
      });

      final techRef = _db
          .collection('shops')
          .doc(shopId)
          .collection('users')
          .doc(techId);
      batch.update(techRef, {
        'status': 'busy',
        'assignedBayId': bayId,
      });

      await batch.commit();
      print('Job assigned successfully');
    } catch (e) {
      print('Error assigning job: $e');
    }
  }

  // ── MARK JOB DONE ────────────────────────────────────
  Future<void> markJobDone({
    required String bayId,
    required String jobId,
    required String techId,
  }) async {
    if (shopId == null) return;

    try {
      final batch = _db.batch();

      final bayRef = _db
          .collection('shops')
          .doc(shopId)
          .collection('bays')
          .doc(bayId);
      batch.update(bayRef, {
        'status': 'available',
        'assignedJobId': null,
        'assignedTechId': null,
        'assignedTechName': null,
        'startedAt': null,
      });

      final jobRef = _db
          .collection('shops')
          .doc(shopId)
          .collection('jobs')
          .doc(jobId);
      batch.update(jobRef, {
        'status': 'done',
        'completedAt': FieldValue.serverTimestamp(),
      });

      final techRef = _db
          .collection('shops')
          .doc(shopId)
          .collection('users')
          .doc(techId);
      batch.update(techRef, {
        'status': 'available',
        'assignedBayId': null,
      });

      await batch.commit();
      print('Job marked done');
    } catch (e) {
      print('Error marking job done: $e');
    }
  }
}