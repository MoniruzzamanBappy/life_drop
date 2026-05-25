import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/services/me_service.dart';
import '../../models/user_profile_model.dart';
import '../../widgets/common_header.dart';
import '../profile/update_profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.onTabChange});

  final void Function(int index) onTabChange;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final MeService _meService = MeService();

  bool _hideProfileBanner = false;

  User? get _currentUser => FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    final user = _currentUser;

    if (user == null) {
      return const Scaffold(body: Center(child: Text('User not logged in')));
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: StreamBuilder<UserProfileModel?>(
        stream: _meService.watchMe(user.uid),
        builder: (context, snapshot) {
          UserProfileModel profile;

          if (snapshot.data == null) {
            profile = UserProfileModel.empty(
              uid: user.uid,
              name: user.displayName ?? '',
              email: user.email ?? '',
              phone: user.phoneNumber ?? '',
              photo: user.photoURL ?? '',
            );

            _meService.createMeIfNotExists(profile);
          } else {
            profile = snapshot.data!;
          }

          return Column(
            children: [
              CommonHeader(
                title: profile.name.isEmpty ? 'Welcome Donor' : profile.name,
                subtitle: profile.email.isEmpty
                    ? 'Donate a drop, save a life.'
                    : profile.email,
                imageUrl: profile.photo,
                actions: [
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(
                      Icons.notifications_none,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () async {
                    setState(() {});
                  },
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      if (snapshot.connectionState == ConnectionState.waiting)
                        const LinearProgressIndicator(),

                      if (!profile.isProfileComplete && !_hideProfileBanner)
                        _buildCompleteProfileCard(profile),

                      if (!profile.isProfileComplete && !_hideProfileBanner)
                        const SizedBox(height: 16),

                      _buildQuickStats(profile),

                      const SizedBox(height: 16),

                      const Text(
                        'Menus',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),

                      const SizedBox(height: 12),

                      GridView.count(
                        crossAxisCount: 2,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        mainAxisSpacing: 14,
                        crossAxisSpacing: 14,
                        childAspectRatio: 1.15,
                        children: [
                          _menuCard(
                            title: 'My Profile',
                            subtitle: 'View profile details',
                            icon: Icons.person_outline,
                            color: AppColors.primaryTeal,
                            onTap: () {
                              widget.onTabChange(3);
                            },
                          ),
                          _menuCard(
                            title: 'Find Donors',
                            subtitle: 'Search nearby donors',
                            icon: Icons.people_outline,
                            color: AppColors.primaryGreen,
                            onTap: () {
                              widget.onTabChange(1);
                            },
                          ),
                          _menuCard(
                            title: 'Blood Request',
                            subtitle: 'Create or view requests',
                            icon: Icons.bloodtype_outlined,
                            color: AppColors.danger,
                            onTap: () {
                              widget.onTabChange(2);
                            },
                          ),
                          _menuCard(
                            title: 'Donation History',
                            subtitle: 'Coming soon',
                            icon: Icons.history,
                            color: AppColors.primaryTeal,
                            onTap: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Donation History will be added soon',
                                  ),
                                ),
                              );
                            },
                          ),
                          _menuCard(
                            title: 'Health Info',
                            subtitle: 'View health screening',
                            icon: Icons.health_and_safety_outlined,
                            color: AppColors.primaryGreen,
                            onTap: () {
                              widget.onTabChange(3);
                            },
                          ),
                          _menuCard(
                            title: 'Settings',
                            subtitle: 'Account settings',
                            icon: Icons.settings_outlined,
                            color: AppColors.textSecondary,
                            onTap: () {
                              widget.onTabChange(4);
                            },
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCompleteProfileCard(UserProfileModel profile) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.arrow_forward, color: AppColors.primaryTeal),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Complete your profile',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 17,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              InkWell(
                onTap: () {
                  setState(() {
                    _hideProfileBanner = true;
                  });
                },
                child: const Icon(Icons.close, color: AppColors.textSecondary),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Add your address, blood group, last donation date and health screening information.',
              style: TextStyle(color: AppColors.textSecondary, height: 1.4),
            ),
          ),
          // const SizedBox(height: 10),
          // if (profile.missingFields.isNotEmpty)
          //   Align(
          //     alignment: Alignment.centerLeft,
          //     child: Text(
          //       'Missing: ${profile.missingFields.join(', ')}',
          //       style: const TextStyle(
          //         color: AppColors.textPrimary,
          //         fontSize: 13,
          //         fontWeight: FontWeight.w600,
          //       ),
          //     ),
          //   ),
          const SizedBox(height: 14),
          Align(
            alignment: Alignment.centerLeft,
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => UpdateProfileScreen(profile: profile),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryGreen,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text('Update profile'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStats(UserProfileModel profile) {
    return Row(
      children: [
        Expanded(
          child: _statCard(
            title: 'Blood Group',
            value: profile.bloodGroup.isEmpty ? 'N/A' : profile.bloodGroup,
            icon: Icons.bloodtype,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _statCard(
            title: 'Profile',
            value: profile.isProfileComplete ? 'Complete' : 'Incomplete',
            icon: Icons.verified_user_outlined,
          ),
        ),
      ],
    );
  }

  Widget _statCard({
    required String title,
    required String value,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            height: 42,
            width: 42,
            decoration: BoxDecoration(
              color: AppColors.lightTeal,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: AppColors.primaryTeal),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _menuCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.border),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0D000000),
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
                color: color.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Icon(icon, color: color, size: 26),
            ),
            const Spacer(),
            Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              subtitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
