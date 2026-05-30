import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../services/audit_service.dart';
import '../../models/audit_log.dart';
import '../../widgets/salso_card.dart';

class AuditLogScreen extends StatelessWidget {
  const AuditLogScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final service = context.watch<AuditService>();

    return Scaffold(
      appBar: AppBar(title: const Text('Audit Log')),
      body: StreamBuilder<List<AuditLog>>(
        stream: service.streamAllLogs(),
        builder: (ctx, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final logs = snap.data ?? [];
          if (logs.isEmpty) {
            return const SalsoEmptyState(
              icon: Icons.history,
              title: 'No Audit Logs',
              subtitle: 'Actions will be logged here automatically.',
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: logs.length,
            itemBuilder: (ctx, i) {
              final l = logs[i];
              final date = DateFormat('dd MMM yyyy HH:mm').format(
                DateTime.fromMillisecondsSinceEpoch(l.createdAtMs),
              );
              return Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: SalsoCard(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(_actionIcon(l.action), size: 20, color: Colors.grey[600]),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('${l.userName} — ${l.action}', style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13)),
                            const SizedBox(height: 2),
                            Text(l.details, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                            Text(date, style: TextStyle(color: Colors.grey[400], fontSize: 11)),
                          ],
                        ),
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

  IconData _actionIcon(String action) {
    switch (action.toLowerCase()) {
      case 'create': return Icons.add_circle_outline;
      case 'update': return Icons.edit_outlined;
      case 'approve': return Icons.check_circle_outline;
      case 'reject': return Icons.cancel_outlined;
      case 'login': return Icons.login;
      case 'upload': return Icons.upload_file;
      default: return Icons.info_outline;
    }
  }
}
