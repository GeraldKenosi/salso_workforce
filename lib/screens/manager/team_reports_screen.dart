import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/report.dart';
import '../../services/report_service.dart';
import '../../state/session_provider.dart';
import '../../widgets/salso_card.dart';
import '../../widgets/salso_app_bar.dart';
import '../reports/report_detail_page.dart';

class TeamReportsScreen extends StatelessWidget {
  const TeamReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final service = context.watch<ReportService>();
    final session = context.watch<SessionProvider>();
    final profile = session.profile;
    final role = profile?.roleTemplateId ?? '';
    final isEd = role == 'executiveDirector';
    final teamId = profile?.teamId ?? '';

    return Scaffold(
      appBar: SalsoAppBar(
        title: const Text("Team Reports", style: TextStyle(color: Colors.white)),
      ),
      body: StreamBuilder(
        stream: isEd ? service.streamAllSubmittedReports() : service.streamTeamReports(teamId),
        builder: (ctx, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return Center(
              child: Text('Error: ${snap.error}', style: const TextStyle(color: Colors.red)),
            );
          }
          final data = snap.data;
          final List<Report> reports = (data is List<Report>) ? data : [];
          reports.sort((a, b) => b.createdAtMs.compareTo(a.createdAtMs));

          if (reports.isEmpty) {
            return const Center(child: Text('No team reports yet.'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: reports.length,
            itemBuilder: (ctx, i) {
              final r = reports[i];
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: SalsoCard(
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ReportDetailPage(report: r))),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(r.title.isEmpty ? '(Untitled)' : r.title, style: const TextStyle(fontWeight: FontWeight.w600)),
                      const SizedBox(height: 4),
                      Text('${r.reportType.toUpperCase()} — ${r.sharePointStatus}', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          SalsoStatusBadge(status: r.status, fontSize: 10),
                          const Spacer(),
                          if (!isEd)
                            TextButton(
                              style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: Size.zero, tapTargetSize: MaterialTapTargetSize.shrinkWrap),
                              onPressed: () => service.approveReport(r, approve: true, comment: 'Approved'),
                              child: const Text('Approve', style: TextStyle(fontSize: 12)),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
