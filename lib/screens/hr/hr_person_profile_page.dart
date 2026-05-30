import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class HrPersonProfilePage extends StatelessWidget {
  final String userId;
  final Map<String, dynamic> userData;

  const HrPersonProfilePage({
    super.key,
    required this.userId,
    required this.userData,
  });

  static const _docTypes = <String, String>{
    'id': 'ID Document',
    'cv': 'CV',
    'proofOfBank': 'Proof of Banking',
    'contract': 'Signed Contract',
  };

  @override
  Widget build(BuildContext context) {
    final fullName = (userData['fullName'] ?? 'Unknown').toString();
    final email = (userData['email'] ?? '').toString();
    final role = (userData['roleTemplateId'] ?? userData['role'] ?? 'unknown').toString();
    final programmeId = (userData['programmeId'] ?? '').toString();
    final teamId = (userData['teamId'] ?? '').toString();

    return Scaffold(
      appBar: AppBar(title: const Text('Person Profile')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Icon(Icons.badge_outlined, size: 44),
          const SizedBox(height: 12),
          Text(
            fullName,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          Text(
            email.isEmpty ? 'No email on record' : email,
            style: const TextStyle(color: Colors.black54),
          ),
          const SizedBox(height: 12),

          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('User ID: $userId', style: const TextStyle(color: Colors.black54)),
                  const SizedBox(height: 8),
                  Text('Role: $role'),
                  const SizedBox(height: 8),
                  Text('Programme: ${programmeId.isEmpty ? 'Not set' : programmeId}'),
                  const SizedBox(height: 8),
                  Text('Team: ${teamId.isEmpty ? 'Not set' : teamId}'),
                ],
              ),
            ),
          ),

          const SizedBox(height: 12),

          // ✅ Document status section
          const Text(
            'Documents Status',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 8),

          _DocumentsStatusCard(userId: userId),

          const SizedBox(height: 16),

          // ✅ Recent uploads list
          const Text(
            'Recent Documents (Metadata)',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 8),

          _RecentDocumentsCard(userId: userId),
        ],
      ),
    );
  }
}

class _DocumentsStatusCard extends StatelessWidget {
  final String userId;

  const _DocumentsStatusCard({required this.userId});

  static const _docTypes = <String, String>{
    'id': 'ID Document',
    'cv': 'CV',
    'proofOfBank': 'Proof of Banking',
    'contract': 'Signed Contract',
  };

  @override
  Widget build(BuildContext context) {
    return Card(
      child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('documents')
            .where('userId', isEqualTo: userId)
            .snapshots(),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Padding(
              padding: EdgeInsets.all(12),
              child: LinearProgressIndicator(),
            );
          }
          if (snap.hasError) {
            return Padding(
              padding: const EdgeInsets.all(12),
              child: Text(
                'Failed to load documents: ${snap.error}',
                style: const TextStyle(color: Colors.red),
              ),
            );
          }

          final docs = snap.data?.docs ?? [];

          // Pick “latest” record per docType based on updatedAtMs/createdAtMs.
          final Map<String, Map<String, dynamic>> latestByType = {};
          for (final d in docs) {
            final m = d.data();
            final type = (m['docType'] ?? '').toString();
            if (type.isEmpty) continue;

            final updated = _asInt(m['updatedAtMs']) ?? _asInt(m['createdAtMs']) ?? 0;
            final existing = latestByType[type];
            if (existing == null) {
              latestByType[type] = m;
            } else {
              final existingUpdated =
                  _asInt(existing['updatedAtMs']) ?? _asInt(existing['createdAtMs']) ?? 0;
              if (updated >= existingUpdated) {
                latestByType[type] = m;
              }
            }
          }

          return Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: _docTypes.entries.map((e) {
                final type = e.key;
                final label = e.value;

                final record = latestByType[type];
                final status = (record?['sharePointStatus'] ?? '').toString();
                final fileName = (record?['originalFileName'] ?? '').toString();
                final url = (record?['sharePointFileUrl'] ?? '').toString();

                final displayStatus = status.isEmpty ? 'missing' : status;
                final color = _statusColor(displayStatus);

                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
                            const SizedBox(height: 2),
                            Text(
                              fileName.isEmpty ? 'No file on record' : fileName,
                              style: const TextStyle(color: Colors.black54),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      _StatusChip(text: displayStatus.toUpperCase(), color: color),
                      const SizedBox(width: 8),
                      if (url.isNotEmpty)
                        IconButton(
                          tooltip: 'Copy SharePoint link',
                          icon: const Icon(Icons.link),
                          onPressed: () async {
                            await Clipboard.setData(ClipboardData(text: url));
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Link copied')),
                              );
                            }
                          },
                        ),
                    ],
                  ),
                );
              }).toList(),
            ),
          );
        },
      ),
    );
  }

  static int? _asInt(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    if (v is num) return v.toInt();
    final s = v.toString();
    return int.tryParse(s);
  }

  static Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'uploaded':
        return Colors.green;
      case 'failed':
        return Colors.red;
      case 'queued':
        return Colors.orange;
      case 'missing':
      default:
        return Colors.grey;
    }
  }
}

class _RecentDocumentsCard extends StatelessWidget {
  final String userId;

  const _RecentDocumentsCard({required this.userId});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('documents')
            .where('userId', isEqualTo: userId)
            .orderBy('createdAtMs', descending: true)
            .limit(10)
            .snapshots(),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Padding(
              padding: EdgeInsets.all(12),
              child: LinearProgressIndicator(),
            );
          }
          if (snap.hasError) {
            return Padding(
              padding: const EdgeInsets.all(12),
              child: Text(
                'Failed to load recent docs: ${snap.error}',
                style: const TextStyle(color: Colors.red),
              ),
            );
          }

          final docs = snap.data?.docs ?? [];
          if (docs.isEmpty) {
            return const Padding(
              padding: EdgeInsets.all(12),
              child: Text(
                'No documents found for this person yet.',
                style: TextStyle(color: Colors.black54),
              ),
            );
          }

          return Column(
            children: docs.map((d) {
              final m = d.data();
              final type = (m['docType'] ?? '').toString();
              final fileName = (m['originalFileName'] ?? '').toString();
              final status = (m['sharePointStatus'] ?? '').toString();
              final by = (m['uploadedByName'] ?? 'Unknown').toString();
              final whenMs = _asInt(m['uploadedAtMs']) ?? _asInt(m['createdAtMs']) ?? 0;

              final dateStr = whenMs > 0
                  ? DateTime.fromMillisecondsSinceEpoch(whenMs).toLocal().toString()
                  : 'Unknown time';

              final url = (m['sharePointFileUrl'] ?? '').toString();

              return ListTile(
                leading: const Icon(Icons.insert_drive_file_outlined),
                title: Text(fileName.isEmpty ? '(Unnamed file)' : fileName),
                subtitle: Text(
                  '${type.toUpperCase()} • ${status.isEmpty ? 'missing' : status} • $by\n$dateStr',
                ),
                trailing: url.isEmpty
                    ? null
                    : IconButton(
                        tooltip: 'Copy link',
                        icon: const Icon(Icons.link),
                        onPressed: () async {
                          await Clipboard.setData(ClipboardData(text: url));
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Link copied')),
                            );
                          }
                        },
                      ),
              );
            }).toList(),
          );
        },
      ),
    );
  }

  static int? _asInt(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    if (v is num) return v.toInt();
    return int.tryParse(v.toString());
  }
}

class _StatusChip extends StatelessWidget {
  final String text;
  final Color color;

  const _StatusChip({required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        border: Border.all(color: color.withValues(alpha: 0.55)),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }
}