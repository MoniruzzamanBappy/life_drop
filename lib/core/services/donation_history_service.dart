import 'package:cloud_firestore/cloud_firestore.dart';

import '../../models/donation_history_model.dart';

class DonationHistoryService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _collection {
    return _firestore.collection('donation_history');
  }

  Future<void> createDonationHistory(DonationHistoryModel history) {
    return _collection.add(history.toCreateMap());
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
