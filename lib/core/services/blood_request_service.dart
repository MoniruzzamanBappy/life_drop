import 'package:cloud_firestore/cloud_firestore.dart';

import '../../models/blood_request_model.dart';

class BloodRequestService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _collection {
    return _firestore.collection('blood_requests');
  }

  Future<void> createBloodRequest(BloodRequestModel request) {
    return _collection.add(request.toCreateMap());
  }

  Stream<List<BloodRequestModel>> watchOpenBloodRequests() {
    return _collection
        .where('status', isEqualTo: 'open')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => BloodRequestModel.fromFirestore(doc))
              .toList();
        });
  }

  Stream<List<BloodRequestModel>> watchOtherOpenBloodRequests(
    String currentUid,
  ) {
    return _collection
        .where('status', isEqualTo: 'open')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => BloodRequestModel.fromFirestore(doc))
              .where((request) => request.requesterUid != currentUid)
              .toList();
        });
  }

  Stream<List<BloodRequestModel>> watchMyBloodRequests(String requesterUid) {
    return _collection
        .where('requesterUid', isEqualTo: requesterUid)
        .snapshots()
        .map((snapshot) {
          final requests = snapshot.docs
              .map((doc) => BloodRequestModel.fromFirestore(doc))
              .toList();

          requests.sort((a, b) {
            final aDate = a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
            final bDate = b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
            return bDate.compareTo(aDate);
          });

          return requests;
        });
  }

  Future<void> closeBloodRequest(String requestId) {
    return _collection.doc(requestId).update({
      'status': 'closed',
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}
