import 'package:cloud_firestore/cloud_firestore.dart';

class DonationHistoryModel {
  final String id;
  final String requestId;
  final String requesterUid;
  final String donorUid;
  final String donorName;
  final String donorPhone;
  final String patientName;
  final String bloodGroup;
  final int unitsDonated;
  final String hospitalName;
  final String district;
  final DateTime? donatedAt;
  final DateTime? createdAt;

  DonationHistoryModel({
    required this.id,
    required this.requestId,
    required this.requesterUid,
    required this.donorUid,
    required this.donorName,
    required this.donorPhone,
    required this.patientName,
    required this.bloodGroup,
    required this.unitsDonated,
    required this.hospitalName,
    required this.district,
    required this.donatedAt,
    required this.createdAt,
  });

  factory DonationHistoryModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? {};

    return DonationHistoryModel(
      id: doc.id,
      requestId: data['requestId']?.toString() ?? '',
      requesterUid: data['requesterUid']?.toString() ?? '',
      donorUid: data['donorUid']?.toString() ?? '',
      donorName: data['donorName']?.toString() ?? '',
      donorPhone: data['donorPhone']?.toString() ?? '',
      patientName: data['patientName']?.toString() ?? '',
      bloodGroup: data['bloodGroup']?.toString() ?? '',
      unitsDonated: data['unitsDonated'] is int
          ? data['unitsDonated']
          : int.tryParse(data['unitsDonated']?.toString() ?? '1') ?? 1,
      hospitalName: data['hospitalName']?.toString() ?? '',
      district: data['district']?.toString() ?? '',
      donatedAt: _dateFromFirestore(data['donatedAt']),
      createdAt: _dateFromFirestore(data['createdAt']),
    );
  }

  Map<String, dynamic> toCreateMap() {
    return {
      'requestId': requestId,
      'requesterUid': requesterUid,
      'donorUid': donorUid,
      'donorName': donorName,
      'donorPhone': donorPhone,
      'patientName': patientName,
      'bloodGroup': bloodGroup,
      'unitsDonated': unitsDonated,
      'hospitalName': hospitalName,
      'district': district,
      'donatedAt': donatedAt == null ? null : Timestamp.fromDate(donatedAt!),
      'createdAt': FieldValue.serverTimestamp(),
    };
  }

  static DateTime? _dateFromFirestore(dynamic value) {
    if (value == null) return null;

    if (value is Timestamp) {
      return value.toDate();
    }

    if (value is String) {
      return DateTime.tryParse(value);
    }

    return null;
  }
}
