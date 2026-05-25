import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lifedrop/features/blood_request/respond_to_request_screen.dart';

import '../../core/constants/app_colors.dart';
import '../../core/services/blood_request_service.dart';
import '../../models/blood_request_model.dart';
import 'widgets/blood_request_card.dart';

class BloodRequestListScreen extends StatelessWidget {
  const BloodRequestListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUid = FirebaseAuth.instance.currentUser?.uid;

    if (currentUid == null) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(child: Text('User not logged in')),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Others Blood Requests')),
      body: StreamBuilder<List<BloodRequestModel>>(
        stream: BloodRequestService().watchOtherOpenBloodRequests(currentUid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final requests = snapshot.data ?? [];

          if (requests.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'No open requests from other users found',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 16,
                  ),
                ),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: requests.length,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final request = requests[index];

              return Column(
                children: [
                  BloodRequestCard(request: request, isMine: false),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                RespondToRequestScreen(request: request),
                          ),
                        );
                      },
                      icon: const Icon(Icons.volunteer_activism),
                      label: const Text('I Can Donate'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryGreen,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
