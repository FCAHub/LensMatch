import 'package:flutter/material.dart';
import 'reservations_view.dart';
import 'account_details_view.dart';
import 'scan_history_view.dart';
import 'notifications_view.dart';
import 'help_support_view.dart';
import 'login_view.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Profile', style: textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 32),
            
            // Premium Centered Profile Header
            Center(
              child: Column(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: colorScheme.primary, width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: colorScheme.primary.withValues(alpha: 0.15),
                          blurRadius: 24,
                          spreadRadius: 4,
                        ),
                      ],
                    ),
                    child: CircleAvatar(
                      radius: 52,
                      backgroundColor: const Color(0xFF141414), // bgCard
                      child: Text('JD', style: textTheme.displaySmall?.copyWith(color: colorScheme.primary, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text('John Doe', style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text('johndoe@example.com', style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant)),
                ],
              ),
            ),
            
            const SizedBox(height: 48),
            
            Text('ACTIVITY', style: textTheme.labelLarge?.copyWith(fontWeight: FontWeight.bold, color: colorScheme.onSurfaceVariant, letterSpacing: 1.2)),
            const SizedBox(height: 16),
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: const BorderSide(color: Color(0xFF2A2A35)),
              ),
              child: Column(
                children: [
                  _buildListTile(context, Icons.history_rounded, 'Scan History', 'View past face analysis results', onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const ScanHistoryView()));
                  }),
                  const Divider(color: Color(0xFF2A2A35), height: 1, indent: 64),
                  _buildListTile(context, Icons.calendar_today_rounded, 'My Reservations', 'Manage your reserved frames', onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const ReservationsView()));
                  }),
                ],
              ),
            ),
            
            const SizedBox(height: 32),
            Text('SETTINGS', style: textTheme.labelLarge?.copyWith(fontWeight: FontWeight.bold, color: colorScheme.onSurfaceVariant, letterSpacing: 1.2)),
            const SizedBox(height: 16),
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: const BorderSide(color: Color(0xFF2A2A35)),
              ),
              child: Column(
                children: [
                  _buildListTile(context, Icons.person_outline_rounded, 'Account Details', 'Update your personal info', onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const AccountDetailsView()));
                  }),
                  const Divider(color: Color(0xFF2A2A35), height: 1, indent: 64),
                  _buildListTile(context, Icons.notifications_none_rounded, 'Notifications', 'Manage your alerts', onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const NotificationsView()));
                  }),
                  const Divider(color: Color(0xFF2A2A35), height: 1, indent: 64),
                  _buildListTile(context, Icons.help_outline_rounded, 'Help & Support', 'Get assistance', onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const HelpSupportView()));
                  }),
                ],
              ),
            ),
            
            const SizedBox(height: 48),
            Center(
              child: TextButton.icon(
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginView()),
                    (route) => false,
                  );
                },
                icon: Icon(Icons.logout_rounded, color: colorScheme.error),
                label: Text('Log Out', style: textTheme.titleMedium?.copyWith(color: colorScheme.error, fontWeight: FontWeight.bold)),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildListTile(BuildContext context, IconData icon, String title, String subtitle, {VoidCallback? onTap}) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: colorScheme.primary.withValues(alpha: 0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: colorScheme.primary, size: 22),
      ),
      title: Text(title, style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
      subtitle: Text(subtitle, style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant)),
      trailing: Icon(Icons.chevron_right_rounded, color: colorScheme.onSurfaceVariant),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      onTap: onTap,
    );
  }
}
