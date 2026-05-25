import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/services/activity_service.dart';
import '../../models/activity_model.dart';
import '../../widgets/common_header.dart';

class ActivityScreen extends StatelessWidget {
  const ActivityScreen({super.key});

  String _formatDate(DateTime? date) {
    if (date == null) return '';

    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');

    return '$day-$month-$year $hour:$minute';
  }

  IconData _iconForType(String type) {
    switch (type) {
      case 'request_response':
        return Icons.volunteer_activism;
      case 'response_status':
        return Icons.check_circle_outline;
      case 'blood_request':
        return Icons.bloodtype_outlined;
      default:
        return Icons.notifications_none;
    }
  }

  Color _colorForType(String type) {
    switch (type) {
      case 'request_response':
        return AppColors.primaryGreen;
      case 'response_status':
        return AppColors.primaryTeal;
      case 'blood_request':
        return AppColors.danger;
      default:
        return AppColors.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(child: Text('User not logged in')),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          CommonHeader(
            title: 'Activity',
            subtitle: 'Notifications and updates',
            actions: [
              IconButton(
                tooltip: 'Mark all as read',
                onPressed: () {
                  ActivityService().markAllAsRead(user.uid);
                },
                icon: const Icon(Icons.done_all, color: Colors.white),
              ),
            ],
          ),
          Expanded(
            child: StreamBuilder<List<ActivityModel>>(
              stream: ActivityService().watchMyActivities(user.uid),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final activities = snapshot.data ?? [];

                if (activities.isEmpty) {
                  return _emptyState();
                }

                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: activities.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final activity = activities[index];

                    return _activityCard(activity);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _emptyState() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.notifications_none,
              color: AppColors.primaryTeal,
              size: 58,
            ),
            SizedBox(height: 14),
            Text(
              'No activity yet',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 6),
            Text(
              'Your blood request responses and updates will appear here.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }

  Widget _activityCard(ActivityModel activity) {
    final color = _colorForType(activity.type);

    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: () {
        if (!activity.isRead) {
          ActivityService().markAsRead(activity.id);
        }
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: activity.isRead ? AppColors.white : AppColors.lightTeal,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: activity.isRead ? AppColors.border : AppColors.primaryTeal,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 46,
              width: 46,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Icon(_iconForType(activity.type), color: color),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    activity.title,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    activity.message,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _formatDate(activity.createdAt),
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            if (!activity.isRead)
              Container(
                height: 10,
                width: 10,
                decoration: const BoxDecoration(
                  color: AppColors.primaryGreen,
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
