import 'package:cloud_firestore/cloud_firestore.dart';

class BloodRequestResponseModel {
  final String id;
  final String requestId;
  final String donorUid;
  final String donorName;
  final String donorPhone;
  final String bloodGroup;
  final String message;
  final String status;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  BloodRequestResponseModel({
    required this.id,
    required this.requestId,
    required this.donorUid,
    required this.donorName,
    required this.donorPhone,
    required this.bloodGroup,
    required this.message,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory BloodRequestResponseModel.fromFirestore({
    required String requestId,
    required DocumentSnapshot<Map<String, dynamic>> doc,
  }) {
    final data = doc.data() ?? {};

    return BloodRequestResponseModel(
      id: doc.id,
      requestId: requestId,
      donorUid: data['donorUid']?.toString() ?? '',
      donorName: data['donorName']?.toString() ?? '',
      donorPhone: data['donorPhone']?.toString() ?? '',
      bloodGroup: data['bloodGroup']?.toString() ?? '',
      message: data['message']?.toString() ?? '',
      status: data['status']?.toString() ?? 'pending',
      createdAt: _dateFromFirestore(data['createdAt']),
      updatedAt: _dateFromFirestore(data['updatedAt']),
    );
  }

  Map<String, dynamic> toCreateMap() {
    return {
      'donorUid': donorUid,
      'donorName': donorName,
      'donorPhone': donorPhone,
      'bloodGroup': bloodGroup,
      'message': message,
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
