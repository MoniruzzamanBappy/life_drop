import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> setDocument({
    required String collection,
    required String docId,
    required Map<String, dynamic> data,
  }) {
    return _firestore.collection(collection).doc(docId).set(data);
  }

  Future<void> updateDocument({
    required String collection,
    required String docId,
    required Map<String, dynamic> data,
  }) {
    return _firestore.collection(collection).doc(docId).update(data);
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> getDocument({
    required String collection,
    required String docId,
  }) {
    return _firestore.collection(collection).doc(docId).get();
  }

  Future<void> createUserIfNotExists({
    required String collection,
    required String docId,
    required Map<String, dynamic> data,
  }) async {
    final doc = await _firestore.collection(collection).doc(docId).get();

    if (!doc.exists) {
      await _firestore.collection(collection).doc(docId).set(data);
    }
  }
}
