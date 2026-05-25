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
  });

  final BloodRequestModel request;
  final bool isMine;
  final VoidCallback? onClose;

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

  @override
  Widget build(BuildContext context) {
    final urgencyColor = _urgencyColor(request.urgency);
    final statusColor = _statusColor(request.status);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
        boxShadow: const [
          BoxShadow(color: Colors.black, blurRadius: 10, offset: Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: urgencyColor.withValues(alpha: 0.12),
                child: Text(
                  request.bloodGroup,
                  style: TextStyle(
                    color: urgencyColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  request.patientName,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              _badge(text: request.status.toUpperCase(), color: statusColor),
            ],
          ),

          const SizedBox(height: 10),

          Align(
            alignment: Alignment.centerLeft,
            child: _badge(
              text: request.urgency.toUpperCase(),
              color: urgencyColor,
            ),
          ),

          const SizedBox(height: 14),

          _info(
            Icons.water_drop_outlined,
            '${request.unitsNeeded} unit(s) needed',
          ),
          _info(Icons.local_hospital_outlined, request.hospitalName),
          _info(Icons.location_on_outlined, request.hospitalAddress),
          _info(Icons.map_outlined, request.district),
          _info(Icons.calendar_month_outlined, _formatDate(request.neededDate)),
          _info(
            Icons.phone_outlined,
            '${request.contactName} - ${request.contactPhone}',
          ),

          if (request.reason.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              request.reason,
              style: const TextStyle(
                color: AppColors.textSecondary,
                height: 1.4,
              ),
            ),
          ],

          const SizedBox(height: 12),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _callContact(context),
              icon: const Icon(Icons.phone),
              label: const Text('Call Contact'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryGreen,
                foregroundColor: AppColors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),

          if (isMine && request.status == 'open' && onClose != null) ...[
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: onClose,
              icon: const Icon(Icons.check_circle_outline),
              label: const Text('Close Request'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primaryGreen,
                side: const BorderSide(color: AppColors.primaryGreen),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _info(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 7),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.primaryTeal, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text.isEmpty ? 'Not added' : text,
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

  Widget _badge({required String text, required Color color}) {
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
