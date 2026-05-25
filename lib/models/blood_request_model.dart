import 'package:cloud_firestore/cloud_firestore.dart';

class BloodRequestModel {
  final String id;
  final String requesterUid;
  final String patientName;
  final String bloodGroup;
  final int unitsNeeded;
  final String hospitalName;
  final String hospitalAddress;
  final String district;
  final String contactName;
  final String contactPhone;
  final DateTime? neededDate;
  final String urgency;
  final String reason;
  final String status;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  BloodRequestModel({
    required this.id,
    required this.requesterUid,
    required this.patientName,
    required this.bloodGroup,
    required this.unitsNeeded,
    required this.hospitalName,
    required this.hospitalAddress,
    required this.district,
    required this.contactName,
    required this.contactPhone,
    required this.neededDate,
    required this.urgency,
    required this.reason,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory BloodRequestModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? {};

    return BloodRequestModel(
      id: doc.id,
      requesterUid: data['requesterUid']?.toString() ?? '',
      patientName: data['patientName']?.toString() ?? '',
      bloodGroup: data['bloodGroup']?.toString() ?? '',
      unitsNeeded: data['unitsNeeded'] is int
          ? data['unitsNeeded']
          : int.tryParse(data['unitsNeeded']?.toString() ?? '1') ?? 1,
      hospitalName: data['hospitalName']?.toString() ?? '',
      hospitalAddress: data['hospitalAddress']?.toString() ?? '',
      district: data['district']?.toString() ?? '',
      contactName: data['contactName']?.toString() ?? '',
      contactPhone: data['contactPhone']?.toString() ?? '',
      neededDate: _dateFromFirestore(data['neededDate']),
      urgency: data['urgency']?.toString() ?? 'normal',
      reason: data['reason']?.toString() ?? '',
      status: data['status']?.toString() ?? 'open',
      createdAt: _dateFromFirestore(data['createdAt']),
      updatedAt: _dateFromFirestore(data['updatedAt']),
    );
  }

  Map<String, dynamic> toCreateMap() {
    return {
      'requesterUid': requesterUid,
      'patientName': patientName,
      'bloodGroup': bloodGroup,
      'unitsNeeded': unitsNeeded,
      'hospitalName': hospitalName,
      'hospitalAddress': hospitalAddress,
      'district': district,
      'contactName': contactName,
      'contactPhone': contactPhone,
      'neededDate': neededDate == null ? null : Timestamp.fromDate(neededDate!),
      'urgency': urgency,
      'reason': reason,
      'status': status,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
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
