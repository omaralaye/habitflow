import 'package:flutter/material.dart';
import '../utils/constants.dart';
import 'onboarding_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _pushNotifications = true;
  bool _darkMode = false;
  bool _weeklyDigest = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryLighter,
      appBar: AppBar(
        title: const Text('Settings'),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.textDark),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Refine your sanctuary and pace.',
              style: TextStyle(fontSize: 14, color: AppColors.textGrey),
            ),
            const SizedBox(height: 32),
            _buildSettingsGroup('Reminders', [
              _buildSettingItem(
                Icons.notifications_active_rounded,
                'Push Notifications',
                'Daily nudges to keep your flow.',
                trailing: Switch(
                  value: _pushNotifications,
                  onChanged: (v) {
                    setState(() {
                      _pushNotifications = v;
                    });
                  },
                  activeThumbColor: AppColors.primary,
                ),
              ),
              _buildSettingItem(
                Icons.nights_stay_rounded,
                'Quiet Hours',
                '10:00 PM — 07:00 AM',
                trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.textGrey),
              ),
            ]),
            const SizedBox(height: 24),
            _buildSettingsGroup('Display', [
              _buildSettingItem(
                Icons.palette_rounded,
                'Dark Mode',
                'COMING SOON',
                trailing: Switch(
                  value: _darkMode,
                  onChanged: (v) {
                    setState(() {
                      _darkMode = v;
                    });
                  },
                  activeThumbColor: AppColors.primary,
                ),
              ),
            ]),
            const SizedBox(height: 24),
            _buildSettingsGroup('Stats', [
              _buildSettingItem(
                Icons.auto_graph_rounded,
                'Weekly Digest',
                '',
                trailing: Switch(
                  value: _weeklyDigest,
                  onChanged: (v) {
                    setState(() {
                      _weeklyDigest = v;
                    });
                  },
                  activeThumbColor: AppColors.primary,
                ),
              ),
            ]),
            const SizedBox(height: 24),
            _buildSettingsGroup('Account', [
              _buildSettingItem(
                Icons.email_rounded,
                'EMAIL ADDRESS',
                'alex.flow@example.com',
                trailing: const Icon(Icons.edit_rounded, size: 18, color: AppColors.textGrey),
              ),
              _buildSettingItem(
                Icons.security_rounded,
                'SECURITY',
                'Two-Factor Auth',
                trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.textGrey),
              ),
            ]),
            const SizedBox(height: 48),
            _buildSignOutButton(context),
            const SizedBox(height: 48),
            const Center(
              child: Column(
                children: [
                  Text(
                    'HABIT FLOW V2.4.0',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textGrey,
                      letterSpacing: 2,
                    ),
                  ),
                  SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Privacy Policy', style: TextStyle(fontSize: 12, color: AppColors.primary, fontWeight: FontWeight.w600)),
                      SizedBox(width: 24),
                      Text('Terms of Service', style: TextStyle(fontSize: 12, color: AppColors.primary, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsGroup(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8.0, bottom: 12.0),
          child: Row(
            children: [
              const Icon(Icons.circle, size: 8, color: AppColors.primary),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            children: List.generate(children.length, (index) {
              return Column(
                children: [
                  children[index],
                  if (index < children.length - 1)
                    Divider(height: 1, color: AppColors.primaryLighter),
                ],
              );
            }),
          ),
        ),
      ],
    );
  }

  Widget _buildSettingItem(IconData icon, String title, String subtitle, {required Widget trailing}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primaryLighter,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppColors.primary, size: 22),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                  ),
                ),
                if (subtitle.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textGrey,
                    ),
                  ),
                ],
              ],
            ),
          ),
          trailing,
        ],
      ),
    );
  }

  Widget _buildSignOutButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: ElevatedButton(
        onPressed: () {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const OnboardingScreen()),
            (route) => false,
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryLighter.withOpacity(0.5),
          foregroundColor: AppColors.accentRed,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        ),
        child: const Text(
          'Sign Out',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
