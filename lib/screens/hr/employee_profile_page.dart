import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../models/user_profile.dart';
import '../../utils/display_labels.dart';
import '../../widgets/salso_card.dart';
import '../../app/theme.dart';

class EmployeeProfilePage extends StatelessWidget {
  final String userId;
  const EmployeeProfilePage({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Employee Profile')),
      body: FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        future: FirebaseFirestore.instance.collection('users').doc(userId).get(),
        builder: (ctx, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError || !snap.hasData || !snap.data!.exists) {
            return const Center(child: Text('Profile not found'));
          }

          final data = snap.data!.data() ?? {};
          final profile = UserProfile.fromMap(userId, data);
          final roleLabel = DisplayLabels.roleLabel(profile.roleTemplateId);

          return ListView(
            padding: EdgeInsets.zero,
            children: [
              Container(
                decoration: const BoxDecoration(
                  color: SalsoTheme.primary,
                  borderRadius: BorderRadius.zero,
                ),
                padding: const EdgeInsets.fromLTRB(60, 48, 20, 24),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundColor: Colors.white.withValues(alpha: 0.2),
                      child: Text(
                        profile.fullName.isNotEmpty ? profile.fullName[0].toUpperCase() : '?',
                        style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(profile.fullName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                          Text(profile.email, style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 13)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: SalsoCard(
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                  child: Row(
                    children: [
                      _statItem('Status', profile.status.isNotEmpty ? '${profile.status[0].toUpperCase()}${profile.status.substring(1)}' : '-'),
                      Container(width: 1, height: 30, color: Colors.grey[200]),
                      _statItem('Role', roleLabel),
                      Container(width: 1, height: 30, color: Colors.grey[200]),
                      _statItem('Dept', DisplayLabels.departmentLabel(profile.programmeId)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
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
                      _row(Icons.flag_outlined, 'Status', profile.status),
                      if (profile.idNumber != null && profile.idNumber!.isNotEmpty) ...[
                        const Divider(height: 1),
                        _row(Icons.fingerprint, 'ID Number', profile.idNumber!),
                      ],
                      const Divider(height: 1),
                      _row(Icons.group_outlined, 'Department', DisplayLabels.departmentLabel(profile.programmeId)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: SalsoCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Contact", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                      const SizedBox(height: 8),
                      _row(Icons.phone, 'Phone', (profile.phoneNumber ?? '').isNotEmpty ? profile.phoneNumber! : 'Not set'),
                      const Divider(height: 1),
                      _row(Icons.home, 'Address', (profile.physicalAddress ?? '').isNotEmpty ? profile.physicalAddress! : 'Not set'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: SalsoCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Next of Kin", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                      const SizedBox(height: 8),
                      _row(Icons.person, 'Name', (profile.nextOfKinName ?? '').isNotEmpty ? profile.nextOfKinName! : 'Not set'),
                      const Divider(height: 1),
                      _row(Icons.phone, 'Phone', (profile.nextOfKinPhone ?? '').isNotEmpty ? profile.nextOfKinPhone! : 'Not set'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          );
        },
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
