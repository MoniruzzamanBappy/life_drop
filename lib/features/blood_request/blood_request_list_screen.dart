import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lifedrop/features/blood_request/blood_request_details_screen.dart';
import 'package:lifedrop/features/blood_request/respond_to_request_screen.dart';

import '../../core/constants/app_colors.dart';
import '../../core/services/blood_request_service.dart';
import '../../models/blood_request_model.dart';
import 'widgets/blood_request_card.dart';

class BloodRequestListScreen extends StatefulWidget {
  const BloodRequestListScreen({super.key});

  @override
  State<BloodRequestListScreen> createState() => _BloodRequestListScreenState();
}

class _BloodRequestListScreenState extends State<BloodRequestListScreen> {
  final BloodRequestService _bloodRequestService = BloodRequestService();

  String? _selectedBloodGroup;
  String? _selectedDistrict;
  String? _selectedUrgency;
  DateTime? _selectedNeededDate;

  final List<String> _bloodGroups = const [
    'A+',
    'A-',
    'B+',
    'B-',
    'AB+',
    'AB-',
    'O+',
    'O-',
  ];

  final List<String> _urgencies = const ['normal', 'urgent', 'emergency'];

  bool get _hasActiveFilter {
    return _selectedBloodGroup != null ||
        _selectedDistrict != null ||
        _selectedUrgency != null ||
        _selectedNeededDate != null;
  }

  List<BloodRequestModel> _applyFilters(List<BloodRequestModel> requests) {
    return requests.where((request) {
      final matchesBloodGroup =
          _selectedBloodGroup == null ||
          request.bloodGroup.toUpperCase() == _selectedBloodGroup;

      final matchesDistrict =
          _selectedDistrict == null ||
          request.district.trim().toLowerCase() ==
              _selectedDistrict!.trim().toLowerCase();

      final matchesUrgency =
          _selectedUrgency == null ||
          request.urgency.trim().toLowerCase() ==
              _selectedUrgency!.trim().toLowerCase();

      final matchesNeededDate =
          _selectedNeededDate == null ||
          (request.neededDate != null &&
              DateUtils.isSameDay(request.neededDate, _selectedNeededDate));

      return matchesBloodGroup &&
          matchesDistrict &&
          matchesUrgency &&
          matchesNeededDate;
    }).toList();
  }

  List<String> _getDistricts(List<BloodRequestModel> requests) {
    final districts = requests
        .map((request) => request.district.trim())
        .where((district) => district.isNotEmpty)
        .toSet()
        .toList();

    districts.sort();

    if (_selectedDistrict != null &&
        _selectedDistrict!.trim().isNotEmpty &&
        !districts.contains(_selectedDistrict)) {
      districts.insert(0, _selectedDistrict!);
    }

    return districts;
  }

  void _clearFilters() {
    setState(() {
      _selectedBloodGroup = null;
      _selectedDistrict = null;
      _selectedUrgency = null;
      _selectedNeededDate = null;
    });
  }

  Future<void> _pickNeededDate() async {
    final now = DateTime.now();

    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedNeededDate ?? now,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 2),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: AppColors.primaryGreen,
              surface: AppColors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null) {
      setState(() {
        _selectedNeededDate = pickedDate;
      });
    }
  }

  String _formatDate(DateTime date) {
    return DateFormat('dd MMM yyyy').format(date);
  }

  String _formatUrgency(String urgency) {
    if (urgency.isEmpty) return urgency;

    return urgency[0].toUpperCase() + urgency.substring(1).toLowerCase();
  }

  @override
  Widget build(BuildContext context) {
    final currentUid = FirebaseAuth.instance.currentUser?.uid;

    if (currentUid == null) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(child: Text('User not logged in')),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Others Blood Requests'),
        actions: [
          if (_hasActiveFilter)
            TextButton.icon(
              onPressed: _clearFilters,
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text('Reset'),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primaryGreen,
              ),
            ),
        ],
      ),
      body: StreamBuilder<List<BloodRequestModel>>(
        stream: _bloodRequestService.watchOtherOpenBloodRequests(currentUid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primaryGreen),
            );
          }

          final allRequests = snapshot.data ?? [];
          final filteredRequests = _applyFilters(allRequests);
          final districts = _getDistricts(allRequests);

          if (allRequests.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'No open requests from other users found',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 16,
                  ),
                ),
              ),
            );
          }

          return Column(
            children: [
              _FilterSection(
                bloodGroups: _bloodGroups,
                districts: districts,
                urgencies: _urgencies,
                selectedBloodGroup: _selectedBloodGroup,
                selectedDistrict: _selectedDistrict,
                selectedUrgency: _selectedUrgency,
                selectedNeededDate: _selectedNeededDate,
                totalCount: allRequests.length,
                filteredCount: filteredRequests.length,
                hasActiveFilter: _hasActiveFilter,
                onBloodGroupChanged: (value) {
                  setState(() => _selectedBloodGroup = value);
                },
                onDistrictChanged: (value) {
                  setState(() => _selectedDistrict = value);
                },
                onUrgencyChanged: (value) {
                  setState(() => _selectedUrgency = value);
                },
                onPickNeededDate: _pickNeededDate,
                onClearNeededDate: () {
                  setState(() => _selectedNeededDate = null);
                },
                onClearFilters: _clearFilters,
                formatDate: _formatDate,
                formatUrgency: _formatUrgency,
              ),

              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  child: filteredRequests.isEmpty
                      ? _NoFilteredRequestView(onClearFilters: _clearFilters)
                      : ListView.separated(
                          key: ValueKey(
                            '${filteredRequests.length}-$_selectedBloodGroup-$_selectedDistrict-$_selectedUrgency-$_selectedNeededDate',
                          ),
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                          itemCount: filteredRequests.length,
                          separatorBuilder: (_, _) =>
                              const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final request = filteredRequests[index];

                            return TweenAnimationBuilder<double>(
                              tween: Tween(begin: 0, end: 1),
                              duration: Duration(
                                milliseconds: 250 + (index * 40),
                              ),
                              curve: Curves.easeOutCubic,
                              builder: (context, value, child) {
                                return Opacity(
                                  opacity: value,
                                  child: Transform.translate(
                                    offset: Offset(0, 18 * (1 - value)),
                                    child: child,
                                  ),
                                );
                              },
                              child: Column(
                                children: [
                                  BloodRequestCard(
                                    request: request,
                                    isMine: false,
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) =>
                                              BloodRequestDetailsScreen(
                                                request: request,
                                              ),
                                        ),
                                      );
                                    },
                                    onDonate: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) =>
                                              RespondToRequestScreen(
                                                request: request,
                                              ),
                                        ),
                                      );
                                    },
                                  ),
                                  // const SizedBox(height: 8),
                                  // SizedBox(
                                  //   width: double.infinity,
                                  //   child: ElevatedButton.icon(
                                  //     onPressed: () {
                                  //       Navigator.push(
                                  //         context,
                                  //         MaterialPageRoute(
                                  //           builder: (_) =>
                                  //               RespondToRequestScreen(
                                  //                 request: request,
                                  //               ),
                                  //         ),
                                  //       );
                                  //     },
                                  //     icon: const Icon(
                                  //       Icons.volunteer_activism,
                                  //     ),
                                  //     label: const Text('I Can Donate'),
                                  //     style: ElevatedButton.styleFrom(
                                  //       backgroundColor: AppColors.primaryGreen,
                                  //       foregroundColor: Colors.white,
                                  //       elevation: 0,
                                  //       padding: const EdgeInsets.symmetric(
                                  //         vertical: 14,
                                  //       ),
                                  //       shape: RoundedRectangleBorder(
                                  //         borderRadius: BorderRadius.circular(
                                  //           14,
                                  //         ),
                                  //       ),
                                  //     ),
                                  //   ),
                                  // ),
                                ],
                              ),
                            );
                          },
                        ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _FilterSection extends StatelessWidget {
  const _FilterSection({
    required this.bloodGroups,
    required this.districts,
    required this.urgencies,
    required this.selectedBloodGroup,
    required this.selectedDistrict,
    required this.selectedUrgency,
    required this.selectedNeededDate,
    required this.totalCount,
    required this.filteredCount,
    required this.hasActiveFilter,
    required this.onBloodGroupChanged,
    required this.onDistrictChanged,
    required this.onUrgencyChanged,
    required this.onPickNeededDate,
    required this.onClearNeededDate,
    required this.onClearFilters,
    required this.formatDate,
    required this.formatUrgency,
  });

  final List<String> bloodGroups;
  final List<String> districts;
  final List<String> urgencies;

  final String? selectedBloodGroup;
  final String? selectedDistrict;
  final String? selectedUrgency;
  final DateTime? selectedNeededDate;

  final int totalCount;
  final int filteredCount;
  final bool hasActiveFilter;

  final ValueChanged<String?> onBloodGroupChanged;
  final ValueChanged<String?> onDistrictChanged;
  final ValueChanged<String?> onUrgencyChanged;
  final VoidCallback onPickNeededDate;
  final VoidCallback onClearNeededDate;
  final VoidCallback onClearFilters;

  final String Function(DateTime date) formatDate;
  final String Function(String urgency) formatUrgency;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.border),
        boxShadow: const [
          BoxShadow(
            color: AppColors.cardShadow,
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                height: 42,
                width: 42,
                decoration: BoxDecoration(
                  color: AppColors.primaryGreen.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.tune, color: AppColors.primaryGreen),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  hasActiveFilter
                      ? '$filteredCount of $totalCount requests found'
                      : '$totalCount open requests available',
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                  ),
                ),
              ),
              if (hasActiveFilter)
                IconButton(
                  onPressed: onClearFilters,
                  tooltip: 'Clear filters',
                  icon: const Icon(Icons.close),
                  color: AppColors.textSecondary,
                ),
            ],
          ),

          const SizedBox(height: 14),

          Row(
            children: [
              Expanded(
                child: _FilterDropdown(
                  label: 'Blood Group',
                  icon: Icons.water_drop_outlined,
                  value: selectedBloodGroup,
                  items: bloodGroups,
                  onChanged: onBloodGroupChanged,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _FilterDropdown(
                  label: 'Urgency',
                  icon: Icons.priority_high_rounded,
                  value: selectedUrgency,
                  items: urgencies,
                  displayText: formatUrgency,
                  onChanged: onUrgencyChanged,
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          _FilterDropdown(
            label: 'District',
            icon: Icons.map_outlined,
            value: selectedDistrict,
            items: districts,
            onChanged: onDistrictChanged,
          ),

          const SizedBox(height: 10),

          InkWell(
            onTap: onPickNeededDate,
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 13),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.calendar_month_outlined,
                    color: AppColors.primaryGreen,
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      selectedNeededDate == null
                          ? 'Needed Date'
                          : formatDate(selectedNeededDate!),
                      style: TextStyle(
                        color: selectedNeededDate == null
                            ? AppColors.textSecondary
                            : AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  if (selectedNeededDate != null)
                    GestureDetector(
                      onTap: onClearNeededDate,
                      child: const Icon(
                        Icons.close,
                        size: 18,
                        color: AppColors.textSecondary,
                      ),
                    )
                  else
                    const Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: AppColors.textSecondary,
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterDropdown extends StatelessWidget {
  const _FilterDropdown({
    required this.label,
    required this.icon,
    required this.value,
    required this.items,
    required this.onChanged,
    this.displayText,
  });

  final String label;
  final IconData icon;
  final String? value;
  final List<String> items;
  final ValueChanged<String?> onChanged;
  final String Function(String value)? displayText;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      isExpanded: true,
      icon: const Icon(Icons.keyboard_arrow_down_rounded),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 20),
        filled: true,
        fillColor: AppColors.background,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 13,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: AppColors.primaryGreen,
            width: 1.4,
          ),
        ),
      ),
      items: [
        DropdownMenuItem<String>(value: null, child: Text('All $label')),
        ...items.map(
          (item) => DropdownMenuItem<String>(
            value: item,
            child: Text(displayText?.call(item) ?? item),
          ),
        ),
      ],
      onChanged: onChanged,
    );
  }
}

class _NoFilteredRequestView extends StatelessWidget {
  const _NoFilteredRequestView({required this.onClearFilters});

  final VoidCallback onClearFilters;

  @override
  Widget build(BuildContext context) {
    return Center(
      key: const ValueKey('no-filtered-requests'),
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 72,
              width: 72,
              decoration: BoxDecoration(
                color: AppColors.primaryGreen.withValues(alpha: 0.10),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.search_off_rounded,
                color: AppColors.primaryGreen,
                size: 34,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'No matching blood requests',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Try changing blood group, district, urgency, or needed date.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary, height: 1.4),
            ),
            const SizedBox(height: 18),
            OutlinedButton.icon(
              onPressed: onClearFilters,
              icon: const Icon(Icons.refresh),
              label: const Text('Clear Filters'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primaryGreen,
                side: const BorderSide(color: AppColors.primaryGreen),
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
