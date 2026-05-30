import 'package:flutter/material.dart';
import '../../widgets/salso_card.dart';
import '../../widgets/salso_app_bar.dart';
import 'sop_detail_page.dart';

class SopLibraryPage extends StatefulWidget {
  const SopLibraryPage({super.key});

  @override
  State createState() => _SopLibraryPageState();
}

class _SopLibraryPageState extends State {
  final _searchCtrl = TextEditingController();

  final _items = const [
    _SopItem(
      id: 'attendance_clocking',
      category: 'Attendance',
      title: 'Clocking In & Out',
      summary: 'How to record attendance correctly and resolve issues.',
      content: '''
ATTENDANCE CLOCKING SOP

1. Ensure GPS/location permissions are enabled on your device.
2. Tap "Clock In" when you start your work day.
3. Tap "Clock Out" when you finish.
4. Your location is recorded for audit purposes.
5. If you forgot to clock out, submit a correction request from the Attendance tab.
6. Managers and ED can review and approve corrections.

For issues, contact your Team Leader or Admin.
''',
    ),
    _SopItem(
      id: 'leave_requests',
      category: 'Leave',
      title: 'Leave Requests',
      summary: 'How to apply for leave and get approval.',
      content: '''
LEAVE REQUEST SOP

1. Navigate to Policies tab → Leave Requests.
2. Select your leave dates and provide a reason.
3. Submit the request — it will be sent to your manager.
4. Your manager will review and approve or reject.
5. You will receive a notification of the outcome.
6. Approved leave reflects in your attendance records.

Leave types: Annual, Sick, Family Responsibility, Study.
''',
    ),
    _SopItem(
      id: 'reimbursements',
      category: 'Finance',
      title: 'Reimbursements',
      summary: 'How to submit reimbursement claims with proof.',
      content: '''
REIMBURSEMENT SOP

1. Navigate to Policies tab → Reimbursements.
2. Tap "Submit Claim" and enter the amount and description.
3. Attach receipts or proof of payment (photo/PDF).
4. Submit for approval.
5. Manager reviews and approves/rejects.
6. Approved claims are processed for payment.

Ensure receipts are clear and include vendor details.
''',
    ),
    _SopItem(
      id: 'reporting',
      category: 'Reports',
      title: 'Weekly & Daily Reporting',
      summary: 'How to create reports and submit them.',
      content: '''
REPORTING SOP

1. Navigate to Reports tab → Tap + to create a new report.
2. Select the report type (Event, Field, Feedback).
3. Enter a clear title and detailed content.
4. Submit the report — it moves from Draft to Submitted.
5. Managers/ED can review and approve.
6. Approved reports are filed to SharePoint.

Submit reports promptly after activities/events.
''',
    ),
    _SopItem(
      id: 'finance_sops',
      category: 'Finance',
      title: 'Finance SOP Requests',
      summary: 'How to request financial approvals (procurement, travel, etc.).',
      content: '''
FINANCE SOP REQUEST SOP

1. Navigate to the Finance SOPs section (from drawer if manager/ED).
2. Tap + to create a new SOP request.
3. Select the type: Petty Cash, Procurement, Travel, Event Budget, or Other.
4. Enter the amount and justification.
5. Submit — the approval chain begins:
   - Manager reviews first
   - Finance reviews (if the function exists)
   - ED gives final approval
6. Track the status updates in the app.
''',
    ),
    _SopItem(
      id: 'kpi_tracking',
      category: 'Performance',
      title: 'KPI Tracking',
      summary: 'How performance indicators are measured and tracked.',
      content: '''
KPI TRACKING SOP

1. KPIs are set per user for each quarter (e.g. 2026-Q2).
2. Metrics include: Events Attended, Reports Submitted, Training Hours.
3. Progress is updated by managers based on activity data.
4. Users can view their own KPI dashboard from Home.
5. Colour thresholds:
   - >= 100%: Green (on track)
   - >= 70%: Teal (good progress)
   - >= 40%: Amber (needs attention)
   - < 40%: Red (behind target)
6. KPIs are reviewed quarterly.
''',
    ),
  ];

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final q = _searchCtrl.text.trim().toLowerCase();

    final filtered = _items.where((x) {
      final item = x as _SopItem;
      if (q.isEmpty) return true;
      return item.title.toLowerCase().contains(q) ||
          item.category.toLowerCase().contains(q) ||
          item.summary.toLowerCase().contains(q);
    }).toList();

    return Scaffold(
      appBar: const SalsoAppBar(),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: TextField(
              controller: _searchCtrl,
              decoration: const InputDecoration(
                labelText: 'Search SOPs',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (_) => setState(() {}),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: filtered.length,
              itemBuilder: (ctx, i) {
                final item = filtered[i] as _SopItem;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: SalsoCard(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => SopDetailPage(
                            title: item.title,
                            category: item.category,
                            content: item.content,
                          ),
                        ),
                      );
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.blue.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(item.category, style: const TextStyle(color: Colors.blue, fontSize: 11, fontWeight: FontWeight.w600)),
                            ),
                            const Spacer(),
                            const Icon(Icons.chevron_right, size: 20, color: Colors.grey),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(item.title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                        const SizedBox(height: 4),
                        Text(item.summary, style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _SopItem {
  final String id;
  final String category;
  final String title;
  final String summary;
  final String content;

  const _SopItem({
    required this.id,
    required this.category,
    required this.title,
    required this.summary,
    required this.content,
  });
}
