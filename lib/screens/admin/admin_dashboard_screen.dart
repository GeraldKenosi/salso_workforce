import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../state/session_provider.dart';
import '../../widgets/salso_card.dart';
import '../../app/theme.dart';
import '../reports/reports_menu_page.dart';
import '../manager/team_attendance_screen.dart';
import '../hr/hr_home_page.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final session = context.watch<SessionProvider>();
    final name = session.profile?.fullName ?? 'Administrator';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => session.signOut(),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SalsoCard(
            child: Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: SalsoTheme.secondary,
                  child: Text(name[0].toUpperCase(), style: const TextStyle(color: Colors.white, fontSize: 20)),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                    const Text('Administrator', style: TextStyle(color: Colors.grey, fontSize: 13)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          SalsoCard(
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const HrHomePage())),
            child: const ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(Icons.badge_outlined),
              title: Text('HR Management', style: TextStyle(fontWeight: FontWeight.w600)),
              trailing: Icon(Icons.chevron_right),
            ),
          ),
          SalsoCard(
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TeamAttendanceScreen())),
            child: const ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(Icons.people),
              title: Text('Attendance Overview', style: TextStyle(fontWeight: FontWeight.w600)),
              trailing: Icon(Icons.chevron_right),
            ),
          ),
          SalsoCard(
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ReportsMenuPage())),
            child: const ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(Icons.description),
              title: Text('Reports', style: TextStyle(fontWeight: FontWeight.w600)),
              trailing: Icon(Icons.chevron_right),
            ),
          ),
        ],
      ),
    );
  }
}
