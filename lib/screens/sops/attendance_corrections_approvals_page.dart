import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../services/attendance_correction_admin_service.dart';
import '../../models/attendance_correction.dart';
import '../../state/session_provider.dart';

class AttendanceCorrectionsApprovalsPage extends StatelessWidget {
  const AttendanceCorrectionsApprovalsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final session = context.watch<SessionProvider>();
    final admin = context.watch<AttendanceCorrectionAdminService>();

    final role = session.profile?.roleTemplateId ?? '';
    final teamId = session.profile?.teamId ?? '';
    final programmeId = session.profile?.programmeId ?? '';

    final canApprove =
        role == 'executiveDirector' || role == 'manager' || role == 'teamLeader';

    if (!canApprove) {
      return Scaffold(
        appBar: AppBar(title: const Text('Attendance Corrections')),
        body: const Center(child: Text('No approval permissions.')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Attendance Corrections')),
      body: StreamBuilder<List<AttendanceCorrection>>(
        stream: admin.streamPendingCorrections(
          role: role,
          teamId: teamId,
          programmeId: programmeId,
        ),
        builder: (ctx, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  "Failed to load pending corrections:\n${snap.error}",
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            );
          }

          final list = snap.data ?? [];
          if (list.isEmpty) {
            return const Center(child: Text('No pending corrections.'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: list.length,
            itemBuilder: (ctx, i) {
              final c = list[i];
              final time = DateFormat('dd MMM yyyy, HH:mm').format(
                DateTime.fromMillisecondsSinceEpoch(c.proposedClockOutMs),
              );

              return Card(
                child: ListTile(
                  title: Text('User ID: ${c.userId}'),
                  subtitle: Text('Proposed clock-out: $time\nReason: ${c.reason}'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _openDecisionDialog(ctx, admin, c),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _openDecisionDialog(
    BuildContext context,
    AttendanceCorrectionAdminService admin,
    AttendanceCorrection correction,
  ) async {
    final decisionCtrl = TextEditingController();

    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Review correction'),
        content: TextField(
          controller: decisionCtrl,
          decoration: const InputDecoration(
            labelText: 'Decision reason (required)',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              await admin.decide(
                correction: correction,
                approve: false,
                decisionReason: decisionCtrl.text,
              );
              Navigator.pop(ctx);
            },
            child: const Text('Reject'),
          ),
          ElevatedButton(
            onPressed: () async {
              await admin.decide(
                correction: correction,
                approve: true,
                decisionReason: decisionCtrl.text,
              );
              Navigator.pop(ctx);
            },
            child: const Text('Approve'),
          ),
        ],
      ),
    );
  }
}