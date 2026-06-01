import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../state/session_provider.dart';
import '../../services/attendance_service.dart';
import '../../services/workflow_service.dart';
import '../../widgets/salso_card.dart';
import '../../app/theme.dart';
import '../attendance/my_attendance_history_page.dart';
import '../reports/narrative/narrative_report_list_page.dart';
import '../sops/approvals_dashboard_page.dart';
import '../sops/my_requests_page.dart';
import '../notifications/notifications_screen.dart';

class TabHome extends StatelessWidget {
  const TabHome({super.key});

  String _greeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good morning';
    if (h < 17) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context) {
    final session = context.watch<SessionProvider>();
    final attendance = context.watch<AttendanceService>();
    final workflow = context.watch<WorkflowService>();

    final name = (session.profile?.fullName ?? '').split(' ').firstOrNull ?? '';
    final uid = session.firebaseUser?.uid ?? '';
    final clockedIn = uid.isNotEmpty && attendance.isCurrentlyClockedIn(uid);
    final role = session.profile?.roleTemplateId ?? '';
    final isEdOrManager = role == 'executiveDirector' || role == 'manager';

    return Scaffold(
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          // Red header
          Container(
            decoration: const BoxDecoration(
              color: SalsoTheme.primary,
              borderRadius: BorderRadius.zero,
            ),
            padding: const EdgeInsets.fromLTRB(60, 48, 20, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${_greeting()}, ${name.isNotEmpty ? name : 'there'}',
                            style: const TextStyle(color: Colors.white70, fontSize: 14),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            session.profile?.fullName ?? '',
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
                          ),
                        ],
                      ),
                    ),
                    NotificationBadge(count: 3),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(
                      clockedIn ? Icons.check_circle : Icons.access_time,
                      color: clockedIn ? Colors.greenAccent : Colors.white70,
                      size: 16,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      clockedIn ? 'Clocked in' : 'Not clocked in',
                      style: TextStyle(color: clockedIn ? Colors.greenAccent : Colors.white70, fontSize: 13),
                    ),
                    const Spacer(),
                    Text(
                      DateTime.now().toString().substring(0, 10),
                      style: const TextStyle(color: Colors.white60, fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Quick actions
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(child: QuickActionTile(icon: Icons.access_time, label: 'Attendance', color: const Color(0xFF1E9CCC), onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MyAttendanceHistoryPage())))),
                const SizedBox(width: 10),
                Expanded(child: QuickActionTile(icon: Icons.description, label: 'Reports', color: const Color(0xFF0FA65A), onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NarrativeReportListPage())))),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(child: QuickActionTile(icon: Icons.assignment, label: 'My Requests', color: const Color(0xFFD90429), onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MyRequestsPage())))),
                const SizedBox(width: 10),
                Expanded(child: QuickActionTile(icon: Icons.notifications, label: 'Notifications', color: const Color(0xFFE5D300), onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationsScreen())))),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Pending approvals
          if (isEdOrManager) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  const Icon(Icons.approval, size: 16, color: Colors.black87),
                  const SizedBox(width: 6),
                  const Text('Pending Approvals', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: Colors.black87)),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ApprovalsDashboardPage())),
                    child: const Text('See all', style: TextStyle(color: SalsoTheme.primary, fontSize: 12, fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            StreamBuilder(
              stream: workflow.streamPendingApprovals(),
              builder: (ctx, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return const Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: SalsoCard(child: SizedBox(height: 60, child: Center(child: CircularProgressIndicator(strokeWidth: 2)))));
                }
                final data = snap.data ?? [];
                final items = data.take(2).toList();
                if (items.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: SalsoCard(child: Row(children: [Icon(Icons.check_circle_outline, color: Colors.grey[400], size: 20), const SizedBox(width: 8), Text('All caught up!', style: TextStyle(color: Colors.grey[500], fontSize: 13))])),
                  );
                }
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: SalsoCard(
                    child: Column(
                      children: items.map((req) => ListTile(
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                        leading: Container(width: 8, height: 8, decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.orange)),
                        title: Text(req['title'] ?? '', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                        subtitle: Text('${req['sopType'] ?? ''} \u2022 ${req['userDisplayName'] ?? ''}', style: const TextStyle(fontSize: 11)),
                        trailing: const Icon(Icons.chevron_right, size: 18, color: Colors.grey),
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ApprovalsDashboardPage())),
                      )).toList(),
                    ),
                  ),
                );
              },
            ),
          ],
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class QuickActionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const QuickActionTile({super.key, required this.icon, required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SalsoCard(
      onTap: onTap,
      height: 80,
      padding: const EdgeInsets.all(12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 26),
          const SizedBox(height: 6),
          Text(label, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12, color: Colors.grey[800])),
        ],
      ),
    );
  }
}

class NotificationBadge extends StatelessWidget {
  final int count;
  const NotificationBadge({super.key, this.count = 0});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.notifications, color: Colors.white, size: 16),
          const SizedBox(width: 4),
          Text('$count', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 12)),
        ],
      ),
    );
  }
}
