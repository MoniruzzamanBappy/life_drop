import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/services/admin_service.dart';
import '../../widgets/common_header.dart';

class ReportsDashboardScreen extends StatefulWidget {
  const ReportsDashboardScreen({super.key});

  @override
  State<ReportsDashboardScreen> createState() => _ReportsDashboardScreenState();
}

class _ReportsDashboardScreenState extends State<ReportsDashboardScreen> {
  late Future<Map<String, int>> _future;

  @override
  void initState() {
    super.initState();
    _future = AdminService().getDashboardCounts();
  }

  Future<void> _refresh() async {
    setState(() {
      _future = AdminService().getDashboardCounts();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          const CommonHeader(
            title: 'Reports',
            subtitle: 'Life Drop platform overview',
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _refresh,
              child: FutureBuilder<Map<String, int>>(
                future: _future,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final data = snapshot.data ?? {};

                  return ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      _reportTile('Total Users', data['totalUsers'] ?? 0),
                      _reportTile('Total Donors', data['totalDonors'] ?? 0),
                      _reportTile(
                        'Total Blood Requests',
                        data['totalBloodRequests'] ?? 0,
                      ),
                      _reportTile(
                        'Open Requests',
                        data['openBloodRequests'] ?? 0,
                      ),
                      _reportTile(
                        'Closed Requests',
                        data['closedBloodRequests'] ?? 0,
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

  Widget _reportTile(String title, int count) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          const Icon(Icons.bar_chart_outlined, color: AppColors.primaryTeal),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Text(
            count.toString(),
            style: const TextStyle(
              color: AppColors.primaryGreen,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
