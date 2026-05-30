import 'package:cloud_firestore/cloud_firestore.dart';

class UserProfileModel {
  final String uid;
  final String name;
  final String address;
  final String phone;
  final String email;
  final String photo;
  final DateTime? lastDonateDate;
  final String bloodGroup;
  final String role;
  final String status;

  final bool? currentIllnessStatus;
  final bool? currentMedicationStatus;
  final bool? recentSurgeryOrMajorIllness;

  final String hivTestResult;
  final String hepatitisBTestResult;
  final String hepatitisCTestResult;
  final String syphilisTestResult;

  UserProfileModel({
    required this.uid,
    required this.name,
    required this.address,
    required this.phone,
    required this.email,
    required this.photo,
    required this.lastDonateDate,
    required this.bloodGroup,
    required this.role,
    required this.status,
    required this.currentIllnessStatus,
    required this.currentMedicationStatus,
    required this.recentSurgeryOrMajorIllness,
    required this.hivTestResult,
    required this.hepatitisBTestResult,
    required this.hepatitisCTestResult,
    required this.syphilisTestResult,
  });

  factory UserProfileModel.empty({
    required String uid,
    required String email,
    String name = '',
    String phone = '',
    String photo = '',
  }) {
    return UserProfileModel(
      uid: uid,
      name: name,
      address: '',
      phone: phone,
      email: email,
      photo: photo,
      lastDonateDate: null,
      bloodGroup: '',
      role: 'user',
      status: 'active',
      currentIllnessStatus: null,
      currentMedicationStatus: null,
      recentSurgeryOrMajorIllness: null,
      hivTestResult: '',
      hepatitisBTestResult: '',
      hepatitisCTestResult: '',
      syphilisTestResult: '',
    );
  }

  factory UserProfileModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? {};

    return UserProfileModel(
      uid: data['uid']?.toString() ?? doc.id,
      name: data['name']?.toString() ?? '',
      address: data['address']?.toString() ?? '',
      phone: data['phone']?.toString() ?? '',
      email: data['email']?.toString() ?? '',
      photo: data['photo']?.toString() ?? '',
      lastDonateDate: _dateFromFirestore(data['lastDonateDate']),
      bloodGroup: data['bloodGroup']?.toString() ?? '',
      role: data['role']?.toString() ?? 'user',
      status: data['status']?.toString() ?? 'active',
      currentIllnessStatus: _toBool(data['currentIllnessStatus']),
      currentMedicationStatus: _toBool(data['currentMedicationStatus']),
      recentSurgeryOrMajorIllness: _toBool(data['recentSurgeryOrMajorIllness']),
      hivTestResult: data['hivTestResult']?.toString() ?? '',
      hepatitisBTestResult: data['hepatitisBTestResult']?.toString() ?? '',
      hepatitisCTestResult: data['hepatitisCTestResult']?.toString() ?? '',
      syphilisTestResult: data['syphilisTestResult']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'uid': uid,
      'name': name,
      'address': address,
      'phone': phone,
      'email': email,
      'photo': photo,
      'lastDonateDate': lastDonateDate == null
          ? null
          : Timestamp.fromDate(lastDonateDate!),
      'bloodGroup': bloodGroup,
      'role': role,
      'status': status,
      'currentIllnessStatus': currentIllnessStatus,
      'currentMedicationStatus': currentMedicationStatus,
      'recentSurgeryOrMajorIllness': recentSurgeryOrMajorIllness,
      'hivTestResult': hivTestResult,
      'hepatitisBTestResult': hepatitisBTestResult,
      'hepatitisCTestResult': hepatitisCTestResult,
      'syphilisTestResult': syphilisTestResult,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  bool get isBlocked => status.toLowerCase().trim() == 'blocked';

  bool get isAdmin => role.toLowerCase().trim() == 'admin';

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

  static bool? _toBool(dynamic value) {
    if (value == null) return null;
    if (value is bool) return value;

    final text = value.toString().toLowerCase().trim();

    if (text == 'true' || text == 'yes' || text == '1') return true;
    if (text == 'false' || text == 'no' || text == '0') return false;

    return null;
  }

  bool get isProfileComplete {
    return name.isNotEmpty &&
        address.isNotEmpty &&
        phone.isNotEmpty &&
        email.isNotEmpty &&
        lastDonateDate != null &&
        bloodGroup.isNotEmpty &&
        currentIllnessStatus != null &&
        currentMedicationStatus != null &&
        recentSurgeryOrMajorIllness != null &&
        hivTestResult.isNotEmpty &&
        hepatitisBTestResult.isNotEmpty &&
        hepatitisCTestResult.isNotEmpty &&
        syphilisTestResult.isNotEmpty;
  }

  List<String> get missingFields {
    final List<String> fields = [];

    if (name.isEmpty) fields.add('name');
    if (address.isEmpty) fields.add('address');
    if (phone.isEmpty) fields.add('phone');
    if (email.isEmpty) fields.add('email');
    if (lastDonateDate == null) fields.add('last donate date');
    if (bloodGroup.isEmpty) fields.add('blood group');

    if (currentIllnessStatus == null) {
      fields.add('current illness status');
    }

    if (currentMedicationStatus == null) {
      fields.add('current medication status');
    }

    if (recentSurgeryOrMajorIllness == null) {
      fields.add('recent surgery or major illness');
    }

    if (hivTestResult.isEmpty) fields.add('HIV test result');
    if (hepatitisBTestResult.isEmpty) fields.add('Hepatitis B test result');
    if (hepatitisCTestResult.isEmpty) fields.add('Hepatitis C test result');
    if (syphilisTestResult.isEmpty) fields.add('Syphilis test result');

    return fields;
  }
}
