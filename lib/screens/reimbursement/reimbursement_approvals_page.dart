import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../services/reimbursement_service.dart';
import '../../models/reimbursement.dart';

class ReimbursementApprovalsPage extends StatelessWidget {
  const ReimbursementApprovalsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final service = context.watch<ReimbursementService>();

    return Scaffold(
      appBar: AppBar(title: const Text('Reimbursement Approvals')),
      body: StreamBuilder<List<Reimbursement>>(
        stream: service.streamAllPendingClaims(),
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
            return const Center(child: Text('No pending claims.'));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: list.length,
            itemBuilder: (ctx, i) {
              final c = list[i];
              return Card(
                child: ListTile(
                  leading: const Icon(Icons.receipt),
                  title: Text('R${c.amount.toStringAsFixed(2)}'),
                  subtitle: Text(c.description),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _openDecisionDialog(context, service, c),
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
    ReimbursementService service,
    Reimbursement claim,
  ) async {
    final decisionCtrl = TextEditingController();
    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Review Claim'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Amount: R${claim.amount.toStringAsFixed(2)}'),
            Text('Description: ${claim.description}'),
            const SizedBox(height: 12),
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
              await service.decide(
                claim: claim,
                approve: false,
                decisionReason: decisionCtrl.text,
              );
              Navigator.pop(ctx);
            },
            child: const Text('Reject'),
          ),
          ElevatedButton(
            onPressed: () async {
              await service.decide(
                claim: claim,
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
