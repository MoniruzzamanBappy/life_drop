import 'package:cloud_firestore/cloud_firestore.dart';

class AdminService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<int> getTotalUsers() async {
    final snapshot = await _firestore.collection('me').get();
    return snapshot.docs.length;
  }

  Future<int> getTotalDonors() async {
    final snapshot = await _firestore.collection('donors').get();
    return snapshot.docs.length;
  }

  Future<int> getTotalBloodRequests() async {
    final snapshot = await _firestore.collection('blood_requests').get();
    return snapshot.docs.length;
  }

  Future<int> getOpenBloodRequests() async {
    final snapshot = await _firestore
        .collection('blood_requests')
        .where('status', isEqualTo: 'open')
        .get();

    return snapshot.docs.length;
  }

  Future<int> getClosedBloodRequests() async {
    final snapshot = await _firestore
        .collection('blood_requests')
        .where('status', isEqualTo: 'closed')
        .get();

    return snapshot.docs.length;
  }

  Future<Map<String, int>> getDashboardCounts() async {
    final results = await Future.wait([
      getTotalUsers(),
      getTotalDonors(),
      getTotalBloodRequests(),
      getOpenBloodRequests(),
      getClosedBloodRequests(),
    ]);

    return {
      'totalUsers': results[0],
      'totalDonors': results[1],
      'totalBloodRequests': results[2],
      'openBloodRequests': results[3],
      'closedBloodRequests': results[4],
    };
  }
}
