import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/services/call_service.dart';
import '../../../models/blood_request_model.dart';

class BloodRequestCard extends StatelessWidget {
  const BloodRequestCard({
    super.key,
    required this.request,
    required this.isMine,
    this.onClose,
    this.onViewResponses,
    this.onDonate,
    this.onTap,
  });

  final BloodRequestModel request;
  final bool isMine;
  final VoidCallback? onClose;
  final VoidCallback? onViewResponses;
  final VoidCallback? onDonate;
  final VoidCallback? onTap;

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

  bool get _isOpen => request.status.toLowerCase() == 'open';

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

  @override
  Widget build(BuildContext context) {
    final urgencyColor = _urgencyColor(request.urgency);
    final statusColor = _statusColor(request.status);

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 380),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 16 * (1 - value)),
            child: child,
          ),
        );
      },
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(28),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: AppColors.border),
              boxShadow: AppColors.softShadow,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _topSection(
                  urgencyColor: urgencyColor,
                  statusColor: statusColor,
                ),

                const SizedBox(height: 18),

                _badge(
                  text: request.urgency.toUpperCase(),
                  color: urgencyColor,
                ),

                const SizedBox(height: 18),

                _info(
                  Icons.water_drop_outlined,
                  '${request.unitsNeeded} unit(s) needed',
                ),
                _info(Icons.local_hospital_outlined, request.hospitalName),
                _info(Icons.location_on_outlined, request.hospitalAddress),
                _info(Icons.map_outlined, request.district),
                _info(
                  Icons.calendar_month_outlined,
                  _formatDate(request.neededDate),
                ),
                _info(
                  Icons.phone_outlined,
                  '${request.contactName} - ${request.contactPhone}',
                ),

                if (request.reason.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Text(
                    request.reason,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 15,
                      height: 1.45,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],

                const SizedBox(height: 18),

                _actionButtons(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _topSection({
    required Color urgencyColor,
    required Color statusColor,
  }) {
    return Row(
      children: [
        Container(
          height: 72,
          width: 72,
          decoration: BoxDecoration(
            color: urgencyColor.withValues(alpha: 0.13),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              request.bloodGroup.isEmpty ? '?' : request.bloodGroup,
              style: TextStyle(
                color: urgencyColor,
                fontSize: 20,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Text(
            request.patientName.isEmpty ? 'Blood Request' : request.patientName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 22,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        const SizedBox(width: 10),
        _badge(text: request.status.toUpperCase(), color: statusColor),
      ],
    );
  }

  Widget _actionButtons(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton.icon(
            onPressed: () => _callContact(context),
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

        if (isMine && onViewResponses != null) ...[
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: OutlinedButton.icon(
              onPressed: onViewResponses,
              icon: const Icon(Icons.people_outline),
              label: const Text('View Responses'),
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
          ),
        ],

        if (isMine && _isOpen && onClose != null) ...[
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: OutlinedButton.icon(
              onPressed: onClose,
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

        if (!isMine && _isOpen && onDonate != null) ...[
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton.icon(
              onPressed: onDonate,
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
          ),
        ],
      ],
    );
  }

  Widget _info(IconData icon, String text) {
    final displayText = text.trim().isEmpty ? 'Not added' : text;

    return Padding(
      padding: const EdgeInsets.only(bottom: 11),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.primaryTeal, size: 21),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              displayText,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w800,
                height: 1.28,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _badge({required String text, required Color color}) {
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
