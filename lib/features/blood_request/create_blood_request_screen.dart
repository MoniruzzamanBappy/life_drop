import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_form_options.dart';
import '../../core/services/blood_request_service.dart';
import '../../core/utils/validators.dart';
import '../../models/blood_request_model.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_dropdown_field.dart';
import '../../widgets/custom_text_field.dart';

class CreateBloodRequestScreen extends StatefulWidget {
  const CreateBloodRequestScreen({super.key});

  @override
  State<CreateBloodRequestScreen> createState() =>
      _CreateBloodRequestScreenState();
}

class _CreateBloodRequestScreenState extends State<CreateBloodRequestScreen> {
  final _formKey = GlobalKey<FormState>();
  final BloodRequestService _service = BloodRequestService();

  final _patientNameController = TextEditingController();
  final _unitsNeededController = TextEditingController(text: '1');
  final _hospitalAddressController = TextEditingController();
  final _contactNameController = TextEditingController();
  final _contactPhoneController = TextEditingController();
  final _reasonController = TextEditingController();

  String? _bloodGroup;
  String? _district;
  String? _hospitalName;
  String? _urgency = 'normal';

  DateTime? _neededDate;
  bool _isLoading = false;

  List<String> get _hospitalOptions {
    return AppFormOptions.hospitalsForDistrict(_district);
  }

  void _onDistrictChanged(String? value) {
    setState(() {
      _district = value;
      _hospitalName = null;
      _hospitalAddressController.clear();
    });
  }

  void _onHospitalChanged(String? value) {
    setState(() {
      _hospitalName = value;
      _hospitalAddressController.text = AppFormOptions.defaultHospitalAddress(
        district: _district,
        hospital: value,
      );
    });
  }

  Future<void> _pickNeededDate() async {
    final now = DateTime.now();

    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _neededDate ?? now,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
    );

    if (pickedDate == null) return;

    setState(() {
      _neededDate = pickedDate;
    });
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Select needed date';

    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();

    return '$day-$month-$year';
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_neededDate == null) {
      _showMessage('Needed date is required', isError: true);
      return;
    }

    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      _showMessage('User not logged in', isError: true);
      return;
    }

    try {
      setState(() {
        _isLoading = true;
      });

      final request = BloodRequestModel(
        id: '',
        requesterUid: user.uid,
        patientName: _patientNameController.text.trim(),
        bloodGroup: _bloodGroup ?? '',
        unitsNeeded: int.tryParse(_unitsNeededController.text.trim()) ?? 1,
        hospitalName: _hospitalName ?? '',
        hospitalAddress: _hospitalAddressController.text.trim(),
        district: _district ?? '',
        contactName: _contactNameController.text.trim(),
        contactPhone: _contactPhoneController.text.trim(),
        neededDate: _neededDate,
        urgency: _urgency ?? 'normal',
        reason: _reasonController.text.trim(),
        status: 'open',
        createdAt: null,
        updatedAt: null,
      );

      await _service.createBloodRequest(request);

      if (!mounted) return;

      _showMessage('Blood request created successfully');
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
    _patientNameController.dispose();
    _unitsNeededController.dispose();
    _hospitalAddressController.dispose();
    _contactNameController.dispose();
    _contactPhoneController.dispose();
    _reasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hospitalItems = _hospitalOptions;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Create Blood Request')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(18),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                _sectionTitle('Patient Information', Icons.person_outline),
                const SizedBox(height: 14),

                CustomTextField(
                  controller: _patientNameController,
                  label: 'Patient Name',
                  prefixIcon: Icons.person_outline,
                  validator: (value) =>
                      Validators.requiredField(value, 'Patient name'),
                ),

                const SizedBox(height: 14),

                CustomDropdownField(
                  label: 'Blood Group',
                  value: _bloodGroup,
                  prefixIcon: Icons.bloodtype,
                  items: AppFormOptions.bloodGroups,
                  validator: (value) =>
                      Validators.requiredField(value, 'Blood group'),
                  onChanged: (value) {
                    setState(() {
                      _bloodGroup = value;
                    });
                  },
                ),

                const SizedBox(height: 14),

                CustomTextField(
                  controller: _unitsNeededController,
                  label: 'Units Needed',
                  prefixIcon: Icons.numbers,
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Units needed is required';
                    }

                    final units = int.tryParse(value.trim());

                    if (units == null || units <= 0) {
                      return 'Enter a valid number';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 24),

                _sectionTitle('Hospital Information', Icons.local_hospital),
                const SizedBox(height: 14),

                CustomDropdownField(
                  label: 'District',
                  value: _district,
                  prefixIcon: Icons.map_outlined,
                  items: AppFormOptions.districts,
                  validator: (value) =>
                      Validators.requiredField(value, 'District'),
                  onChanged: _onDistrictChanged,
                ),

                const SizedBox(height: 14),

                CustomDropdownField(
                  label: 'Hospital',
                  value: _hospitalName,
                  prefixIcon: Icons.local_hospital_outlined,
                  items: hospitalItems,
                  validator: (value) =>
                      Validators.requiredField(value, 'Hospital'),
                  onChanged: _district == null ? (_) {} : _onHospitalChanged,
                ),

                const SizedBox(height: 14),

                _multiLineField(
                  controller: _hospitalAddressController,
                  label: _hospitalName == 'Other'
                      ? 'Hospital Name / Address'
                      : 'Hospital Address',
                  icon: Icons.location_on_outlined,
                  validator: (value) =>
                      Validators.requiredField(value, 'Hospital address'),
                ),

                const SizedBox(height: 24),

                _sectionTitle('Contact Information', Icons.phone_outlined),
                const SizedBox(height: 14),

                CustomTextField(
                  controller: _contactNameController,
                  label: 'Contact Name',
                  prefixIcon: Icons.person_pin_outlined,
                  validator: (value) =>
                      Validators.requiredField(value, 'Contact name'),
                ),

                const SizedBox(height: 14),

                CustomTextField(
                  controller: _contactPhoneController,
                  label: 'Contact Phone',
                  prefixIcon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                  validator: Validators.phone,
                ),

                const SizedBox(height: 24),

                _sectionTitle('Request Details', Icons.info_outline),
                const SizedBox(height: 14),

                _datePicker(),

                const SizedBox(height: 14),

                CustomDropdownField(
                  label: 'Urgency',
                  value: _urgency,
                  prefixIcon: Icons.priority_high,
                  items: AppFormOptions.urgencies,
                  validator: (value) =>
                      Validators.requiredField(value, 'Urgency'),
                  onChanged: (value) {
                    setState(() {
                      _urgency = value;
                    });
                  },
                ),

                const SizedBox(height: 14),

                _multiLineField(
                  controller: _reasonController,
                  label: 'Reason',
                  icon: Icons.notes_outlined,
                  validator: (value) =>
                      Validators.requiredField(value, 'Reason'),
                ),

                const SizedBox(height: 28),

                CustomButton(
                  text: _isLoading ? 'Creating...' : 'Create Request',
                  onPressed: _isLoading ? null : _submit,
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
      onTap: _pickNeededDate,
      borderRadius: BorderRadius.circular(16),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: 'Needed Date',
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
          _formatDate(_neededDate),
          style: TextStyle(
            color: _neededDate == null
                ? AppColors.textSecondary
                : AppColors.textPrimary,
            fontWeight: FontWeight.w500,
          ),
        ),
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
