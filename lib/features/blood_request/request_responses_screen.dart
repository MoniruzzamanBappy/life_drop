import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/services/activity_service.dart';
import '../../core/services/blood_request_response_service.dart';
import '../../core/services/call_service.dart';
import '../../core/services/donation_history_service.dart';
import '../../models/blood_request_model.dart';
import '../../models/blood_request_response_model.dart';

class RequestResponsesScreen extends StatefulWidget {
  const RequestResponsesScreen({super.key, required this.request});

  final BloodRequestModel request;

  @override
  State<RequestResponsesScreen> createState() => _RequestResponsesScreenState();
}

class _RequestResponsesScreenState extends State<RequestResponsesScreen> {
  String _filter = 'all';
  bool _isProcessing = false;

  bool get _isFulfilled {
    return widget.request.status.toLowerCase() == 'fulfilled' ||
        widget.request.acceptedDonorUid.trim().isNotEmpty;
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'accepted':
        return AppColors.primaryGreen;
      case 'rejected':
        return AppColors.danger;
      default:
        return AppColors.warning;
    }
  }

  List<BloodRequestResponseModel> _filterResponses(
    List<BloodRequestResponseModel> responses,
  ) {
    if (_filter == 'all') return responses;

    return responses
        .where((response) => response.status.toLowerCase() == _filter)
        .toList();
  }

  BloodRequestResponseModel? _acceptedResponse(
    List<BloodRequestResponseModel> responses,
  ) {
    for (final response in responses) {
      if (response.status.toLowerCase() == 'accepted') {
        return response;
      }
    }
    return null;
  }

  Future<void> _callDonor(
    BuildContext context,
    BloodRequestResponseModel response,
  ) async {
    final success = await CallService.callPhone(response.donorPhone);

    if (!success && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not open phone dialer'),
          backgroundColor: AppColors.danger,
        ),
      );
    }
  }

  Future<bool> _confirmAccept(
    BuildContext context,
    BloodRequestResponseModel response,
  ) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          title: const Text('Accept this donor?'),
          content: Text(
            'Are you sure you want to accept ${response.donorName.isEmpty ? 'this donor' : response.donorName}?\n\n'
            'This will mark the request as fulfilled and create one donation history record.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton.icon(
              onPressed: () => Navigator.pop(dialogContext, true),
              icon: const Icon(Icons.check),
              label: const Text('Accept'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryGreen,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        );
      },
    );

    return result ?? false;
  }

  Future<void> _acceptResponse({
    required BuildContext context,
    required BloodRequestResponseModel response,
  }) async {
    if (_isProcessing) return;

    if (_isFulfilled) {
      _showMessage(context, 'This request is already fulfilled', isError: true);
      return;
    }

    final confirmed = await _confirmAccept(context, response);
    if (!confirmed) return;

    try {
      setState(() => _isProcessing = true);

      await DonationHistoryService().acceptResponseAndFulfillRequest(
        request: widget.request,
        response: response,
      );

      await ActivityService().createActivity(
        userId: response.donorUid,
        title: 'Your response was accepted',
        message:
            'Your response for ${widget.request.bloodGroup} blood request at ${widget.request.hospitalName} was accepted.',
        type: 'response_status',
        relatedRequestId: widget.request.id,
      );

      if (!context.mounted) return;

      _showMessage(context, 'Donor accepted and request fulfilled');

      Navigator.pop(context);
    } catch (e) {
      if (!context.mounted) return;
      _showMessage(context, e.toString(), isError: true);
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  Future<void> _rejectResponse({
    required BuildContext context,
    required BloodRequestResponseModel response,
  }) async {
    if (_isProcessing) return;

    try {
      setState(() => _isProcessing = true);

      await BloodRequestResponseService().updateResponseStatus(
        requestId: widget.request.id,
        donorUid: response.donorUid,
        status: 'rejected',
      );

      await ActivityService().createActivity(
        userId: response.donorUid,
        title: 'Your response was rejected',
        message:
            'Your response for ${widget.request.bloodGroup} blood request at ${widget.request.hospitalName} was rejected.',
        type: 'response_status',
        relatedRequestId: widget.request.id,
      );

      if (!context.mounted) return;
      _showMessage(context, 'Response rejected');
    } catch (e) {
      if (!context.mounted) return;
      _showMessage(context, e.toString(), isError: true);
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  void _showMessage(
    BuildContext context,
    String message, {
    bool isError = false,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppColors.danger : AppColors.primaryGreen,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final acceptedDonorName = widget.request.acceptedDonorName.trim();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Request Responses')),
      body: Column(
        children: [
          _requestSummary(),

          if (_isFulfilled)
            _fulfilledNotice(
              acceptedDonorName.isEmpty
                  ? 'A donor has already been accepted.'
                  : '$acceptedDonorName has already been accepted.',
            ),

          _filters(),

          Expanded(
            child: StreamBuilder<List<BloodRequestResponseModel>>(
              stream: BloodRequestResponseService().watchResponses(
                widget.request.id,
              ),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.primaryGreen,
                    ),
                  );
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(
                        snapshot.error.toString(),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: AppColors.danger,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  );
                }

                final allResponses = snapshot.data ?? [];
                final accepted = _acceptedResponse(allResponses);
                final responses = _filterResponses(allResponses);

                if (responses.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: Text(
                        'No donor responses found',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: responses.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final response = responses[index];

                    final alreadyAccepted =
                        accepted != null &&
                        accepted.donorUid == response.donorUid;

                    final disableAccept =
                        _isFulfilled ||
                        _isProcessing ||
                        !response.status.toLowerCase().contains('pending');

                    return _responseCard(
                      context: context,
                      response: response,
                      disableAccept: disableAccept,
                      alreadyAccepted: alreadyAccepted,
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _requestSummary() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: AppColors.lightTeal,
            child: Text(
              widget.request.bloodGroup,
              style: const TextStyle(
                color: AppColors.primaryTeal,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.request.patientName,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${widget.request.hospitalName} • ${widget.request.district}',
                  style: const TextStyle(color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          _badge(widget.request.status.toUpperCase(), AppColors.primaryGreen),
        ],
      ),
    );
  }

  Widget _fulfilledNotice(String text) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.primaryGreen.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primaryGreen.withValues(alpha: 0.28),
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.verified_rounded, color: AppColors.primaryGreen),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: AppColors.primaryGreen,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _filters() {
    return Container(
      width: double.infinity,
      color: AppColors.white,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _filterChip('All', 'all'),
            _filterChip('Pending', 'pending'),
            _filterChip('Accepted', 'accepted'),
            _filterChip('Rejected', 'rejected'),
          ],
        ),
      ),
    );
  }

  Widget _filterChip(String label, String value) {
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

  Widget _responseCard({
    required BuildContext context,
    required BloodRequestResponseModel response,
    required bool disableAccept,
    required bool alreadyAccepted,
  }) {
    final statusColor = _statusColor(response.status);
    final isPending = response.status.toLowerCase() == 'pending';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: alreadyAccepted
            ? AppColors.primaryGreen.withValues(alpha: 0.06)
            : AppColors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: alreadyAccepted ? AppColors.primaryGreen : AppColors.border,
        ),
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
              CircleAvatar(
                backgroundColor: AppColors.lightTeal,
                child: Text(
                  response.bloodGroup.isEmpty ? '?' : response.bloodGroup,
                  style: const TextStyle(
                    color: AppColors.primaryTeal,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  response.donorName.isEmpty
                      ? 'Unknown Donor'
                      : response.donorName,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              _badge(
                alreadyAccepted ? 'SELECTED' : response.status.toUpperCase(),
                alreadyAccepted ? AppColors.primaryGreen : statusColor,
              ),
            ],
          ),

          const SizedBox(height: 14),

          _infoRow('Phone', response.donorPhone),
          _infoRow('Blood Group', response.bloodGroup),
          _infoRow('Message', response.message),

          const SizedBox(height: 14),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _callDonor(context, response),
              icon: const Icon(Icons.phone),
              label: const Text('Call Donor'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryGreen,
                foregroundColor: AppColors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),

          if (isPending) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: disableAccept
                        ? null
                        : () => _acceptResponse(
                            context: context,
                            response: response,
                          ),
                    icon: const Icon(Icons.check),
                    label: const Text('Accept'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primaryGreen,
                      side: const BorderSide(color: AppColors.primaryGreen),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _isProcessing
                        ? null
                        : () => _rejectResponse(
                            context: context,
                            response: response,
                          ),
                    icon: const Icon(Icons.close),
                    label: const Text('Reject'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.danger,
                      side: const BorderSide(color: AppColors.danger),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _infoRow(String title, String value) {
    final displayValue = value.isEmpty ? 'Not added' : value;

    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
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
