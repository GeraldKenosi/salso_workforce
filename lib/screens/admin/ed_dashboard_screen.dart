import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../state/session_provider.dart';
import '../../widgets/salso_card.dart';
import '../../app/theme.dart';
import '../finance/finance_sop_list_screen.dart';
import '../finance/finance_sop_approvals_screen.dart';
import '../reports/reports_menu_page.dart';
import '../manager/team_attendance_screen.dart';
import '../audit/audit_log_screen.dart';
import '../kpi/kpi_dashboard_screen.dart';
import '../hr/hr_home_page.dart';

class EdDashboardScreen extends StatelessWidget {
  const EdDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final session = context.watch<SessionProvider>();
    final name = session.profile?.fullName ?? 'Executive Director';

    return Scaffold(
      appBar: AppBar(
        title: const Text('ED Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => session.signOut(),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SalsoCard(
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: SalsoTheme.primary,
                    child: Text(name[0].toUpperCase(), style: const TextStyle(color: Colors.white, fontSize: 20)),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                      const Text('Executive Director', style: TextStyle(color: Colors.grey, fontSize: 13)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            const SalsoSectionHeader(title: 'Oversight'),
            _DashboardGrid(session: session),
            const SizedBox(height: 8),
            const SalsoSectionHeader(title: 'Governance'),
            _GovernanceCards(),
            const SizedBox(height: 8),
            const SalsoSectionHeader(title: 'System'),
            _SystemCards(),
          ],
        ),
      ),
    );
  }
}

class _DashboardGrid extends StatelessWidget {
  final SessionProvider session;
  const _DashboardGrid({required this.session});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          _MetricCard(
            icon: Icons.people, label: 'Attendance', value: 'All Users',
            color: SalsoTheme.primary,
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TeamAttendanceScreen())),
          ),
          _MetricCard(
            icon: Icons.description, label: 'Reports', value: 'Pipeline',
            color: SalsoTheme.secondary,
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ReportsMenuPage())),
          ),
          _MetricCard(
            icon: Icons.receipt_long, label: 'Finance SOPs', value: 'Approvals',
            color: SalsoTheme.warning,
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const FinanceSopListScreen())),
          ),
          _MetricCard(
            icon: Icons.track_changes, label: 'KPIs', value: 'Performance',
            color: SalsoTheme.accent,
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const KpiDashboardScreen())),
          ),
        ],
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final VoidCallback onTap;

  const _MetricCard({
    required this.icon, required this.label, required this.value,
    required this.color, required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final w = (MediaQuery.of(context).size.width - 56) / 2;
    return SizedBox(
      width: w,
      child: SalsoCard(
        onTap: onTap,
        height: 100,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
            Text(value, style: TextStyle(fontWeight: FontWeight.w700, color: color, fontSize: 14)),
          ],
        ),
      ),
    );
  }
}

class _GovernanceCards extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          SalsoCard(
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const FinanceSopApprovalsScreen(approvalStep: 'ed'))),
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(Icons.account_balance, color: SalsoTheme.primary),
              title: const Text('Finance — Final Approval', style: TextStyle(fontWeight: FontWeight.w600)),
              subtitle: const Text('Authorise payments and sign off SOPs'),
              trailing: const Icon(Icons.chevron_right),
            ),
          ),
          SalsoCard(
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const HrHomePage())),
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(Icons.badge_outlined, color: SalsoTheme.secondary),
              title: const Text('HR Management', style: TextStyle(fontWeight: FontWeight.w600)),
              subtitle: const Text('Users, roles, compliance'),
              trailing: const Icon(Icons.chevron_right),
            ),
          ),
        ],
      ),
    );
  }
}

class _SystemCards extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          SalsoCard(
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AuditLogScreen())),
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(Icons.history, color: SalsoTheme.primary),
              title: const Text('Audit Log', style: TextStyle(fontWeight: FontWeight.w600)),
              subtitle: const Text('Full action trail across the system'),
              trailing: const Icon(Icons.chevron_right),
            ),
          ),
          SalsoCard(
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(Icons.settings_outlined, color: Colors.grey),
              title: const Text('System Configuration', style: TextStyle(fontWeight: FontWeight.w600)),
              subtitle: const Text('Role templates, finance mode, document visibility'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Configuration panel — coming in next update.')),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
