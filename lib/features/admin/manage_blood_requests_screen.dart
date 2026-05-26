import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/services/blood_request_service.dart';
import '../../models/blood_request_model.dart';
import '../../widgets/common_header.dart';
import '../blood_request/blood_request_details_screen.dart';

class ManageBloodRequestsScreen extends StatefulWidget {
  const ManageBloodRequestsScreen({super.key});

  @override
  State<ManageBloodRequestsScreen> createState() =>
      _ManageBloodRequestsScreenState();
}

class _ManageBloodRequestsScreenState extends State<ManageBloodRequestsScreen> {
  String _filter = 'all';
  String _search = '';

  List<BloodRequestModel> _applyFilter(List<BloodRequestModel> requests) {
    List<BloodRequestModel> filtered = requests;

    if (_filter != 'all') {
      filtered = filtered
          .where((request) => request.status.toLowerCase() == _filter)
          .toList();
    }

    if (_search.trim().isNotEmpty) {
      final query = _search.trim().toLowerCase();

      filtered = filtered.where((request) {
        return request.patientName.toLowerCase().contains(query) ||
            request.bloodGroup.toLowerCase().contains(query) ||
            request.hospitalName.toLowerCase().contains(query) ||
            request.district.toLowerCase().contains(query) ||
            request.contactPhone.toLowerCase().contains(query);
      }).toList();
    }

    return filtered;
  }

  Future<void> _updateStatus({
    required BuildContext context,
    required BloodRequestModel request,
    required String status,
  }) async {
    try {
      await BloodRequestService().updateRequestStatus(
        requestId: request.id,
        status: status,
      );

      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Request marked as $status'),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          const CommonHeader(
            title: 'Manage Requests',
            subtitle: 'Review and moderate blood requests',
          ),
          _filters(),
          Expanded(
            child: StreamBuilder<List<BloodRequestModel>>(
              stream: BloodRequestService().watchAllBloodRequests(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final requests = _applyFilter(snapshot.data ?? []);

                if (requests.isEmpty) {
                  return const Center(
                    child: Text(
                      'No blood requests found',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: requests.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    return _requestCard(context, requests[index]);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _filters() {
    return Container(
      color: AppColors.white,
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          TextField(
            onChanged: (value) {
              setState(() {
                _search = value;
              });
            },
            decoration: InputDecoration(
              hintText: 'Search request...',
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: AppColors.background,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              enabledBorder: const OutlineInputBorder(
                borderSide: BorderSide(color: AppColors.border),
                borderRadius: BorderRadius.all(Radius.circular(16)),
              ),
            ),
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _chip('All', 'all'),
                _chip('Open', 'open'),
                _chip('Fulfilled', 'fulfilled'),
                _chip('Closed', 'closed'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _chip(String label, String value) {
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

  Widget _requestCard(BuildContext context, BloodRequestModel request) {
    final statusColor = _statusColor(request.status);

    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => BloodRequestDetailsScreen(request: request),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: AppColors.lightTeal,
                  child: Text(
                    request.bloodGroup,
                    style: const TextStyle(
                      color: AppColors.primaryTeal,
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
                _badge(request.status.toUpperCase(), statusColor),
              ],
            ),
            const SizedBox(height: 12),
            _row('Hospital', request.hospitalName),
            _row('District', request.district),
            _row('Phone', request.contactPhone),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _updateStatus(
                      context: context,
                      request: request,
                      status: 'open',
                    ),
                    child: const Text('Open'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _updateStatus(
                      context: context,
                      request: request,
                      status: 'closed',
                    ),
                    child: const Text('Close'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _updateStatus(
                      context: context,
                      request: request,
                      status: 'fulfilled',
                    ),
                    child: const Text('Fulfill'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _row(String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 7),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(color: AppColors.textSecondary),
            ),
          ),
          Expanded(
            child: Text(
              value.isEmpty ? 'Not added' : value,
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
