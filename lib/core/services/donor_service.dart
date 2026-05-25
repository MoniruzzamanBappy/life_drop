import 'package:cloud_firestore/cloud_firestore.dart';

import '../../models/donor_model.dart';

class DonorService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _collection {
    return _firestore.collection('donors');
  }

  Stream<DonorModel?> watchMyDonorProfile(String uid) {
    return _collection.doc(uid).snapshots().map((doc) {
      if (!doc.exists) return null;
      return DonorModel.fromFirestore(doc);
    });
  }

  Future<DonorModel?> getMyDonorProfile(String uid) async {
    final doc = await _collection.doc(uid).get();

    if (!doc.exists) return null;

    return DonorModel.fromFirestore(doc);
  }

  Future<void> saveDonorProfile(DonorModel donor) async {
    final doc = await _collection.doc(donor.uid).get();

    await _collection
        .doc(donor.uid)
        .set(donor.toFirestore(isCreate: !doc.exists), SetOptions(merge: true));
  }

  Stream<List<DonorModel>> watchAvailableDonors({
    String? bloodGroup,
    String? district,
  }) {
    Query<Map<String, dynamic>> query = _collection.where(
      'isAvailable',
      isEqualTo: true,
    );

    if (bloodGroup != null && bloodGroup.isNotEmpty) {
      query = query.where('bloodGroup', isEqualTo: bloodGroup);
    }

    if (district != null && district.trim().isNotEmpty) {
      query = query.where('district', isEqualTo: district.trim());
    }

    return query.snapshots().map((snapshot) {
      final donors = snapshot.docs
          .map((doc) => DonorModel.fromFirestore(doc))
          .toList();

      donors.sort((a, b) => a.name.compareTo(b.name));

      return donors;
    });
  }

  Future<void> updateAvailability({
    required String uid,
    required bool isAvailable,
  }) {
    return _collection.doc(uid).set({
      'isAvailable': isAvailable,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }
}
