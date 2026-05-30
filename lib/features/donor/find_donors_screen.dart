import 'package:flutter/material.dart';
import 'package:lifedrop/core/services/call_service.dart';

import '../../core/constants/app_colors.dart';
import '../../core/services/donor_service.dart';
import '../../models/donor_model.dart';
import '../../widgets/custom_text_field.dart';
import 'donor_profile_screen.dart';

class FindDonorsScreen extends StatefulWidget {
  const FindDonorsScreen({super.key});

  @override
  State<FindDonorsScreen> createState() => _FindDonorsScreenState();
}

class _FindDonorsScreenState extends State<FindDonorsScreen> {
  final _districtController = TextEditingController();

  String? _bloodGroup;
  String _district = '';

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

  bool get _hasFilter {
    return _bloodGroup != null || _district.trim().isNotEmpty;
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Not added';

    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();

    return '$day-$month-$year';
  }

  Future<void> _callDonor(DonorModel donor) async {
    final success = await CallService.callPhone(donor.phone);

    if (!success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not open phone dialer'),
          backgroundColor: AppColors.danger,
        ),
      );
    }
  }

  void _openDonorDetails(DonorModel donor) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => DonorProfileScreen(donor: donor)),
    );
  }

  void _clearFilter() {
    setState(() {
      _bloodGroup = null;
      _district = '';
      _districtController.clear();
    });
  }

  @override
  void dispose() {
    _districtController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Find Donors'),
        actions: [
          if (_hasFilter)
            TextButton.icon(
              onPressed: _clearFilter,
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('Reset'),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primaryGreen,
              ),
            ),
        ],
      ),
      body: StreamBuilder<List<DonorModel>>(
        stream: DonorService().watchAvailableDonors(
          bloodGroup: _bloodGroup,
          district: _district,
        ),
        builder: (context, snapshot) {
          final isLoading = snapshot.connectionState == ConnectionState.waiting;
          final donors = snapshot.data ?? [];

          return CustomScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
            slivers: [
              SliverToBoxAdapter(child: _modernFilterSection()),

              if (isLoading)
                const SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: CircularProgressIndicator(
                      color: AppColors.primaryGreen,
                    ),
                  ),
                )
              else if (donors.isEmpty)
                SliverFillRemaining(hasScrollBody: false, child: _emptyState())
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
                  sliver: SliverList.separated(
                    itemCount: donors.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 14),
                    itemBuilder: (context, index) {
                      return TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0, end: 1),
                        duration: Duration(milliseconds: 240 + (index * 40)),
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
                        child: _smartDonorCard(donors[index]),
                      );
                    },
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _modernFilterSection() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOutCubic,
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.white,
            AppColors.primaryGreen.withValues(alpha: 0.06),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
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
          _filterHeader(),

          const SizedBox(height: 18),

          const Row(
            children: [
              Icon(
                Icons.bloodtype_outlined,
                size: 18,
                color: AppColors.primaryGreen,
              ),
              SizedBox(width: 7),
              Text(
                'Blood Group',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w900,
                  fontSize: 15,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _bloodGroups.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              mainAxisExtent: 72,
            ),
            itemBuilder: (context, index) {
              final group = _bloodGroups[index];
              final isSelected = _bloodGroup == group;

              return _BloodGroupGridItem(
                label: group,
                isSelected: isSelected,
                onTap: () {
                  setState(() {
                    _bloodGroup = isSelected ? null : group;
                  });
                },
              );
            },
          ),

          const SizedBox(height: 18),

          CustomTextField(
            controller: _districtController,
            label: 'District',
            prefixIcon: Icons.location_on_outlined,
            onChanged: (value) {
              setState(() {
                _district = value.trim();
              });
            },
          ),

          if (_hasFilter) ...[
            const SizedBox(height: 14),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (_bloodGroup != null)
                  _ActiveFilterChip(
                    label: 'Blood $_bloodGroup',
                    onDeleted: () {
                      setState(() {
                        _bloodGroup = null;
                      });
                    },
                  ),
                if (_district.trim().isNotEmpty)
                  _ActiveFilterChip(
                    label: _district,
                    onDeleted: () {
                      setState(() {
                        _district = '';
                        _districtController.clear();
                      });
                    },
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _filterHeader() {
    return Row(
      children: [
        Container(
          height: 46,
          width: 46,
          decoration: BoxDecoration(
            color: AppColors.primaryGreen.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(17),
          ),
          child: const Icon(
            Icons.manage_search_rounded,
            color: AppColors.primaryGreen,
            size: 26,
          ),
        ),
        const SizedBox(width: 12),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Search Donors',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
              SizedBox(height: 3),
              Text(
                'Choose blood group and district',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        if (_hasFilter)
          IconButton(
            onPressed: _clearFilter,
            tooltip: 'Clear filters',
            icon: const Icon(Icons.close_rounded),
            color: AppColors.textSecondary,
            style: IconButton.styleFrom(backgroundColor: AppColors.background),
          ),
      ],
    );
  }

  Widget _smartDonorCard(DonorModel donor) {
    final isAvailable = donor.isAvailable;
    final hasPhone = donor.phone.trim().isNotEmpty;

    return InkWell(
      borderRadius: BorderRadius.circular(24),
      onTap: () => _openDonorDetails(donor),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(24),
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
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        height: 66,
                        width: 66,
                        decoration: BoxDecoration(
                          color: AppColors.danger.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(22),
                          border: Border.all(
                            color: AppColors.danger.withValues(alpha: 0.18),
                          ),
                        ),
                        child: Center(
                          child: Text(
                            donor.bloodGroup.isEmpty ? '?' : donor.bloodGroup,
                            style: const TextStyle(
                              color: AppColors.danger,
                              fontSize: 21,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ),
                      if (donor.isVerified)
                        Positioned(
                          right: -5,
                          bottom: -5,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: AppColors.white,
                              shape: BoxShape.circle,
                              border: Border.all(color: AppColors.border),
                            ),
                            child: const Icon(
                              Icons.verified,
                              color: AppColors.primaryGreen,
                              size: 20,
                            ),
                          ),
                        ),
                    ],
                  ),

                  const SizedBox(width: 14),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                donor.name.isEmpty
                                    ? 'Unknown Donor'
                                    : donor.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: AppColors.textPrimary,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Icon(
                              Icons.chevron_right_rounded,
                              color: AppColors.textSecondary,
                            ),
                          ],
                        ),

                        const SizedBox(height: 8),

                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            _MiniStatusBadge(
                              icon: isAvailable
                                  ? Icons.check_circle_rounded
                                  : Icons.cancel_rounded,
                              label: isAvailable ? 'Available' : 'Unavailable',
                              color: isAvailable
                                  ? AppColors.primaryGreen
                                  : AppColors.danger,
                            ),
                            if (donor.isVerified)
                              const _MiniStatusBadge(
                                icon: Icons.verified_user_rounded,
                                label: 'Verified',
                                color: AppColors.primaryTeal,
                              ),
                          ],
                        ),

                        const SizedBox(height: 10),

                        _CardInfoLine(
                          icon: Icons.location_on_outlined,
                          text: donor.district.isEmpty
                              ? 'District not added'
                              : donor.district,
                        ),

                        const SizedBox(height: 6),

                        _CardInfoLine(
                          icon: Icons.history_rounded,
                          text:
                              'Last donation: ${_formatDate(donor.lastDonateDate)}',
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            Container(
              padding: const EdgeInsets.fromLTRB(14, 10, 14, 14),
              decoration: BoxDecoration(
                color: AppColors.background.withValues(alpha: 0.75),
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(24),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _openDonorDetails(donor),
                      icon: const Icon(Icons.visibility_outlined, size: 19),
                      label: const Text('View Details'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primaryTeal,
                        side: BorderSide(
                          color: AppColors.primaryTeal.withValues(alpha: 0.35),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: hasPhone ? () => _callDonor(donor) : null,
                      icon: const Icon(Icons.call_rounded, size: 19),
                      label: const Text('Call'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryGreen,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: AppColors.textSecondary
                            .withValues(alpha: 0.20),
                        disabledForegroundColor: AppColors.textSecondary,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _emptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 76,
              width: 76,
              decoration: BoxDecoration(
                color: AppColors.primaryGreen.withValues(alpha: 0.10),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.person_search_rounded,
                color: AppColors.primaryGreen,
                size: 36,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'No donors found',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Try changing the blood group or district filter.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary, height: 1.4),
            ),
            if (_hasFilter) ...[
              const SizedBox(height: 18),
              OutlinedButton.icon(
                onPressed: _clearFilter,
                icon: const Icon(Icons.refresh_rounded),
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
          ],
        ),
      ),
    );
  }
}

class _BloodGroupGridItem extends StatelessWidget {
  const _BloodGroupGridItem({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: isSelected ? 1.03 : 1,
      duration: const Duration(milliseconds: 180),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOut,
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primaryGreen : AppColors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected ? AppColors.primaryGreen : AppColors.border,
                width: isSelected ? 1.4 : 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: isSelected
                      ? AppColors.primaryGreen.withValues(alpha: 0.22)
                      : AppColors.cardShadow,
                  blurRadius: isSelected ? 14 : 8,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.water_drop_rounded,
                  size: 18,
                  color: isSelected ? Colors.white : AppColors.danger,
                ),
                const SizedBox(height: 5),
                Flexible(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      label,
                      maxLines: 1,
                      style: TextStyle(
                        color: isSelected
                            ? Colors.white
                            : AppColors.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        height: 1,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ActiveFilterChip extends StatelessWidget {
  const _ActiveFilterChip({required this.label, required this.onDeleted});

  final String label;
  final VoidCallback onDeleted;

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(label),
      deleteIcon: const Icon(Icons.close_rounded, size: 17),
      onDeleted: onDeleted,
      backgroundColor: AppColors.primaryTeal.withValues(alpha: 0.10),
      deleteIconColor: AppColors.primaryTeal,
      labelStyle: const TextStyle(
        color: AppColors.primaryTeal,
        fontWeight: FontWeight.w800,
      ),
      side: BorderSide(color: AppColors.primaryTeal.withValues(alpha: 0.20)),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
    );
  }
}

class _MiniStatusBadge extends StatelessWidget {
  const _MiniStatusBadge({
    required this.icon,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.16)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 15),
          const SizedBox(width: 5),
          Text(
            label,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _CardInfoLine extends StatelessWidget {
  const _CardInfoLine({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.textSecondary),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
