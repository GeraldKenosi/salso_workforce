import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../state/session_provider.dart';
import '../../screens/manager/team_reports_screen.dart';
import '../../screens/reports/approvals_page.dart';
import '../../screens/reports/create_report_screen.dart';
import '../../screens/tabs/tab_reports.dart';
import '../../widgets/salso_card.dart';
import '../../widgets/salso_app_bar.dart';

class ReportsMenuPage extends StatelessWidget {
  const ReportsMenuPage({super.key});

  bool _canSeeManagementReports(String role) {
    return role == 'executiveDirector' ||
        role == 'manager' ||
        role == 'teamLeader' ||
        role == 'admin';
  }

  @override
  Widget build(BuildContext context) {
    final session = context.watch<SessionProvider>();
    final role = session.profile?.roleTemplateId ?? '';
    final canManage = _canSeeManagementReports(role);

    return Scaffold(
      appBar: SalsoAppBar(
        title: const Text("Reports", style: TextStyle(color: Colors.white)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SalsoCard(
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CreateReportScreen())),
            child: const ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(Icons.add_circle_outline),
              title: Text('Create Report', style: TextStyle(fontWeight: FontWeight.w600)),
              subtitle: Text('Submit a new activity report'),
              trailing: Icon(Icons.chevron_right),
            ),
          ),
          const SizedBox(height: 8),
          SalsoCard(
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TabReports())),
            child: const ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(Icons.description_outlined),
              title: Text('My Reports', style: TextStyle(fontWeight: FontWeight.w600)),
              subtitle: Text('View your submitted reports'),
              trailing: Icon(Icons.chevron_right),
            ),
          ),
          if (canManage) ...[
            const SizedBox(height: 8),
            SalsoCard(
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TeamReportsScreen())),
              child: const ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(Icons.groups),
                title: Text('Team Reports', style: TextStyle(fontWeight: FontWeight.w600)),
                subtitle: Text('View reports from your team'),
                trailing: Icon(Icons.chevron_right),
              ),
            ),
            const SizedBox(height: 8),
            SalsoCard(
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ApprovalsPage())),
              child: const ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(Icons.approval_outlined),
                title: Text('Report Approvals', style: TextStyle(fontWeight: FontWeight.w600)),
                subtitle: Text('Approve or reject pending reports'),
                trailing: Icon(Icons.chevron_right),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
