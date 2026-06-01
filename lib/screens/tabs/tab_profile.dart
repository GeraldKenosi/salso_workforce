import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../state/session_provider.dart';
import '../../utils/display_labels.dart';
import '../../widgets/salso_card.dart';
import '../../app/theme.dart';
import '../profile/edit_profile_page.dart';
import '../documents/documents_screen.dart';
import '../notifications/notifications_screen.dart';
import '../resources/resources_screen.dart';

class TabProfile extends StatelessWidget {
  const TabProfile({super.key});

  @override
  Widget build(BuildContext context) {
    final session = context.watch<SessionProvider>();
    final name = session.profile?.fullName ?? "";
    final email = session.profile?.email ?? "";
    final roleCode = session.profile?.roleTemplateId ?? "";
    final status = session.profile?.status ?? "";
    final phone = session.profile?.phoneNumber ?? "";
    final address = session.profile?.physicalAddress ?? "";
    final idNumber = session.profile?.idNumber ?? "";
    final nokName = session.profile?.nextOfKinName ?? "";
    final nokPhone = session.profile?.nextOfKinPhone ?? "";
    final roleLabel = DisplayLabels.roleLabel(roleCode);

    return Scaffold(
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          // Red header (same style as home)
          Container(
            decoration: const BoxDecoration(
              color: SalsoTheme.primary,
              borderRadius: BorderRadius.zero,
            ),
            padding: const EdgeInsets.fromLTRB(20, 48, 20, 24),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: Colors.white.withValues(alpha: 0.2),
                  child: Text(name.isNotEmpty ? name[0].toUpperCase() : '?', style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                      Text(email, style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 13)),
                    ],
                  ),
                ),
                Container(
                  decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(12)),
                  child: IconButton(
                    icon: const Icon(Icons.edit, color: Colors.white, size: 20),
                    onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const EditProfilePage())),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Stats row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SalsoCard(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
              child: Row(
                children: [
                  _statItem('Status', status.isNotEmpty ? status[0].toUpperCase() + status.substring(1) : '-'),
                  Container(width: 1, height: 30, color: Colors.grey[200]),
                  _statItem('Role', roleLabel),
                  Container(width: 1, height: 30, color: Colors.grey[200]),
                  _statItem('Reports', '0'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),

          // Personal info
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SalsoCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Personal Information", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                  const SizedBox(height: 8),
                  _row(Icons.badge_outlined, 'Role', roleLabel),
                  const Divider(height: 1),
                  _row(Icons.flag_outlined, 'Status', status),
                  if (idNumber.isNotEmpty) ...[
                    const Divider(height: 1),
                    _row(Icons.fingerprint, 'ID Number', idNumber),
                  ],
                  const Divider(height: 1),
                  _row(Icons.group_outlined, 'Department', DisplayLabels.departmentLabel(session.profile?.programmeId)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),

          // Contact
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SalsoCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Contact", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                  const SizedBox(height: 8),
                  _row(Icons.phone, 'Phone', phone.isNotEmpty ? phone : 'Not set'),
                  const Divider(height: 1),
                  _row(Icons.home, 'Address', address.isNotEmpty ? address : 'Not set'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),

          // Next of Kin
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SalsoCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Next of Kin", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                  const SizedBox(height: 8),
                  _row(Icons.person, 'Name', nokName.isNotEmpty ? nokName : 'Not set'),
                  const Divider(height: 1),
                  _row(Icons.phone, 'Phone', nokPhone.isNotEmpty ? nokPhone : 'Not set'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),

          // Quick links
          _linkCard(context, Icons.edit_outlined, 'Edit Profile', SalsoTheme.primary, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const EditProfilePage()))),
          const SizedBox(height: 8),
          _linkCard(context, Icons.notifications_outlined, 'Notifications', const Color(0xFFE5D300), () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationsScreen()))),
          const SizedBox(height: 8),
          _linkCard(context, Icons.upload_file, 'My Documents', const Color(0xFF1E9CCC), () => Navigator.push(context, MaterialPageRoute(builder: (_) => const DocumentsScreen()))),
          const SizedBox(height: 8),
          _linkCard(context, Icons.library_books_outlined, 'Resources', const Color(0xFF0FA65A), () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ResourcesScreen()))),
          const SizedBox(height: 8),

          // Sign out
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: SalsoCard(
              onTap: () => session.signOut(),
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.logout, color: SalsoTheme.primary, size: 18),
                  const SizedBox(width: 8),
                  Text('Sign Out', style: TextStyle(color: SalsoTheme.primary, fontWeight: FontWeight.w600, fontSize: 14)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _linkCard(BuildContext context, IconData icon, String title, Color color, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SalsoCard(
        onTap: onTap,
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14))),
            const Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _statItem(String label, String value) {
    return Expanded(
      child: Column(
        children: [
          Text(value, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.grey[800])),
          const SizedBox(height: 2),
          Text(label, style: TextStyle(color: Colors.grey[500], fontSize: 11)),
        ],
      ),
    );
  }

  Widget _row(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.grey[600]),
          const SizedBox(width: 12),
          SizedBox(width: 80, child: Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 13))),
          Expanded(child: Text(value, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13))),
        ],
      ),
    );
  }
}
