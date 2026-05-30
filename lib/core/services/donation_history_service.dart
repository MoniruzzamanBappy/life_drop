import 'package:cloud_firestore/cloud_firestore.dart';

import '../../models/blood_request_model.dart';
import '../../models/blood_request_response_model.dart';
import '../../models/donation_history_model.dart';

class DonationHistoryService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _collection {
    return _firestore.collection('donation_history');
  }

  String historyDocId({required String requestId, required String donorUid}) {
    return '${requestId}_$donorUid';
  }

  Future<void> createDonationHistory(DonationHistoryModel history) {
    final docId = historyDocId(
      requestId: history.requestId,
      donorUid: history.donorUid,
    );

    return _collection
        .doc(docId)
        .set(history.toCreateMap(), SetOptions(merge: false));
  }

  Future<void> acceptResponseAndFulfillRequest({
    required BloodRequestModel request,
    required BloodRequestResponseModel response,
  }) async {
    final requestRef = _firestore.collection('blood_requests').doc(request.id);
    final responseRef = requestRef
        .collection('responses')
        .doc(response.donorUid);

    final historyRef = _collection.doc(
      historyDocId(requestId: request.id, donorUid: response.donorUid),
    );

    await _firestore.runTransaction((transaction) async {
      final requestSnapshot = await transaction.get(requestRef);
      final responseSnapshot = await transaction.get(responseRef);
      final historySnapshot = await transaction.get(historyRef);

      if (!requestSnapshot.exists) {
        throw Exception('Blood request not found');
      }

      if (!responseSnapshot.exists) {
        throw Exception('Donor response not found');
      }

      final requestData = requestSnapshot.data() ?? {};
      final currentStatus =
          requestData['status']?.toString().toLowerCase() ?? 'open';
      final acceptedDonorUid =
          requestData['acceptedDonorUid']?.toString() ?? '';

      if (currentStatus == 'fulfilled' || acceptedDonorUid.isNotEmpty) {
        throw Exception('This request is already fulfilled');
      }

      transaction.set(responseRef, {
        'status': 'accepted',
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      transaction.set(requestRef, {
        'status': 'fulfilled',
        'acceptedDonorUid': response.donorUid,
        'acceptedDonorName': response.donorName,
        'acceptedDonorPhone': response.donorPhone,
        'fulfilledAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      if (!historySnapshot.exists) {
        final history = DonationHistoryModel(
          id: historyRef.id,
          requestId: request.id,
          requesterUid: request.requesterUid,
          donorUid: response.donorUid,
          donorName: response.donorName,
          donorPhone: response.donorPhone,
          patientName: request.patientName,
          bloodGroup: request.bloodGroup,
          unitsDonated: request.unitsNeeded,
          hospitalName: request.hospitalName,
          district: request.district,
          donatedAt: DateTime.now(),
          createdAt: null,
        );

        transaction.set(historyRef, history.toCreateMap());
      }
    });
  }

  Stream<List<DonationHistoryModel>> watchUserDonationHistory(String uid) {
    return _collection.snapshots().map((snapshot) {
      final histories = snapshot.docs
          .map((doc) => DonationHistoryModel.fromFirestore(doc))
          .where((history) {
            return history.donorUid == uid || history.requesterUid == uid;
          })
          .toList();

      histories.sort((a, b) {
        final aDate = a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        final bDate = b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        return bDate.compareTo(aDate);
      });

      return histories;
    });
  }

  Stream<List<DonationHistoryModel>> watchAllDonationHistory() {
    return _collection.snapshots().map((snapshot) {
      final histories = snapshot.docs
          .map((doc) => DonationHistoryModel.fromFirestore(doc))
          .toList();

      histories.sort((a, b) {
        final aDate = a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        final bDate = b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        return bDate.compareTo(aDate);
      });

      return histories;
    });
  }
}
