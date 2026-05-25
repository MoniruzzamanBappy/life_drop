import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/services/me_service.dart';
import '../../core/utils/validators.dart';
import '../../models/user_profile_model.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_dropdown_field.dart';
import '../../widgets/custom_text_field.dart';

class UpdateProfileScreen extends StatefulWidget {
  const UpdateProfileScreen({super.key, this.profile});

  final UserProfileModel? profile;

  @override
  State<UpdateProfileScreen> createState() => _UpdateProfileScreenState();
}

class _UpdateProfileScreenState extends State<UpdateProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final MeService _meService = MeService();

  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _photoController = TextEditingController();

  bool _isLoading = false;
  bool _isInitialLoading = true;

  DateTime? _lastDonateDate;

  String? _bloodGroup;
  String? _currentIllnessStatus;
  String? _currentMedicationStatus;
  String? _recentSurgeryOrMajorIllness;

  String? _hivTestResult;
  String? _hepatitisBTestResult;
  String? _hepatitisCTestResult;
  String? _syphilisTestResult;

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

  final List<String> _yesNoOptions = const ['Yes', 'No'];

  final List<String> _testResults = const [
    'Negative',
    'Positive',
    'Not Tested',
  ];

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      setState(() {
        _isInitialLoading = false;
      });
      return;
    }

    UserProfileModel? profile = widget.profile;

    profile ??= await _meService.getMe(user.uid);

    profile ??= UserProfileModel.empty(
      uid: user.uid,
      name: user.displayName ?? '',
      email: user.email ?? '',
      phone: user.phoneNumber ?? '',
      photo: user.photoURL ?? '',
    );

    _setInitialValues(profile);

    if (!mounted) return;

    setState(() {
      _isInitialLoading = false;
    });
  }

  void _setInitialValues(UserProfileModel profile) {
    _nameController.text = profile.name;
    _addressController.text = profile.address;
    _phoneController.text = profile.phone;
    _emailController.text = profile.email;
    _photoController.text = profile.photo;

    _lastDonateDate = profile.lastDonateDate;
    _bloodGroup = profile.bloodGroup.isEmpty ? null : profile.bloodGroup;

    _currentIllnessStatus = _boolToYesNo(profile.currentIllnessStatus);
    _currentMedicationStatus = _boolToYesNo(profile.currentMedicationStatus);
    _recentSurgeryOrMajorIllness = _boolToYesNo(
      profile.recentSurgeryOrMajorIllness,
    );

    _hivTestResult = profile.hivTestResult.isEmpty
        ? null
        : profile.hivTestResult;
    _hepatitisBTestResult = profile.hepatitisBTestResult.isEmpty
        ? null
        : profile.hepatitisBTestResult;
    _hepatitisCTestResult = profile.hepatitisCTestResult.isEmpty
        ? null
        : profile.hepatitisCTestResult;
    _syphilisTestResult = profile.syphilisTestResult.isEmpty
        ? null
        : profile.syphilisTestResult;
  }

  String? _boolToYesNo(bool? value) {
    if (value == null) return null;
    return value ? 'Yes' : 'No';
  }

  bool? _yesNoToBool(String? value) {
    if (value == null) return null;
    return value == 'Yes';
  }

  Future<void> _pickLastDonateDate() async {
    final now = DateTime.now();

    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _lastDonateDate ?? now,
      firstDate: DateTime(1970),
      lastDate: now,
    );

    if (pickedDate == null) return;

    setState(() {
      _lastDonateDate = pickedDate;
    });
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Select last donate date';

    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();

    return '$day-$month-$year';
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      _showMessage('User not logged in', isError: true);
      return;
    }

    try {
      setState(() {
        _isLoading = true;
      });

      await _meService.updateMe(
        uid: user.uid,
        data: {
          'uid': user.uid,
          'name': _nameController.text.trim(),
          'address': _addressController.text.trim(),
          'phone': _phoneController.text.trim(),
          'email': _emailController.text.trim(),
          'photo': _photoController.text.trim(),
          'lastDonateDate': _lastDonateDate == null
              ? null
              : Timestamp.fromDate(_lastDonateDate!),
          'bloodGroup': _bloodGroup,
          'currentIllnessStatus': _yesNoToBool(_currentIllnessStatus),
          'currentMedicationStatus': _yesNoToBool(_currentMedicationStatus),
          'recentSurgeryOrMajorIllness': _yesNoToBool(
            _recentSurgeryOrMajorIllness,
          ),
          'hivTestResult': _hivTestResult,
          'hepatitisBTestResult': _hepatitisBTestResult,
          'hepatitisCTestResult': _hepatitisCTestResult,
          'syphilisTestResult': _syphilisTestResult,
        },
      );

      if (!mounted) return;

      _showMessage('Profile updated successfully');

      Navigator.pop(context);
    } catch (e) {
      _showMessage(e.toString(), isError: true);
    } finally {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
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
    _nameController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _photoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isInitialLoading) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Update Profile')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(18),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                _buildPhotoPreview(),

                const SizedBox(height: 20),

                _buildSectionTitle(
                  title: 'Basic Information',
                  icon: Icons.person_outline,
                ),

                const SizedBox(height: 14),

                CustomTextField(
                  controller: _nameController,
                  label: 'Full Name',
                  prefixIcon: Icons.person_outline,
                  validator: (value) =>
                      Validators.requiredField(value, 'Full name'),
                ),

                const SizedBox(height: 14),

                _buildAddressField(),

                const SizedBox(height: 14),

                CustomTextField(
                  controller: _phoneController,
                  label: 'Phone Number',
                  prefixIcon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                  validator: Validators.phone,
                ),

                const SizedBox(height: 14),

                CustomTextField(
                  controller: _emailController,
                  label: 'Email',
                  prefixIcon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  validator: Validators.email,
                ),

                const SizedBox(height: 14),

                CustomTextField(
                  controller: _photoController,
                  label: 'Photo URL Optional',
                  prefixIcon: Icons.image_outlined,
                  keyboardType: TextInputType.url,
                  onChanged: (_) {
                    setState(() {});
                  },
                ),

                const SizedBox(height: 24),

                _buildSectionTitle(
                  title: 'Donation Information',
                  icon: Icons.bloodtype_outlined,
                ),

                const SizedBox(height: 14),

                CustomDropdownField(
                  label: 'Blood Group',
                  value: _bloodGroup,
                  prefixIcon: Icons.bloodtype,
                  items: _bloodGroups,
                  validator: (value) =>
                      Validators.requiredField(value, 'Blood group'),
                  onChanged: (value) {
                    setState(() {
                      _bloodGroup = value;
                    });
                  },
                ),

                const SizedBox(height: 14),

                _buildDatePicker(),

                const SizedBox(height: 24),

                _buildSectionTitle(
                  title: 'Health Screening',
                  icon: Icons.health_and_safety_outlined,
                ),

                const SizedBox(height: 14),

                CustomDropdownField(
                  label: 'Current Illness Status',
                  value: _currentIllnessStatus,
                  prefixIcon: Icons.sick_outlined,
                  items: _yesNoOptions,
                  validator: (value) =>
                      Validators.requiredField(value, 'Current illness status'),
                  onChanged: (value) {
                    setState(() {
                      _currentIllnessStatus = value;
                    });
                  },
                ),

                const SizedBox(height: 14),

                CustomDropdownField(
                  label: 'Current Medication Status',
                  value: _currentMedicationStatus,
                  prefixIcon: Icons.medication_outlined,
                  items: _yesNoOptions,
                  validator: (value) => Validators.requiredField(
                    value,
                    'Current medication status',
                  ),
                  onChanged: (value) {
                    setState(() {
                      _currentMedicationStatus = value;
                    });
                  },
                ),

                const SizedBox(height: 14),

                CustomDropdownField(
                  label: 'Recent Surgery or Major Illness',
                  value: _recentSurgeryOrMajorIllness,
                  prefixIcon: Icons.local_hospital_outlined,
                  items: _yesNoOptions,
                  validator: (value) => Validators.requiredField(
                    value,
                    'Recent surgery or major illness',
                  ),
                  onChanged: (value) {
                    setState(() {
                      _recentSurgeryOrMajorIllness = value;
                    });
                  },
                ),

                const SizedBox(height: 24),

                _buildSectionTitle(
                  title: 'Blood Test Results',
                  icon: Icons.science_outlined,
                ),

                const SizedBox(height: 14),

                CustomDropdownField(
                  label: 'HIV Test Result',
                  value: _hivTestResult,
                  prefixIcon: Icons.biotech_outlined,
                  items: _testResults,
                  validator: (value) =>
                      Validators.requiredField(value, 'HIV test result'),
                  onChanged: (value) {
                    setState(() {
                      _hivTestResult = value;
                    });
                  },
                ),

                const SizedBox(height: 14),

                CustomDropdownField(
                  label: 'Hepatitis B Test Result',
                  value: _hepatitisBTestResult,
                  prefixIcon: Icons.biotech_outlined,
                  items: _testResults,
                  validator: (value) => Validators.requiredField(
                    value,
                    'Hepatitis B test result',
                  ),
                  onChanged: (value) {
                    setState(() {
                      _hepatitisBTestResult = value;
                    });
                  },
                ),

                const SizedBox(height: 14),

                CustomDropdownField(
                  label: 'Hepatitis C Test Result',
                  value: _hepatitisCTestResult,
                  prefixIcon: Icons.biotech_outlined,
                  items: _testResults,
                  validator: (value) => Validators.requiredField(
                    value,
                    'Hepatitis C test result',
                  ),
                  onChanged: (value) {
                    setState(() {
                      _hepatitisCTestResult = value;
                    });
                  },
                ),

                const SizedBox(height: 14),

                CustomDropdownField(
                  label: 'Syphilis Test Result',
                  value: _syphilisTestResult,
                  prefixIcon: Icons.biotech_outlined,
                  items: _testResults,
                  validator: (value) =>
                      Validators.requiredField(value, 'Syphilis test result'),
                  onChanged: (value) {
                    setState(() {
                      _syphilisTestResult = value;
                    });
                  },
                ),

                const SizedBox(height: 28),

                CustomButton(
                  text: _isLoading ? 'Saving...' : 'Save Profile',
                  onPressed: _isLoading ? null : _saveProfile,
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPhotoPreview() {
    final photoUrl = _photoController.text.trim();

    return Column(
      children: [
        CircleAvatar(
          radius: 52,
          backgroundColor: AppColors.lightTeal,
          backgroundImage: photoUrl.isNotEmpty ? NetworkImage(photoUrl) : null,
          child: photoUrl.isEmpty
              ? const Icon(Icons.person, size: 52, color: AppColors.primaryTeal)
              : null,
        ),
        const SizedBox(height: 10),
        const Text(
          'Donor Profile',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Complete your information to become a verified donor',
          textAlign: TextAlign.center,
          style: TextStyle(color: AppColors.textSecondary),
        ),
      ],
    );
  }

  Widget _buildSectionTitle({required String title, required IconData icon}) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primaryTeal),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildAddressField() {
    return TextFormField(
      controller: _addressController,
      maxLines: 3,
      validator: (value) => Validators.requiredField(value, 'Address'),
      decoration: InputDecoration(
        labelText: 'Address',
        prefixIcon: const Icon(Icons.location_on_outlined),
        filled: true,
        fillColor: Colors.white,
        alignLabelWithHint: true,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.primaryTeal, width: 2),
        ),
      ),
    );
  }

  Widget _buildDatePicker() {
    return InkWell(
      onTap: _pickLastDonateDate,
      borderRadius: BorderRadius.circular(16),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: 'Last Donate Date',
          prefixIcon: const Icon(Icons.calendar_month_outlined),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
        ),
        child: Text(
          _formatDate(_lastDonateDate),
          style: TextStyle(
            color: _lastDonateDate == null
                ? AppColors.textSecondary
                : AppColors.textPrimary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
