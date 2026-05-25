import 'package:cloud_firestore/cloud_firestore.dart';

class DonorModel {
  final String uid;
  final String name;
  final String phone;
  final String email;
  final String address;
  final String district;
  final String bloodGroup;
  final DateTime? lastDonateDate;
  final bool isAvailable;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  DonorModel({
    required this.uid,
    required this.name,
    required this.phone,
    required this.email,
    required this.address,
    required this.district,
    required this.bloodGroup,
    required this.lastDonateDate,
    required this.isAvailable,
    required this.createdAt,
    required this.updatedAt,
  });

  factory DonorModel.empty({
    required String uid,
    String name = '',
    String phone = '',
    String email = '',
    String address = '',
    String district = '',
    String bloodGroup = '',
    DateTime? lastDonateDate,
    bool isAvailable = true,
  }) {
    return DonorModel(
      uid: uid,
      name: name,
      phone: phone,
      email: email,
      address: address,
      district: district,
      bloodGroup: bloodGroup,
      lastDonateDate: lastDonateDate,
      isAvailable: isAvailable,
      createdAt: null,
      updatedAt: null,
    );
  }

  factory DonorModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};

    return DonorModel(
      uid: data['uid']?.toString() ?? doc.id,
      name: data['name']?.toString() ?? '',
      phone: data['phone']?.toString() ?? '',
      email: data['email']?.toString() ?? '',
      address: data['address']?.toString() ?? '',
      district: data['district']?.toString() ?? '',
      bloodGroup: data['bloodGroup']?.toString() ?? '',
      lastDonateDate: _dateFromFirestore(data['lastDonateDate']),
      isAvailable: data['isAvailable'] is bool
          ? data['isAvailable']
          : data['isAvailable']?.toString().toLowerCase() == 'true',
      createdAt: _dateFromFirestore(data['createdAt']),
      updatedAt: _dateFromFirestore(data['updatedAt']),
    );
  }

  Map<String, dynamic> toFirestore({required bool isCreate}) {
    return {
      'uid': uid,
      'name': name,
      'phone': phone,
      'email': email,
      'address': address,
      'district': district,
      'bloodGroup': bloodGroup,
      'lastDonateDate': lastDonateDate == null
          ? null
          : Timestamp.fromDate(lastDonateDate!),
      'isAvailable': isAvailable,
      if (isCreate) 'createdAt': FieldValue.serverTimestamp(),
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
