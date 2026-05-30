import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../services/leave_service.dart';
import '../../models/leave_request.dart';

class LeaveScreen extends StatefulWidget {
  const LeaveScreen({super.key});

  @override
  State<LeaveScreen> createState() => _LeaveScreenState();
}

class _LeaveScreenState extends State<LeaveScreen> {
  @override
  Widget build(BuildContext context) {
    final leaveService = context.watch<LeaveService>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Leave Requests'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _openNewLeaveDialog(context),
          ),
        ],
      ),
      body: StreamBuilder<List<LeaveRequest>>(
        stream: leaveService.streamMyLeaves(),
        builder: (ctx, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return Center(
              child: Text('Error: ${snap.error}', style: const TextStyle(color: Colors.red)),
            );
          }
          final leaves = snap.data ?? [];
          if (leaves.isEmpty) {
            return const Center(child: Text('No leave requests yet.'));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: leaves.length,
            itemBuilder: (ctx, i) {
              final l = leaves[i];
              final start = DateFormat('dd MMM yyyy').format(
                DateTime.fromMillisecondsSinceEpoch(l.startDateMs),
              );
              final end = DateFormat('dd MMM yyyy').format(
                DateTime.fromMillisecondsSinceEpoch(l.endDateMs),
              );
              final color = l.status == 'approved'
                  ? Colors.green
                  : l.status == 'rejected'
                      ? Colors.red
                      : Colors.orange;
              return Card(
                child: ListTile(
                  leading: const Icon(Icons.event),
                  title: Text('${l.leaveType} Leave'),
                  subtitle: Text('$start → $end\n${l.reason}'),
                  trailing: Text(
                    l.status.toUpperCase(),
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

  Future<void> _openNewLeaveDialog(BuildContext context) async {
    String leaveType = 'annual';
    DateTime startDate = DateTime.now();
    DateTime endDate = DateTime.now().add(const Duration(days: 1));
    final reasonCtrl = TextEditingController();

    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('New Leave Request'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  value: leaveType,
                  items: const [
                    DropdownMenuItem(value: 'annual', child: Text('Annual Leave')),
                    DropdownMenuItem(value: 'sick', child: Text('Sick Leave')),
                    DropdownMenuItem(value: 'family', child: Text('Family Responsibility')),
                    DropdownMenuItem(value: 'other', child: Text('Other')),
                  ],
                  onChanged: (v) => setDialogState(() => leaveType = v ?? 'annual'),
                  decoration: const InputDecoration(labelText: 'Leave Type'),
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () async {
                    final picked = await showDatePicker(
                      context: ctx,
                      initialDate: startDate,
                      firstDate: DateTime.now().subtract(const Duration(days: 30)),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (picked != null) setDialogState(() => startDate = picked);
                  },
                  child: Text('Start: ${DateFormat('dd MMM yyyy').format(startDate)}'),
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () async {
                    final picked = await showDatePicker(
                      context: ctx,
                      initialDate: endDate,
                      firstDate: startDate,
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (picked != null) setDialogState(() => endDate = picked);
                  },
                  child: Text('End: ${DateFormat('dd MMM yyyy').format(endDate)}'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: reasonCtrl,
                  decoration: const InputDecoration(labelText: 'Reason'),
                  maxLines: 3,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () async {
                try {
                  await context.read<LeaveService>().submitLeave(
                    leaveType: leaveType,
                    startDate: startDate,
                    endDate: endDate,
                    reason: reasonCtrl.text,
                  );
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Leave request submitted.')),
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
      ),
    );
  }
}
