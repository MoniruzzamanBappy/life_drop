import 'package:cloud_firestore/cloud_firestore.dart';

import '../../models/activity_model.dart';

class ActivityService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _collection {
    return _firestore.collection('activities');
  }

  Future<void> createActivity({
    required String userId,
    required String title,
    required String message,
    required String type,
    String relatedRequestId = '',
  }) {
    final activity = ActivityModel(
      id: '',
      userId: userId,
      title: title,
      message: message,
      type: type,
      isRead: false,
      relatedRequestId: relatedRequestId,
      createdAt: null,
    );

    return _collection.add(activity.toCreateMap());
  }

  Stream<List<ActivityModel>> watchMyActivities(String userId) {
    return _collection.where('userId', isEqualTo: userId).snapshots().map((
      snapshot,
    ) {
      final activities = snapshot.docs
          .map((doc) => ActivityModel.fromFirestore(doc))
          .toList();

      activities.sort((a, b) {
        final aDate = a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        final bDate = b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        return bDate.compareTo(aDate);
      });

      return activities;
    });
  }

  Stream<int> watchUnreadCount(String userId) {
    return _collection
        .where('userId', isEqualTo: userId)
        .where('isRead', isEqualTo: false)
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  Future<void> markAsRead(String activityId) {
    return _collection.doc(activityId).update({'isRead': true});
  }

  Future<void> markAllAsRead(String userId) async {
    final snapshot = await _collection
        .where('userId', isEqualTo: userId)
        .where('isRead', isEqualTo: false)
        .get();

    final batch = _firestore.batch();

    for (final doc in snapshot.docs) {
      batch.update(doc.reference, {'isRead': true});
    }

    await batch.commit();
  }
}
