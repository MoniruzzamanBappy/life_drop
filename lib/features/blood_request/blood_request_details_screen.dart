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
      case 'closed':
        return AppColors.textSecondary;
      default:
        return AppColors.primaryGreen;
    }
  }

  Future<void> _callContact(BuildContext context) async {
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

  Future<void> _closeRequest(BuildContext context) async {
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
    final currentUid = FirebaseAuth.instance.currentUser?.uid;
    final bool isMine = currentUid == request.requesterUid;
    final bool isOpen = request.status.toLowerCase() == 'open';

    final urgencyColor = _urgencyColor(request.urgency);
    final statusColor = _statusColor(request.status);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Request Details')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _topCard(urgencyColor: urgencyColor, statusColor: statusColor),

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

            const SizedBox(height: 16),

            if (request.reason.isNotEmpty)
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

            if (request.reason.isNotEmpty) const SizedBox(height: 16),

            _actionButtons(context: context, isMine: isMine, isOpen: isOpen),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _topCard({required Color urgencyColor, required Color statusColor}) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primaryTeal, AppColors.primaryGreen],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 34,
            backgroundColor: AppColors.white,
            child: Text(
              request.bloodGroup,
              style: const TextStyle(
                color: AppColors.primaryTeal,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  request.patientName.isEmpty
                      ? 'Blood Request'
                      : request.patientName,
                  style: const TextStyle(
                    color: AppColors.white,
                    fontSize: 21,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '${request.unitsNeeded} unit(s) needed • ${request.district}',
                  style: const TextStyle(color: AppColors.white, fontSize: 14),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _badge(
                      text: request.urgency.toUpperCase(),
                      color: urgencyColor,
                      isLight: true,
                    ),
                    _badge(
                      text: request.status.toUpperCase(),
                      color: statusColor,
                      isLight: true,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionButtons({
    required BuildContext context,
    required bool isMine,
    required bool isOpen,
  }) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton.icon(
            onPressed: () => _callContact(context),
            icon: const Icon(Icons.phone),
            label: const Text('Call Contact'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryGreen,
              foregroundColor: AppColors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        ),

        const SizedBox(height: 12),

        if (isMine) ...[
          SizedBox(
            width: double.infinity,
            height: 50,
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
              label: const Text('View Responses'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primaryTeal,
                side: const BorderSide(color: AppColors.primaryTeal),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),

          if (isOpen) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: OutlinedButton.icon(
                onPressed: () => _closeRequest(context),
                icon: const Icon(Icons.check_circle_outline),
                label: const Text('Close Request'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.danger,
                  side: const BorderSide(color: AppColors.danger),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
          ],
        ] else if (isOpen) ...[
          SizedBox(
            width: double.infinity,
            height: 50,
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
                foregroundColor: AppColors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
        ],
      ],
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

  Widget _badge({
    required String text,
    required Color color,
    bool isLight = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: isLight ? AppColors.white : color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(9),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: isLight ? color : color,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
