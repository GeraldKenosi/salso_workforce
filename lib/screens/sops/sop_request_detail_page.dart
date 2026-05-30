import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

import '../../widgets/salso_app_bar.dart';
import '../../widgets/salso_card.dart';
import '../../services/workflow_service.dart';
import '../../models/sop_form_config.dart';
import '../../app/theme.dart';

class SopRequestDetailPage extends StatefulWidget {
  final Map<String, dynamic> requestData;
  const SopRequestDetailPage({super.key, required this.requestData});

  @override
  State<SopRequestDetailPage> createState() => _SopRequestDetailPageState();
}

class _SopRequestDetailPageState extends State<SopRequestDetailPage> {
  final _commentCtrl = TextEditingController();
  final _service = WorkflowService(FirebaseFirestore.instance, FirebaseAuth.instance);
  bool _addingComment = false;

  @override
  void dispose() {
    _commentCtrl.dispose();
    super.dispose();
  }

  Future<void> _addComment() async {
    if (_commentCtrl.text.trim().isEmpty) return;
    setState(() => _addingComment = true);
    try {
      await _service.addComment(
        widget.requestData['id'],
        _commentCtrl.text.trim(),
      );
      _commentCtrl.clear();
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _addingComment = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final d = widget.requestData;
    final requestId = d['id'] ?? '';
    final type = d['type'] ?? 'general';
    final cfg = SopFormConfig.fromType(type);
    final data = d['data'] is Map ? Map<String, dynamic>.from(d['data']) : d;
    final title = data['title'] ?? 'No title';
    final description = data['description'] ?? '';
    final status = d['currentStatus'] ?? 'pending';
    final stepLabel = d['currentStepLabel'] ?? '';
    final filerName = data['filerName'] ?? d['filerName'] ?? '';
    final createdAtMs = d['createdAtMs'] ?? d['data']?['createdAtMs'] ?? 0;
    final date = createdAtMs > 0 ? DateTime.fromMillisecondsSinceEpoch(createdAtMs) : null;

    return Scaffold(
      appBar: SalsoAppBar(title: Text(cfg?.label ?? 'Request', style: const TextStyle(color: Colors.white))),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SalsoCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Expanded(child: Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16))),
                  _statusChip(status),
                ]),
                const SizedBox(height: 8),
                if (filerName.isNotEmpty) Text('By: $filerName', style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                if (stepLabel.isNotEmpty) Text(stepLabel, style: TextStyle(color: SalsoTheme.primary, fontSize: 13)),
                if (date != null) Text(DateFormat.yMMMd().add_jm().format(date), style: TextStyle(color: Colors.grey[500], fontSize: 12)),
                if (description.isNotEmpty) ...[const SizedBox(height: 12), Text(description)],
              ],
            ),
          ),

          // Approval timeline / steps
          if (d['workflowSteps'] is List) ...[
            const SizedBox(height: 12),
            SalsoCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Workflow', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                  const SizedBox(height: 8),
                  ...(d['workflowSteps'] as List).map((step) {
                    final stepData = step is Map ? Map<String, dynamic>.from(step) : {};
                    final stepLabel = stepData['label'] ?? '';
                    final done = stepData['completedAtMs'] != null;
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(done ? Icons.check_circle : Icons.radio_button_unchecked,
                        color: done ? Colors.green : Colors.grey),
                      title: Text(stepLabel, style: TextStyle(fontWeight: done ? FontWeight.w600 : FontWeight.normal)),
                      subtitle: stepData['completedBy'] != null ? Text('by ${stepData['completedBy']}') : null,
                    );
                  }),
                ],
              ),
            ),
          ],

          // Comments
          const SizedBox(height: 12),
          SalsoCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Comments', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                const SizedBox(height: 8),
                  StreamBuilder<QuerySnapshot>(
                  stream: requestId.isNotEmpty
                      ? FirebaseFirestore.instance
                          .collection('workflowRequests').doc(requestId)
                          .collection('comments').orderBy('createdAtMs', descending: true).snapshots()
                      : null,
                  builder: (context, snapshot) {
                    if (snapshot == null || snapshot.hasError) return const Text('No comments');
                    if (!snapshot.hasData) return const CircularProgressIndicator();
                    final comments = snapshot.data!.docs;
                    if (comments.isEmpty) return const Text('No comments yet.', style: TextStyle(color: Colors.grey));

                    return Column(
                      children: comments.map((doc) {
                        final c = doc.data() as Map<String, dynamic>;
                        final cDate = (c['createdAtMs'] ?? 0) > 0
                            ? DateTime.fromMillisecondsSinceEpoch(c['createdAtMs'])
                            : null;
                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(c['text'] ?? '', style: const TextStyle(fontSize: 13)),
                          subtitle: Text(
                            '${c['userName'] ?? ''} ${cDate != null ? '· ${DateFormat.MMMd().add_jm().format(cDate)}' : ''}',
                            style: TextStyle(color: Colors.grey[500], fontSize: 11),
                          ),
                        );
                      }).toList(),
                    );
                  },
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextField(controller: _commentCtrl, decoration: const InputDecoration(labelText: 'Add comment', isDense: true)),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: _addingComment
                          ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                          : const Icon(Icons.send),
                      onPressed: _addingComment ? null : _addComment,
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _statusChip(String status) {
    Color color;
    switch (status) {
      case 'pending': color = Colors.orange; break;
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
}
