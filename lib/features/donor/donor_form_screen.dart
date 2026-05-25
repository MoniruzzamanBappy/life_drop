import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/services/donor_service.dart';
import '../../core/services/me_service.dart';
import '../../core/utils/validators.dart';
import '../../models/donor_model.dart';
import '../../models/user_profile_model.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_dropdown_field.dart';
import '../../widgets/custom_text_field.dart';

class DonorFormScreen extends StatefulWidget {
  const DonorFormScreen({super.key, this.donor});

  final DonorModel? donor;

  @override
  State<DonorFormScreen> createState() => _DonorFormScreenState();
}

class _DonorFormScreenState extends State<DonorFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final DonorService _donorService = DonorService();
  final MeService _meService = MeService();

  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();
  final _districtController = TextEditingController();

  String? _bloodGroup;
  DateTime? _lastDonateDate;
  bool _isAvailable = true;
  bool _isLoading = false;
  bool _isInitialLoading = true;

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

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      setState(() {
        _isInitialLoading = false;
      });
      return;
    }

    if (widget.donor != null) {
      _fillFromDonor(widget.donor!);
    } else {
      final me = await _meService.getMe(user.uid);

      if (me != null) {
        _fillFromMe(me);
      } else {
        _nameController.text = user.displayName ?? '';
        _emailController.text = user.email ?? '';
        _phoneController.text = user.phoneNumber ?? '';
      }
    }

    if (!mounted) return;

    setState(() {
      _isInitialLoading = false;
    });
  }

  void _fillFromDonor(DonorModel donor) {
    _nameController.text = donor.name;
    _phoneController.text = donor.phone;
    _emailController.text = donor.email;
    _addressController.text = donor.address;
    _districtController.text = donor.district;
    _bloodGroup = donor.bloodGroup.isEmpty ? null : donor.bloodGroup;
    _lastDonateDate = donor.lastDonateDate;
    _isAvailable = donor.isAvailable;
  }

  void _fillFromMe(UserProfileModel me) {
    _nameController.text = me.name;
    _phoneController.text = me.phone;
    _emailController.text = me.email;
    _addressController.text = me.address;
    _bloodGroup = me.bloodGroup.isEmpty ? null : me.bloodGroup;
    _lastDonateDate = me.lastDonateDate;
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

  Future<void> _saveDonor() async {
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

      final donor = DonorModel.empty(
        uid: user.uid,
        name: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
        email: _emailController.text.trim(),
        address: _addressController.text.trim(),
        district: _districtController.text.trim(),
        bloodGroup: _bloodGroup ?? '',
        lastDonateDate: _lastDonateDate,
        isAvailable: _isAvailable,
      );

      await _donorService.saveDonorProfile(donor);

      if (!mounted) return;

      _showMessage('Donor profile saved successfully');
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
    _phoneController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _districtController.dispose();
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
      appBar: AppBar(
        title: Text(widget.donor == null ? 'Become a Donor' : 'Update Donor'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(18),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                _sectionTitle('Donor Information', Icons.volunteer_activism),
                const SizedBox(height: 14),
                CustomTextField(
                  controller: _nameController,
                  label: 'Full Name',
                  prefixIcon: Icons.person_outline,
                  validator: (value) =>
                      Validators.requiredField(value, 'Full name'),
                ),
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
                _multiLineField(
                  controller: _addressController,
                  label: 'Address',
                  icon: Icons.location_on_outlined,
                  validator: (value) =>
                      Validators.requiredField(value, 'Address'),
                ),
                const SizedBox(height: 14),
                CustomTextField(
                  controller: _districtController,
                  label: 'District',
                  prefixIcon: Icons.map_outlined,
                  validator: (value) =>
                      Validators.requiredField(value, 'District'),
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
                _datePicker(),
                const SizedBox(height: 14),
                _availabilitySwitch(),
                const SizedBox(height: 28),
                CustomButton(
                  text: _isLoading ? 'Saving...' : 'Save Donor Profile',
                  onPressed: _isLoading ? null : _saveDonor,
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String title, IconData icon) {
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

  Widget _datePicker() {
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

  Widget _availabilitySwitch() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: SwitchListTile(
        contentPadding: EdgeInsets.zero,
        title: const Text(
          'Available for Donation',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: const Text(
          'Turn off if you are not available right now',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        value: _isAvailable,
        activeThumbColor: AppColors.primaryGreen,
        onChanged: (value) {
          setState(() {
            _isAvailable = value;
          });
        },
      ),
    );
  }

  Widget _multiLineField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: 3,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        filled: true,
        fillColor: Colors.white,
        alignLabelWithHint: true,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
          borderSide: BorderSide(color: AppColors.primaryTeal, width: 2),
        ),
      ),
    );
  }
}
