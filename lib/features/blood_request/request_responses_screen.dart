import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/services/blood_request_response_service.dart';
import '../../models/blood_request_model.dart';
import '../../models/blood_request_response_model.dart';

class RequestResponsesScreen extends StatelessWidget {
  const RequestResponsesScreen({super.key, required this.request});

  final BloodRequestModel request;

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'accepted':
        return AppColors.primaryGreen;
      case 'rejected':
        return AppColors.danger;
      default:
        return Colors.orange;
    }
  }

  Future<void> _updateStatus({
    required BuildContext context,
    required BloodRequestResponseModel response,
    required String status,
  }) async {
    try {
      await BloodRequestResponseService().updateResponseStatus(
        requestId: request.id,
        donorUid: response.donorUid,
        status: status,
      );

      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Response $status'),
          backgroundColor: AppColors.primaryGreen,
        ),
      );
    } catch (e) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: AppColors.danger,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Request Responses')),
      body: StreamBuilder<List<BloodRequestResponseModel>>(
        stream: BloodRequestResponseService().watchResponses(request.id),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final responses = snapshot.data ?? [];

          if (responses.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'No donor responses yet',
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
            itemCount: responses.length,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final response = responses[index];

              return _responseCard(context, response);
            },
          );
        },
      ),
    );
  }

  Widget _responseCard(
    BuildContext context,
    BloodRequestResponseModel response,
  ) {
    final statusColor = _statusColor(response.status);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: AppColors.lightTeal,
                child: Text(
                  response.bloodGroup,
                  style: const TextStyle(
                    color: AppColors.primaryTeal,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  response.donorName,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              _badge(response.status.toUpperCase(), statusColor),
            ],
          ),
          const SizedBox(height: 12),
          _info(Icons.phone_outlined, response.donorPhone),
          _info(Icons.bloodtype, response.bloodGroup),
          _info(Icons.message_outlined, response.message),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _updateStatus(
                    context: context,
                    response: response,
                    status: 'accepted',
                  ),
                  icon: const Icon(Icons.check),
                  label: const Text('Accept'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primaryGreen,
                    side: const BorderSide(color: AppColors.primaryGreen),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _updateStatus(
                    context: context,
                    response: response,
                    status: 'rejected',
                  ),
                  icon: const Icon(Icons.close),
                  label: const Text('Reject'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.danger,
                    side: const BorderSide(color: AppColors.danger),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _info(IconData icon, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 7),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.primaryTeal),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value.isEmpty ? 'Not added' : value,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _badge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(9),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
