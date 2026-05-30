import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../widgets/salso_app_bar.dart';
import '../../widgets/salso_card.dart';
import '../../services/workflow_service.dart';
import '../../models/sop_form_config.dart';
import '../../app/theme.dart';
import 'sop_request_detail_page.dart';

class ApprovalsDashboardPage extends StatelessWidget {
  const ApprovalsDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: SalsoAppBar(title: const Text('Approvals', style: TextStyle(color: Colors.white))),
      body: StreamBuilder(
        stream: WorkflowService(FirebaseFirestore.instance, FirebaseAuth.instance).streamPendingApprovals(),
        builder: (context, snapshot) {
          if (snapshot.hasError) return Center(child: Text('Error: ${snapshot.error}'));
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final requests = snapshot.data!;
          if (requests.isEmpty) return const Center(child: Text('No pending approvals.'));

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: requests.length,
            itemBuilder: (_, i) {
              final r = requests[i];
              final cfg = SopFormConfig.fromType(r['sopType'] ?? 'general');
              final typeLabel = cfg?.label ?? r['sopType'] ?? 'Request';
              final title = r['title'] ?? 'No title';
              final status = r['status'] ?? 'submitted';
              final filerName = r['userDisplayName'] ?? '';
              final currentIdx = (r['currentStepIndex'] ?? 0) as int;
              final steps = (r['approvalSteps'] as List?) ?? [];
              final stepLabel = currentIdx < steps.length ? steps[currentIdx] : '';

              return SalsoCard(
                onTap: () => Navigator.push(context, MaterialPageRoute(
                  builder: (_) => SopRequestDetailPage(requestData: r),
                )),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.description, size: 20, color: SalsoTheme.primary),
                        const SizedBox(width: 8),
                        Expanded(child: Text(typeLabel, style: const TextStyle(fontWeight: FontWeight.w700))),
                        _statusChip(status),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: Colors.grey[700])),
                    if (filerName.isNotEmpty) Text(filerName, style: TextStyle(color: Colors.grey[500], fontSize: 12)),
                    if (stepLabel.isNotEmpty) Text(stepLabel, style: TextStyle(color: SalsoTheme.primary, fontSize: 12)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () => _decide(context, r['id'], true, ''),
                            child: const Text('Approve', style: TextStyle(color: Colors.white)),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => _showRejectDialog(context, r['id']),
                            child: const Text('Reject'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _statusChip(String status) {
    Color color;
    switch (status) {
      case 'submitted': case 'pending': color = Colors.orange; break;
      case 'approved': color = Colors.green; break;
      case 'rejected': color = Colors.red; break;
      default: color = Colors.grey;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(12)),
      child: Text(status.toUpperCase(), style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: color)),
    );
  }

  Future<void> _decide(BuildContext context, String? requestId, bool approve, String comment) async {
    if (requestId == null) return;
    try {
      await WorkflowService(FirebaseFirestore.instance, FirebaseAuth.instance).decide(
        requestId: requestId,
        approve: approve,
        comment: comment,
      );
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(approve ? 'Request approved.' : 'Request rejected.'),
        ));
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  void _showRejectDialog(BuildContext context, String? requestId) {
    final reasonCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Reject Request'),
        content: TextField(controller: reasonCtrl, decoration: const InputDecoration(labelText: 'Reason'), maxLines: 3),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              _decide(context, requestId, false, reasonCtrl.text.trim());
            },
            child: const Text('Reject'),
          ),
        ],
      ),
    );
  }
}
