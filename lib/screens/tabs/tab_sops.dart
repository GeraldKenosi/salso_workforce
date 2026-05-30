import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../state/session_provider.dart';
import '../../services/workflow_service.dart';
import '../../widgets/salso_card.dart';
import '../../app/theme.dart';
import '../sops/new_sop_picker_page.dart';
import '../sops/approvals_dashboard_page.dart';
import '../sops/my_requests_page.dart';
import '../leave/leave_screen.dart';
import '../reimbursement/reimbursement_screen.dart';

class TabSOPs extends StatefulWidget {
  const TabSOPs({super.key});

  @override
  State<TabSOPs> createState() => _TabSOPsState();
}

class _TabSOPsState extends State<TabSOPs> {
  final _searchCtrl = TextEditingController();

  bool _canApprove(String role) {
    return role == 'executiveDirector' || role == 'manager' || role == 'teamLeader';
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final session = context.watch<SessionProvider>();
    final workflow = context.watch<WorkflowService>();
    final role = session.profile?.roleTemplateId ?? '';
    final canApprove = _canApprove(role);

    return Scaffold(
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          // Red header
          Container(
            decoration: const BoxDecoration(
              color: SalsoTheme.primary,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
            ),
            padding: const EdgeInsets.fromLTRB(20, 48, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Procedures', style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w600)),
                const Text('SOPs & Approvals', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                const SizedBox(height: 12),
                TextField(
                  controller: _searchCtrl,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                  decoration: InputDecoration(
                    hintText: 'Search forms...',
                    hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 14),
                    filled: true,
                    fillColor: Colors.white.withValues(alpha: 0.15),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    prefixIcon: Icon(Icons.search, color: Colors.white.withValues(alpha: 0.6), size: 20),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // New Request
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SalsoCard(
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => NewSopPickerPage(roleTemplateId: role))),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(color: SalsoTheme.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
                    child: const Icon(Icons.add_circle_outline, color: SalsoTheme.primary, size: 22),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('New Request', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                    SizedBox(height: 2),
                    Text('Start a new SOP workflow', style: TextStyle(color: Colors.grey, fontSize: 12)),
                  ])),
                  const Icon(Icons.chevron_right, color: Colors.grey),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),

          // My requests
          StreamBuilder(
            stream: workflow.streamMyRequests(),
            builder: (ctx, snap) {
              final myCount = snap.data?.length ?? 0;
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: SalsoCard(
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MyRequestsPage())),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(color: const Color(0xFF1E9CCC).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
                        child: const Icon(Icons.assignment, color: Color(0xFF1E9CCC), size: 22),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text('My Requests', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                        SizedBox(height: 2),
                        Text('Forms you have submitted', style: TextStyle(color: Colors.grey, fontSize: 12)),
                      ])),
                      if (myCount > 0)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(color: SalsoTheme.primary, borderRadius: BorderRadius.circular(12)),
                          child: Text('$myCount', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 11)),
                        ),
                      const SizedBox(width: 8),
                      const Icon(Icons.chevron_right, color: Colors.grey),
                    ],
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 10),

          // Approvals
          if (canApprove)
            StreamBuilder(
              stream: workflow.streamPendingApprovals(),
              builder: (ctx, snap) {
                final pendingCount = snap.data?.length ?? 0;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: SalsoCard(
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ApprovalsDashboardPage())),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(color: const Color(0xFF0FA65A).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
                          child: const Icon(Icons.verified_outlined, color: Color(0xFF0FA65A), size: 22),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text('Approvals', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                          SizedBox(height: 2),
                          Text('Pending review items', style: TextStyle(color: Colors.grey, fontSize: 12)),
                        ])),
                        if (pendingCount > 0)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(color: SalsoTheme.primary, borderRadius: BorderRadius.circular(12)),
                            child: Text('$pendingCount', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 11)),
                          ),
                        const SizedBox(width: 8),
                        const Icon(Icons.chevron_right, color: Colors.grey),
                      ],
                    ),
                  ),
                );
              },
            ),
          if (canApprove) const SizedBox(height: 10),

          // Legacy items
          _legacyItem(context, Icons.event_available_outlined, 'Leave Requests', 'Apply and track leave', const Color(0xFFE5D300), () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LeaveScreen()))),
          const SizedBox(height: 10),
          _legacyItem(context, Icons.receipt_long_outlined, 'Reimbursements', 'Submit claims and track', const Color(0xFF1E9CCC), () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ReimbursementScreen()))),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _legacyItem(BuildContext context, IconData icon, String title, String subtitle, Color color, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SalsoCard(
        onTap: onTap,
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
              SizedBox(height: 2),
              Text(subtitle, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
            ])),
            const Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
