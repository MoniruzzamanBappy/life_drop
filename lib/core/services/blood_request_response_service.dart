import 'package:cloud_firestore/cloud_firestore.dart';

import '../../models/blood_request_response_model.dart';

class BloodRequestResponseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _responsesRef(String requestId) {
    return _firestore
        .collection('blood_requests')
        .doc(requestId)
        .collection('responses');
  }

  Future<void> respondToRequest({
    required String requestId,
    required BloodRequestResponseModel response,
  }) {
    return _responsesRef(requestId)
        .doc(response.donorUid)
        .set(response.toCreateMap(), SetOptions(merge: true));
  }

  Stream<List<BloodRequestResponseModel>> watchResponses(String requestId) {
    return _responsesRef(requestId).snapshots().map((snapshot) {
      final responses = snapshot.docs
          .map(
            (doc) => BloodRequestResponseModel.fromFirestore(
              requestId: requestId,
              doc: doc,
            ),
          )
          .toList();

      responses.sort((a, b) {
        final aDate = a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        final bDate = b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        return bDate.compareTo(aDate);
      });

      return responses;
    });
  }

  Future<void> updateResponseStatus({
    required String requestId,
    required String donorUid,
    required String status,
  }) {
    return _responsesRef(requestId).doc(donorUid).set({
      'status': status,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }
}
