import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../services/finance_sop_service.dart';
import '../../models/finance_sop.dart';
import '../../widgets/salso_card.dart';
import '../../app/theme.dart';

class FinanceSopListScreen extends StatefulWidget {
  const FinanceSopListScreen({super.key});

  @override
  State<FinanceSopListScreen> createState() => _FinanceSopListScreenState();
}

class _FinanceSopListScreenState extends State<FinanceSopListScreen> {
  @override
  Widget build(BuildContext context) {
    final service = context.watch<FinanceSopService>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Finance SOPs'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _openNewSopDialog(context),
          ),
        ],
      ),
      body: StreamBuilder<List<FinanceSop>>(
        stream: service.streamMySops(),
        builder: (ctx, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final sops = snap.data ?? [];
          if (sops.isEmpty) {
            return SalsoEmptyState(
              icon: Icons.receipt_long_outlined,
              title: 'No Finance SOPs',
              subtitle: 'Submit a reimbursement, supplier payment, or procurement request.',
              action: ElevatedButton.icon(
                icon: const Icon(Icons.add),
                label: const Text('New Request'),
                onPressed: () => _openNewSopDialog(context),
              ),
            );
          }

          final types = {
            'reimbursement': 'Reimbursement',
            'supplier_payment': 'Supplier Payment',
            'procurement': 'Procurement',
            'petty_cash': 'Petty Cash',
            'travel': 'Travel Reimbursement',
          };

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: sops.length,
            itemBuilder: (ctx, i) {
              final s = sops[i];
              final date = DateFormat('dd MMM yyyy').format(
                DateTime.fromMillisecondsSinceEpoch(s.createdAtMs),
              );
              final typeLabel = types[s.sopType] ?? s.sopType;
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: SalsoCard(
                  onTap: () => _showSopDetail(context, s),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              s.title,
                              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                            ),
                          ),
                          SalsoStatusBadge(status: s.status),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '$typeLabel • R${s.amount.toStringAsFixed(2)}',
                        style: TextStyle(color: Colors.grey[600], fontSize: 13),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        s.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: Colors.grey[500], fontSize: 12),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        date,
                        style: TextStyle(color: Colors.grey[400], fontSize: 11),
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

  Future<void> _openNewSopDialog(BuildContext context) async {
    String sopType = 'reimbursement';
    final titleCtrl = TextEditingController();
    final amountCtrl = TextEditingController();
    final descCtrl = TextEditingController();

    final types = {
      'reimbursement': 'Reimbursement',
      'supplier_payment': 'Supplier Payment',
      'procurement': 'Procurement Request',
      'petty_cash': 'Petty Cash',
      'travel': 'Travel Reimbursement',
    };

    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('New Finance SOP'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  value: sopType,
                  items: types.entries.map((e) => DropdownMenuItem(
                    value: e.key, child: Text(e.value),
                  )).toList(),
                  onChanged: (v) => setDialogState(() => sopType = v ?? 'reimbursement'),
                  decoration: const InputDecoration(labelText: 'SOP Type'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: titleCtrl,
                  decoration: const InputDecoration(labelText: 'Title'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: amountCtrl,
                  decoration: const InputDecoration(labelText: 'Amount (R)', prefixText: 'R '),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: descCtrl,
                  decoration: const InputDecoration(labelText: 'Description'),
                  maxLines: 3,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () async {
                final amount = double.tryParse(amountCtrl.text.trim());
                if (amount == null || amount <= 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Enter a valid amount')),
                  );
                  return;
                }
                try {
                  await context.read<FinanceSopService>().submitSop(
                    sopType: sopType,
                    title: titleCtrl.text.trim(),
                    amount: amount,
                    description: descCtrl.text.trim(),
                  );
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('SOP submitted for approval.')),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: $e')),
                  );
                }
              },
              child: const Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }

  void _showSopDetail(BuildContext context, FinanceSop sop) {
    final types = {
      'reimbursement': 'Reimbursement',
      'supplier_payment': 'Supplier Payment',
      'procurement': 'Procurement Request',
      'petty_cash': 'Petty Cash',
      'travel': 'Travel Reimbursement',
    };

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(sop.title),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              SalsoInfoRow(label: 'Type', value: types[sop.sopType] ?? sop.sopType),
              SalsoInfoRow(label: 'Amount', value: 'R${sop.amount.toStringAsFixed(2)}'),
              SalsoInfoRow(label: 'Status', value: sop.status.toUpperCase()),
              const SizedBox(height: 8),
              Text(sop.description, style: const TextStyle(height: 1.4)),
              if (sop.decisionReason != null && sop.decisionReason!.isNotEmpty) ...[
                const Divider(height: 20),
                Text('Decision: ${sop.decisionReason}', style: TextStyle(color: Colors.grey[600])),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Close')),
        ],
      ),
    );
  }
}
