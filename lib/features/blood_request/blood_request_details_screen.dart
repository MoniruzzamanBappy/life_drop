import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/services/blood_request_service.dart';
import '../../core/services/call_service.dart';
import '../../models/blood_request_model.dart';
import 'request_responses_screen.dart';
import 'respond_to_request_screen.dart';

class BloodRequestDetailsScreen extends StatelessWidget {
  const BloodRequestDetailsScreen({super.key, required this.request});

  final BloodRequestModel request;

  String _formatDate(DateTime? date) {
    if (date == null) return 'Not added';

    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();

    return '$day-$month-$year';
  }

  Color _urgencyColor(String urgency) {
    switch (urgency.toLowerCase()) {
      case 'emergency':
        return AppColors.danger;
      case 'urgent':
        return AppColors.warning;
      default:
        return AppColors.primaryGreen;
    }
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'fulfilled':
        return AppColors.primaryGreen;
      case 'closed':
        return AppColors.textSecondary;
      default:
        return AppColors.danger;
    }
  }

  Future<void> _callContact(
    BuildContext context,
    BloodRequestModel request,
  ) async {
    final success = await CallService.callPhone(request.contactPhone);

    if (!success && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not open phone dialer'),
          backgroundColor: AppColors.danger,
        ),
      );
    }
  }

  Future<void> _callAcceptedDonor(
    BuildContext context,
    BloodRequestModel request,
  ) async {
    final success = await CallService.callPhone(request.acceptedDonorPhone);

    if (!success && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not open phone dialer'),
          backgroundColor: AppColors.danger,
        ),
      );
    }
  }

  Future<void> _closeRequest(
    BuildContext context,
    BloodRequestModel request,
  ) async {
    try {
      await BloodRequestService().closeBloodRequest(request.id);

      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Request closed successfully'),
          backgroundColor: AppColors.primaryGreen,
        ),
      );

      Navigator.pop(context);
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
    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('blood_requests')
          .doc(request.id)
          .snapshots(),
      builder: (context, snapshot) {
        final latestRequest = snapshot.data?.exists == true
            ? BloodRequestModel.fromFirestore(snapshot.data!)
            : request;

        return _detailsScaffold(context, latestRequest);
      },
    );
  }

  Widget _detailsScaffold(BuildContext context, BloodRequestModel request) {
    final currentUid = FirebaseAuth.instance.currentUser?.uid;
    final bool isMine = currentUid == request.requesterUid;
    final bool isOpen = request.status.toLowerCase() == 'open';
    final bool isFulfilled = request.status.toLowerCase() == 'fulfilled';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Request Details')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _mainRequestCard(
              context: context,
              request: request,
              isMine: isMine,
              isOpen: isOpen,
              isFulfilled: isFulfilled,
            ),

            if (isFulfilled || request.hasAcceptedDonor) ...[
              const SizedBox(height: 16),
              _acceptedDonorCard(context, request),
            ],

            const SizedBox(height: 16),

            _sectionCard(
              title: 'Patient Information',
              icon: Icons.person_outline,
              children: [
                _infoRow('Patient Name', request.patientName),
                _infoRow('Blood Group', request.bloodGroup),
                _infoRow('Units Needed', '${request.unitsNeeded}'),
                _infoRow('Needed Date', _formatDate(request.neededDate)),
                _infoRow('Urgency', request.urgency.toUpperCase()),
                _infoRow('Status', request.status.toUpperCase()),
                if (request.fulfilledAt != null)
                  _infoRow('Fulfilled At', _formatDate(request.fulfilledAt)),
              ],
            ),

            const SizedBox(height: 16),

            _sectionCard(
              title: 'Hospital Information',
              icon: Icons.local_hospital_outlined,
              children: [
                _infoRow('Hospital Name', request.hospitalName),
                _infoRow('Hospital Address', request.hospitalAddress),
                _infoRow('District', request.district),
              ],
            ),

            const SizedBox(height: 16),

            _sectionCard(
              title: 'Contact Information',
              icon: Icons.phone_outlined,
              children: [
                _infoRow('Contact Name', request.contactName),
                _infoRow('Contact Phone', request.contactPhone),
              ],
            ),

            if (request.reason.isNotEmpty) ...[
              const SizedBox(height: 16),
              _sectionCard(
                title: 'Reason',
                icon: Icons.notes_outlined,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      request.reason,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        height: 1.45,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ],

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _mainRequestCard({
    required BuildContext context,
    required BloodRequestModel request,
    required bool isMine,
    required bool isOpen,
    required bool isFulfilled,
  }) {
    final urgencyColor = _urgencyColor(request.urgency);
    final statusColor = _statusColor(request.status);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: AppColors.border),
        boxShadow: const [
          BoxShadow(
            color: AppColors.cardShadow,
            blurRadius: 22,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 38,
                backgroundColor: urgencyColor.withValues(alpha: 0.12),
                child: Text(
                  request.bloodGroup,
                  style: TextStyle(
                    color: urgencyColor,
                    fontSize: 19,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  request.patientName.isEmpty
                      ? 'Blood Request'
                      : request.patientName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              _pillBadge(
                text: request.status.toUpperCase(),
                color: statusColor,
              ),
            ],
          ),

          const SizedBox(height: 20),

          _pillBadge(text: request.urgency.toUpperCase(), color: urgencyColor),

          const SizedBox(height: 20),

          _mainInfoLine(
            icon: Icons.water_drop_outlined,
            text: '${request.unitsNeeded} unit(s) needed',
          ),
          _mainInfoLine(
            icon: Icons.local_hospital_outlined,
            text: request.hospitalName,
          ),
          _mainInfoLine(
            icon: Icons.location_on_outlined,
            text: request.hospitalAddress,
          ),
          _mainInfoLine(icon: Icons.map_outlined, text: request.district),
          _mainInfoLine(
            icon: Icons.calendar_month_outlined,
            text: _formatDate(request.neededDate),
          ),
          _mainInfoLine(
            icon: Icons.phone_outlined,
            text: '${request.contactName} - ${request.contactPhone}',
          ),

          if (request.reason.isNotEmpty) ...[
            const SizedBox(height: 18),
            Text(
              request.reason,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 16,
                height: 1.45,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],

          const SizedBox(height: 22),

          _insideCardButtons(
            context: context,
            request: request,
            isMine: isMine,
            isOpen: isOpen,
            isFulfilled: isFulfilled,
          ),
        ],
      ),
    );
  }

  Widget _insideCardButtons({
    required BuildContext context,
    required BloodRequestModel request,
    required bool isMine,
    required bool isOpen,
    required bool isFulfilled,
  }) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton.icon(
            onPressed: () => _callContact(context, request),
            icon: const Icon(Icons.phone),
            label: const Text('Call Contact'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryGreen,
              foregroundColor: Colors.white,
              elevation: 0,
              textStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
            ),
          ),
        ),

        const SizedBox(height: 12),

        if (isMine)
          SizedBox(
            width: double.infinity,
            height: 52,
            child: OutlinedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => RequestResponsesScreen(request: request),
                  ),
                );
              },
              icon: const Icon(Icons.people_outline),
              label: Text(
                isFulfilled
                    ? 'View Responses / Accepted Donor'
                    : 'View Responses',
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primaryTeal,
                side: const BorderSide(
                  color: AppColors.primaryTeal,
                  width: 1.4,
                ),
                textStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
            ),
          )
        else if (isOpen)
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => RespondToRequestScreen(request: request),
                  ),
                );
              },
              icon: const Icon(Icons.volunteer_activism),
              label: const Text('I Can Donate'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryTeal,
                foregroundColor: Colors.white,
                elevation: 0,
                textStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
            ),
          )
        else
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.textSecondary.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Text(
              'This request is no longer accepting donor responses.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),

        if (isMine && isOpen) ...[
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: OutlinedButton.icon(
              onPressed: () => _closeRequest(context, request),
              icon: const Icon(Icons.check_circle_outline),
              label: const Text('Close Request'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.danger,
                side: const BorderSide(color: AppColors.danger, width: 1.3),
                textStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _mainInfoLine({required IconData icon, required String text}) {
    final displayText = text.trim().isEmpty ? 'Not added' : text;

    return Padding(
      padding: const EdgeInsets.only(bottom: 13),
      child: Row(
        children: [
          Icon(icon, size: 23, color: AppColors.primaryTeal),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              displayText,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _acceptedDonorCard(BuildContext context, BloodRequestModel request) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primaryGreen.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.primaryGreen.withValues(alpha: 0.30),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                height: 44,
                width: 44,
                decoration: BoxDecoration(
                  color: AppColors.primaryGreen.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.verified_rounded,
                  color: AppColors.primaryGreen,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Selected / Accepted Donor',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _infoRow('Donor Name', request.acceptedDonorName),
          _infoRow('Donor Phone', request.acceptedDonorPhone),
          if (request.acceptedDonorPhone.trim().isNotEmpty) ...[
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _callAcceptedDonor(context, request),
                icon: const Icon(Icons.call),
                label: const Text('Call Accepted Donor'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryGreen,
                  foregroundColor: Colors.white,
                  elevation: 0,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _sectionCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
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
              Icon(icon, color: AppColors.primaryTeal),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ...children,
        ],
      ),
    );
  }

  Widget _infoRow(String title, String value) {
    final displayValue = value.isEmpty ? 'Not added' : value;

    return Padding(
      padding: const EdgeInsets.only(bottom: 11),
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

  Widget _pillBadge({required String text, required Color color}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}
