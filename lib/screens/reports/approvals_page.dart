import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../models/report.dart';
import '../../services/report_service.dart';
import '../../state/session_provider.dart';
import 'report_detail_page.dart';

class ApprovalsPage extends StatelessWidget {
  const ApprovalsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final session = context.watch<SessionProvider>();
    final reportService = context.watch<ReportService>();
    final role = session.profile?.roleTemplateId ?? '';
    final programmeId = session.profile?.programmeId ?? '';
    final teamId = session.profile?.teamId ?? '';

    final Stream stream;
    if (role == 'teamLeader') {
      stream = reportService.streamTeamReports(teamId);
    } else if (role == 'manager') {
      stream = reportService.streamProgrammeReports(programmeId);
    } else {
      stream = reportService.streamAllSubmittedReports();
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Report Approvals')),
      body: StreamBuilder(
        stream: stream,
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
          final pending = reports.where((r) => r.status == 'submitted').toList();

          if (pending.isEmpty) {
            return const Center(child: Text('No reports pending approval.'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: pending.length,
            itemBuilder: (ctx, i) {
              final r = pending[i];
              final date = DateFormat('dd MMM yyyy, HH:mm').format(
                DateTime.fromMillisecondsSinceEpoch(r.createdAtMs),
              );
              return Card(
                child: ListTile(
                  title: Text(r.title.isEmpty ? '(Untitled)' : r.title),
                  subtitle: Text(
                    '${r.reportType.toUpperCase()} • $date\n'
                    'Programme: ${r.programmeId.isEmpty ? 'N/A' : r.programmeId}',
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.check_circle, color: Colors.green),
                        onPressed: () => _decide(context, reportService, r, true),
                      ),
                      IconButton(
                        icon: const Icon(Icons.cancel, color: Colors.red),
                        onPressed: () => _decide(context, reportService, r, false),
                      ),
                    ],
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => ReportDetailPage(report: r)),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _decide(
    BuildContext context,
    ReportService service,
    Report report,
    bool approve,
  ) async {
    final reasonCtrl = TextEditingController();
    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(approve ? 'Approve Report' : 'Reject Report'),
        content: TextField(
          controller: reasonCtrl,
          decoration: const InputDecoration(
            labelText: 'Review comment (required)',
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              try {
                await service.approveReport(report, approve: approve, comment: reasonCtrl.text);
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(approve ? 'Report approved.' : 'Report rejected.')),
                );
              } catch (e) {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error: $e')),
                );
              }
            },
            child: Text(approve ? 'Confirm Approve' : 'Confirm Reject'),
          ),
        ],
      ),
    );
  }
}