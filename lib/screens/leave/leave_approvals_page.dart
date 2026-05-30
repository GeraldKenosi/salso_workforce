import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../services/leave_service.dart';
import '../../models/leave_request.dart';
import '../../state/session_provider.dart';

class LeaveApprovalsPage extends StatelessWidget {
  const LeaveApprovalsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final session = context.watch<SessionProvider>();
    final leaveService = context.watch<LeaveService>();
    final role = session.profile?.roleTemplateId ?? '';

    final bool canApprove =
        role == 'executiveDirector' || role == 'manager' || role == 'teamLeader' || role == 'admin';

    if (!canApprove) {
      return Scaffold(
        appBar: AppBar(title: const Text('Leave Approvals')),
        body: const Center(child: Text('No approval permissions.')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Leave Approvals')),
      body: StreamBuilder<List<LeaveRequest>>(
        stream: leaveService.streamAllPendingLeaves(),
        builder: (ctx, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return Center(
              child: Text('Error: ${snap.error}', style: const TextStyle(color: Colors.red)),
            );
          }
          final list = snap.data ?? [];
          if (list.isEmpty) {
            return const Center(child: Text('No pending leave requests.'));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: list.length,
            itemBuilder: (ctx, i) {
              final l = list[i];
              final start = DateFormat('dd MMM yyyy').format(
                DateTime.fromMillisecondsSinceEpoch(l.startDateMs),
              );
              final end = DateFormat('dd MMM yyyy').format(
                DateTime.fromMillisecondsSinceEpoch(l.endDateMs),
              );
              return Card(
                child: ListTile(
                  leading: const Icon(Icons.event),
                  title: Text('${l.leaveType} leave — ${l.userId.substring(0, 8)}...'),
                  subtitle: Text('$start → $end\n${l.reason}'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _openDecisionDialog(context, leaveService, l),
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
    LeaveService leaveService,
    LeaveRequest request,
  ) async {
    final decisionCtrl = TextEditingController();
    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Review Leave Request'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('User: ${request.userId}'),
            Text('Leave: ${request.leaveType}'),
            TextField(
              controller: decisionCtrl,
              decoration: const InputDecoration(labelText: 'Decision reason (required)'),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              await leaveService.decide(
                request: request,
                approve: false,
                decisionReason: decisionCtrl.text,
              );
              Navigator.pop(ctx);
            },
            child: const Text('Reject'),
          ),
          ElevatedButton(
            onPressed: () async {
              await leaveService.decide(
                request: request,
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
