import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/services/activity_service.dart';
import '../../core/services/blood_request_response_service.dart';
import '../../core/services/blood_request_service.dart';
import '../../core/services/call_service.dart';
import '../../core/services/donation_history_service.dart';
import '../../models/blood_request_model.dart';
import '../../models/blood_request_response_model.dart';
import '../../models/donation_history_model.dart';

class RequestResponsesScreen extends StatefulWidget {
  const RequestResponsesScreen({super.key, required this.request});

  final BloodRequestModel request;

  @override
  State<RequestResponsesScreen> createState() => _RequestResponsesScreenState();
}

class _RequestResponsesScreenState extends State<RequestResponsesScreen> {
  String _filter = 'all';

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'accepted':
        return AppColors.primaryGreen;
      case 'rejected':
        return AppColors.danger;
      default:
        return AppColors.warning;
    }
  }

  List<BloodRequestResponseModel> _filterResponses(
    List<BloodRequestResponseModel> responses,
  ) {
    if (_filter == 'all') return responses;

    return responses
        .where((response) => response.status.toLowerCase() == _filter)
        .toList();
  }

  Future<void> _callDonor(
    BuildContext context,
    BloodRequestResponseModel response,
  ) async {
    final success = await CallService.callPhone(response.donorPhone);

    if (!success && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not open phone dialer'),
          backgroundColor: AppColors.danger,
        ),
      );
    }
  }

  Future<void> _updateStatus({
    required BuildContext context,
    required BloodRequestResponseModel response,
    required String status,
  }) async {
    try {
      await BloodRequestResponseService().updateResponseStatus(
        requestId: widget.request.id,
        donorUid: response.donorUid,
        status: status,
      );

      if (status == 'accepted') {
        await BloodRequestService().markFulfilled(widget.request.id);

        await DonationHistoryService().createDonationHistory(
          DonationHistoryModel(
            id: '',
            requestId: widget.request.id,
            requesterUid: widget.request.requesterUid,
            donorUid: response.donorUid,
            donorName: response.donorName,
            donorPhone: response.donorPhone,
            patientName: widget.request.patientName,
            bloodGroup: widget.request.bloodGroup,
            unitsDonated: widget.request.unitsNeeded,
            hospitalName: widget.request.hospitalName,
            district: widget.request.district,
            donatedAt: DateTime.now(),
            createdAt: null,
          ),
        );
      }

      await ActivityService().createActivity(
        userId: response.donorUid,
        title: status == 'accepted'
            ? 'Your response was accepted'
            : 'Your response was rejected',
        message:
            'Your response for ${widget.request.bloodGroup} blood request at ${widget.request.hospitalName} was $status.',
        type: 'response_status',
        relatedRequestId: widget.request.id,
      );

      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Response $status successfully'),
          backgroundColor: status == 'accepted'
              ? AppColors.primaryGreen
              : AppColors.danger,
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
      body: Column(
        children: [
          _requestSummary(),
          _filters(),
          Expanded(
            child: StreamBuilder<List<BloodRequestResponseModel>>(
              stream: BloodRequestResponseService().watchResponses(
                widget.request.id,
              ),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(
                        snapshot.error.toString(),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: AppColors.danger,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  );
                }

                final responses = _filterResponses(snapshot.data ?? []);

                if (responses.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: Text(
                        'No donor responses found',
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

                    return _responseCard(context: context, response: response);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _requestSummary() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: AppColors.lightTeal,
            child: Text(
              widget.request.bloodGroup,
              style: const TextStyle(
                color: AppColors.primaryTeal,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.request.patientName,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${widget.request.hospitalName} • ${widget.request.district}',
                  style: const TextStyle(color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _filters() {
    return Container(
      width: double.infinity,
      color: AppColors.white,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _filterChip('All', 'all'),
            _filterChip('Pending', 'pending'),
            _filterChip('Accepted', 'accepted'),
            _filterChip('Rejected', 'rejected'),
          ],
        ),
      ),
    );
  }

  Widget _filterChip(String label, String value) {
    final selected = _filter == value;

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
        selectedColor: AppColors.lightTeal,
        side: const BorderSide(color: AppColors.border),
        labelStyle: TextStyle(
          color: selected ? AppColors.primaryTeal : AppColors.textSecondary,
          fontWeight: FontWeight.bold,
        ),
        onSelected: (_) {
          setState(() {
            _filter = value;
          });
        },
      ),
    );
  }

  Widget _responseCard({
    required BuildContext context,
    required BloodRequestResponseModel response,
  }) {
    final statusColor = _statusColor(response.status);
    final isPending = response.status.toLowerCase() == 'pending';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
        boxShadow: const [
          BoxShadow(
            color: AppColors.cardShadow,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: AppColors.lightTeal,
                child: Text(
                  response.bloodGroup.isEmpty ? '?' : response.bloodGroup,
                  style: const TextStyle(
                    color: AppColors.primaryTeal,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  response.donorName.isEmpty
                      ? 'Unknown Donor'
                      : response.donorName,
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

          const SizedBox(height: 14),

          _infoRow('Phone', response.donorPhone),
          _infoRow('Blood Group', response.bloodGroup),
          _infoRow('Message', response.message),

          const SizedBox(height: 14),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _callDonor(context, response),
              icon: const Icon(Icons.phone),
              label: const Text('Call Donor'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryGreen,
                foregroundColor: AppColors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),

          if (isPending) ...[
            const SizedBox(height: 10),
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
        ],
      ),
    );
  }

  Widget _infoRow(String title, String value) {
    final displayValue = value.isEmpty ? 'Not added' : value;

    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              displayValue,
              textAlign: TextAlign.right,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.bold,
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
