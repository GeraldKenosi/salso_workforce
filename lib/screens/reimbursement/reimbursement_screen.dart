import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../services/reimbursement_service.dart';
import '../../models/reimbursement.dart';

class ReimbursementScreen extends StatefulWidget {
  const ReimbursementScreen({super.key});

  @override
  State<ReimbursementScreen> createState() => _ReimbursementScreenState();
}

class _ReimbursementScreenState extends State<ReimbursementScreen> {
  @override
  Widget build(BuildContext context) {
    final service = context.watch<ReimbursementService>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reimbursements'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _openNewClaimDialog(context),
          ),
        ],
      ),
      body: StreamBuilder<List<Reimbursement>>(
        stream: service.streamMyClaims(),
        builder: (ctx, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return Center(
              child: Text('Error: ${snap.error}', style: const TextStyle(color: Colors.red)),
            );
          }
          final claims = snap.data ?? [];
          if (claims.isEmpty) {
            return const Center(child: Text('No reimbursement claims yet.'));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: claims.length,
            itemBuilder: (ctx, i) {
              final c = claims[i];
              final date = DateFormat('dd MMM yyyy, HH:mm').format(
                DateTime.fromMillisecondsSinceEpoch(c.createdAtMs),
              );
              final color = c.status == 'approved'
                  ? Colors.green
                  : c.status == 'rejected'
                      ? Colors.red
                      : Colors.orange;
              return Card(
                child: ListTile(
                  leading: const Icon(Icons.receipt),
                  title: Text('R${c.amount.toStringAsFixed(2)}'),
                  subtitle: Text('${c.description}\n$date'),
                  trailing: Text(
                    c.status.toUpperCase(),
                    style: TextStyle(fontWeight: FontWeight.bold, color: color),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _openNewClaimDialog(BuildContext context) async {
    final amountCtrl = TextEditingController();
    final descCtrl = TextEditingController();

    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('New Reimbursement Claim'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: amountCtrl,
                decoration: const InputDecoration(
                  labelText: 'Amount (R)',
                  prefixText: 'R ',
                ),
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
                  const SnackBar(content: Text('Please enter a valid amount.')),
                );
                return;
              }
              try {
                await context.read<ReimbursementService>().submitClaim(
                  amount: amount,
                  description: descCtrl.text,
                );
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Claim submitted.')),
                );
              } catch (e) {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error: $e')),
                );
              }
            },
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }
}
