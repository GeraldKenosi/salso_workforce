import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/narrative_report.dart';
import '../../services/narrative_report_service.dart';
import '../../state/session_provider.dart';
import '../../widgets/salso_card.dart';
import '../../app/theme.dart';
import '../reports/narrative/narrative_report_stepper.dart';
import '../reports/narrative/narrative_report_list_page.dart';
import '../reports/report_analytics_page.dart';

class TabReports extends StatelessWidget {
  const TabReports({super.key});

  @override
  Widget build(BuildContext context) {
    final narrativeService = context.watch<NarrativeReportService>();
    final session = context.watch<SessionProvider>();
    final role = session.profile?.roleTemplateId ?? '';

    return Scaffold(
      body: StreamBuilder(
        stream: narrativeService.streamMyReports(),
        builder: (ctx, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text('Error: ${snap.error}', textAlign: TextAlign.center, style: const TextStyle(color: Colors.red)),
              ),
            );
          }
          final data = snap.data;
          final List<NarrativeReport> reports = (data is List<NarrativeReport>) ? data : [];

          final submitted = reports.where((r) => r.status == 'submitted').length;
          final approved = reports.where((r) => r.status == 'approved' || r.status == 'signed_off').length;
          final drafts = reports.where((r) => r.status == 'draft').toList();
          final isEmpty = reports.isEmpty;

          return ListView(
            padding: EdgeInsets.zero,
            children: [
              // Red header
              redHeader(context, session, narrativeService),

              // Metric cards
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    Expanded(child: _metricCard('Submitted', submitted, const Color(0xFF1E9CCC), Icons.send)),
                    const SizedBox(width: 10),
                    Expanded(child: _metricCard('Approved', approved, const Color(0xFF0FA65A), Icons.check_circle)),
                  ],
                ),
              ),

              if (isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 40),
                    child: Column(
                      children: [
                        Icon(Icons.description_outlined, size: 56, color: Colors.grey[300]),
                        const SizedBox(height: 16),
                        Text('No reports yet', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.grey[700])),
                        const SizedBox(height: 8),
                        Text('Tap + to create your first report', style: TextStyle(color: Colors.grey[500], fontSize: 13)),
                      ],
                    ),
                  ),
                ),

              // Drafts
              if (drafts.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: SalsoCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(width: 8, height: 8, decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.orange)),
                            const SizedBox(width: 6),
                            Text('Drafts (${drafts.length})', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                          ],
                        ),
                        const SizedBox(height: 6),
                        ...drafts.map((r) => ListTile(
                          dense: true,
                          contentPadding: EdgeInsets.zero,
                          title: Text(r.activityName.isNotEmpty ? r.activityName : '(Untitled)', style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13)),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.arrow_forward, size: 18, color: SalsoTheme.primary),
                                onPressed: () => Navigator.push(ctx, MaterialPageRoute(builder: (_) => const NarrativeReportStepper())),
                              ),
                            ],
                          ),
                        )),
                      ],
                    ),
                  ),
                ),
              if (drafts.isNotEmpty) const SizedBox(height: 8),

              // All reports link
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: SalsoCard(
                  onTap: () => Navigator.push(ctx, MaterialPageRoute(builder: (_) => const NarrativeReportListPage())),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(color: SalsoTheme.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                        child: const Icon(Icons.list_alt, color: SalsoTheme.primary, size: 22),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text('All Reports', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                        SizedBox(height: 2),
                        Text('View full list by status', style: TextStyle(color: Colors.grey, fontSize: 12)),
                      ])),
                      const Icon(Icons.chevron_right, color: Colors.grey),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),

              // Analytics dashboard
              if (role == 'executiveDirector' || role == 'manager')
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: SalsoCard(
                    onTap: () => Navigator.push(ctx, MaterialPageRoute(builder: (_) => const ReportAnalyticsPage())),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(color: const Color(0xFF1E9CCC).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                          child: const Icon(Icons.analytics_outlined, color: Color(0xFF1E9CCC), size: 22),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text('Analytics Dashboard', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                          SizedBox(height: 2),
                          Text('Monthly programme metrics', style: TextStyle(color: Colors.grey, fontSize: 12)),
                        ])),
                        const Icon(Icons.chevron_right, color: Colors.grey),
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

  Widget redHeader(BuildContext context, SessionProvider session, NarrativeReportService narrativeService) {
    return Container(
      decoration: const BoxDecoration(
        color: SalsoTheme.primary,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(20, 48, 20, 20),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Reports', style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 12, fontWeight: FontWeight.w600)),
                Text("Your Reports", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(12)),
            child: IconButton(
              icon: const Icon(Icons.add, color: Colors.white),
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NarrativeReportStepper())),
            ),
          ),
        ],
      ),
    );
  }

  Widget _metricCard(String label, int count, Color color, IconData icon) {
    return SalsoCard(
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('$count', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.grey[800])),
              Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }
}
