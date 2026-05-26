import 'package:flutter/material.dart';
import 'package:lifedrop/features/admin/manage_blood_requests_screen.dart';
import 'package:lifedrop/features/admin/manage_donors_screen.dart';
import 'package:lifedrop/features/admin/manage_users_screen.dart';
import 'package:lifedrop/features/admin/reports_dashboard_screen.dart';

import '../../core/constants/app_colors.dart';
import '../../core/services/admin_service.dart';
import '../../widgets/common_header.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final AdminService _adminService = AdminService();

  late Future<Map<String, int>> _dashboardFuture;

  @override
  void initState() {
    super.initState();
    _dashboardFuture = _adminService.getDashboardCounts();
  }

  Future<void> _refresh() async {
    setState(() {
      _dashboardFuture = _adminService.getDashboardCounts();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          const CommonHeader(
            title: 'Admin Dashboard',
            subtitle: 'Manage Life Drop platform',
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _refresh,
              child: FutureBuilder<Map<String, int>>(
                future: _dashboardFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return ListView(
                      padding: const EdgeInsets.all(24),
                      children: [
                        const SizedBox(height: 120),
                        const Icon(
                          Icons.error_outline,
                          color: AppColors.danger,
                          size: 56,
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Failed to load dashboard',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          snapshot.error.toString(),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    );
                  }

                  final data = snapshot.data ?? {};

                  return ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      const Text(
                        'Overview',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 14),

                      GridView.count(
                        crossAxisCount: 2,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        mainAxisSpacing: 14,
                        crossAxisSpacing: 14,
                        childAspectRatio: 1.05,
                        children: [
                          _countCard(
                            title: 'Users',
                            count: data['totalUsers'] ?? 0,
                            icon: Icons.people_outline,
                            color: AppColors.primaryTeal,
                          ),
                          _countCard(
                            title: 'Donors',
                            count: data['totalDonors'] ?? 0,
                            icon: Icons.volunteer_activism_outlined,
                            color: AppColors.primaryGreen,
                          ),
                          _countCard(
                            title: 'Open Requests',
                            count: data['openBloodRequests'] ?? 0,
                            icon: Icons.bloodtype_outlined,
                            color: AppColors.danger,
                          ),
                          _countCard(
                            title: 'Closed Requests',
                            count: data['closedBloodRequests'] ?? 0,
                            icon: Icons.check_circle_outline,
                            color: AppColors.textSecondary,
                          ),
                        ],
                      ),

                      const SizedBox(height: 22),

                      const Text(
                        'Admin Menus',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 14),

                      _menuTile(
                        title: 'Manage Users',
                        subtitle: 'View users and account status',
                        icon: Icons.manage_accounts_outlined,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const ManageUsersScreen(),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 12),
                      _menuTile(
                        title: 'Manage Donors',
                        subtitle: 'Verify and review donor profiles',
                        icon: Icons.verified_user_outlined,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const ManageDonorsScreen(),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 12),
                      _menuTile(
                        title: 'Manage Blood Requests',
                        subtitle: 'Review open and closed requests',
                        icon: Icons.bloodtype_outlined,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const ManageBloodRequestsScreen(),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 12),
                      _menuTile(
                        title: 'Reports',
                        subtitle: 'View app reports and analytics',
                        icon: Icons.bar_chart_outlined,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const ReportsDashboardScreen(),
                            ),
                          );
                        },
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _countCard({
    required String title,
    required int count,
    required IconData icon,
    required Color color,
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 46,
            width: 46,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(icon, color: color, size: 27),
          ),
          const Spacer(),
          Text(
            count.toString(),
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _menuTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Container(
              height: 46,
              width: 46,
              decoration: BoxDecoration(
                color: AppColors.lightTeal,
                borderRadius: BorderRadius.circular(15),
              ),
              child: const Icon(
                Icons.admin_panel_settings_outlined,
                color: AppColors.primaryTeal,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
            Icon(icon, color: AppColors.primaryTeal),
          ],
        ),
      ),
    );
  }
}
