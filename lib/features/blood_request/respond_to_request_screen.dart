import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/services/blood_request_response_service.dart';
import '../../core/services/donor_service.dart';
import '../../models/blood_request_model.dart';
import '../../models/blood_request_response_model.dart';
import '../../models/donor_model.dart';
import '../../widgets/custom_button.dart';

class RespondToRequestScreen extends StatefulWidget {
  const RespondToRequestScreen({super.key, required this.request});

  final BloodRequestModel request;

  @override
  State<RespondToRequestScreen> createState() => _RespondToRequestScreenState();
}

class _RespondToRequestScreenState extends State<RespondToRequestScreen> {
  final _messageController = TextEditingController();
  final DonorService _donorService = DonorService();
  final BloodRequestResponseService _responseService =
      BloodRequestResponseService();

  DonorModel? _donor;
  bool _isLoading = true;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _loadDonor();
  }

  Future<void> _loadDonor() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      setState(() {
        _isLoading = false;
      });
      return;
    }

    final donor = await _donorService.getMyDonorProfile(user.uid);

    if (!mounted) return;

    setState(() {
      _donor = donor;
      _isLoading = false;
    });
  }

  Future<void> _submitResponse() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      _showMessage('User not logged in', isError: true);
      return;
    }

    if (_donor == null) {
      _showMessage('Please create your donor profile first', isError: true);
      return;
    }

    if (!_donor!.isAvailable) {
      _showMessage('You are currently unavailable as donor', isError: true);
      return;
    }

    try {
      setState(() {
        _isSubmitting = true;
      });

      final response = BloodRequestResponseModel(
        id: user.uid,
        requestId: widget.request.id,
        donorUid: user.uid,
        donorName: _donor!.name,
        donorPhone: _donor!.phone,
        bloodGroup: _donor!.bloodGroup,
        message: _messageController.text.trim().isEmpty
            ? 'I can donate blood.'
            : _messageController.text.trim(),
        status: 'pending',
        createdAt: null,
        updatedAt: null,
      );

      await _responseService.respondToRequest(
        requestId: widget.request.id,
        response: response,
      );

      if (!mounted) return;

      _showMessage('Response sent successfully');
      Navigator.pop(context);
    } catch (e) {
      _showMessage(e.toString(), isError: true);
    } finally {
      if (!mounted) return;

      setState(() {
        _isSubmitting = false;
      });
    }
  }

  void _showMessage(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppColors.danger : AppColors.primaryGreen,
      ),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final donor = _donor;
    final isBloodMatched =
        donor != null &&
        donor.bloodGroup.toUpperCase() ==
            widget.request.bloodGroup.toUpperCase();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Respond to Request')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: ListView(
                padding: const EdgeInsets.all(18),
                children: [
                  _requestSummary(),
                  const SizedBox(height: 16),

                  if (donor == null)
                    _warningCard(
                      title: 'Donor profile required',
                      message:
                          'You need to create a donor profile before responding to a blood request.',
                    )
                  else ...[
                    _donorSummary(donor),
                    const SizedBox(height: 16),

                    if (!isBloodMatched)
                      _warningCard(
                        title: 'Blood group does not match',
                        message:
                            'Requested blood group is ${widget.request.bloodGroup}, but your donor profile blood group is ${donor.bloodGroup}. Continue only if this is correct.',
                      ),

                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _messageController,
                      maxLines: 4,
                      decoration: InputDecoration(
                        labelText: 'Message Optional',
                        hintText: 'Example: I can donate today after 5 PM.',
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    CustomButton(
                      text: _isSubmitting ? 'Sending...' : 'I Can Donate',
                      onPressed: _isSubmitting ? null : _submitResponse,
                    ),
                  ],
                ],
              ),
            ),
    );
  }

  Widget _requestSummary() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Request Summary',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          _row('Patient', widget.request.patientName),
          _row('Blood Group', widget.request.bloodGroup),
          _row('Hospital', widget.request.hospitalName),
          _row('District', widget.request.district),
          _row('Contact', widget.request.contactPhone),
        ],
      ),
    );
  }

  Widget _donorSummary(DonorModel donor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Your Donor Info',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          _row('Name', donor.name),
          _row('Phone', donor.phone),
          _row('Blood Group', donor.bloodGroup),
          _row('Available', donor.isAvailable ? 'Yes' : 'No'),
        ],
      ),
    );
  }

  Widget _warningCard({required String title, required String message}) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8E1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFFECB3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.warning_amber, color: Color(0xFFF57F17)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  message,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _row(String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: Row(
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
}
