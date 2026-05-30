import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../services/finance_sop_service.dart';
import '../../models/finance_sop.dart';
import '../../widgets/salso_card.dart';
import '../../state/session_provider.dart';

class FinanceSopApprovalsScreen extends StatelessWidget {
  final String approvalStep;

  const FinanceSopApprovalsScreen({
    super.key,
    required this.approvalStep,
  });

  @override
  Widget build(BuildContext context) {
    final service = context.watch<FinanceSopService>();
    final session = context.watch<SessionProvider>();
    final role = session.profile?.roleTemplateId ?? '';

    Stream<List<FinanceSop>> stream;
    String title;

    switch (approvalStep) {
      case 'manager':
        stream = service.streamPendingManagerApproval();
        title = 'Manager Approvals';
        break;
      case 'finance':
        stream = service.streamPendingFinanceApproval();
        title = 'Finance Approvals';
        break;
      case 'ed':
        stream = service.streamPendingEdApproval();
        title = 'ED Final Approval';
        break;
      default:
        stream = service.streamAllSops();
        title = 'All SOPs';
    }

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: StreamBuilder<List<FinanceSop>>(
        stream: stream,
        builder: (ctx, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final list = snap.data ?? [];
          if (list.isEmpty) return const Center(child: Text('No items pending.'));

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: list.length,
            itemBuilder: (ctx, i) {
              final s = list[i];
              final date = DateFormat('dd MMM yyyy').format(
                DateTime.fromMillisecondsSinceEpoch(s.createdAtMs),
              );
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: SalsoCard(
                  onTap: () => _openDecisionDialog(context, service, s),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(s.title, style: const TextStyle(fontWeight: FontWeight.w600)),
                          ),
                          SalsoStatusBadge(status: s.status),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text('R${s.amount.toStringAsFixed(2)} • $date',
                        style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                      Text(s.description, maxLines: 2, overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: Colors.grey[500], fontSize: 12)),
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

  Future<void> _openDecisionDialog(
    BuildContext context,
    FinanceSopService service,
    FinanceSop sop,
  ) async {
    final commentCtrl = TextEditingController();
    final isEd = approvalStep == 'ed';
    final financeEnabled = true;

    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(sop.title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Amount: R${sop.amount.toStringAsFixed(2)}'),
            const SizedBox(height: 4),
            Text(sop.description),
            const SizedBox(height: 12),
            TextField(
              controller: commentCtrl,
              decoration: const InputDecoration(labelText: 'Review comment'),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              await service.approveStep(
                sop: sop,
                step: approvalStep,
                approve: false,
                comment: commentCtrl.text,
                financeEnabled: financeEnabled,
              );
              Navigator.pop(ctx);
            },
            child: const Text('Reject', style: TextStyle(color: Colors.red)),
          ),
          ElevatedButton(
            onPressed: () async {
              await service.approveStep(
                sop: sop,
                step: approvalStep,
                approve: true,
                comment: commentCtrl.text,
                financeEnabled: financeEnabled,
              );
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(isEd ? 'Payment authorised.' : 'Approved.')),
              );
            },
            child: Text(isEd ? 'Authorise Payment' : 'Approve'),
          ),
        ],
      ),
    );
  }
}
