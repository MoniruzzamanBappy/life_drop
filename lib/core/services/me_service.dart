import 'package:cloud_firestore/cloud_firestore.dart';

import '../../core/constants/firebase_collections.dart';
import '../../models/user_profile_model.dart';

class MeService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<UserProfileModel?> watchMe(String uid) {
    return _firestore
        .collection(FirebaseCollections.me)
        .doc(uid)
        .snapshots()
        .map((doc) {
          if (!doc.exists) return null;
          return UserProfileModel.fromFirestore(doc);
        });
  }

  Future<UserProfileModel?> getMe(String uid) async {
    final doc = await _firestore
        .collection(FirebaseCollections.me)
        .doc(uid)
        .get();

    if (!doc.exists) return null;

    return UserProfileModel.fromFirestore(doc);
  }

  Future<void> createMeIfNotExists(UserProfileModel profile) async {
    final docRef = _firestore
        .collection(FirebaseCollections.me)
        .doc(profile.uid);

    final doc = await docRef.get();

    if (!doc.exists) {
      await docRef.set({
        ...profile.toFirestore(),
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
  }

  Future<void> updateMe({
    required String uid,
    required Map<String, dynamic> data,
  }) {
    return _firestore.collection(FirebaseCollections.me).doc(uid).set({
      ...data,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }
}
