import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../widgets/salso_app_bar.dart';
import '../../../widgets/salso_card.dart';
import '../../../app/theme.dart';
import 'qr_display_page.dart';
import 'add_participant_page.dart';
import 'close_register_page.dart';
import 'late_additions_page.dart';

class RegisterDetailPage extends StatelessWidget {
  final String registerId;
  final Map<String, dynamic> registerData;

  const RegisterDetailPage({
    super.key,
    required this.registerId,
    required this.registerData,
  });

  @override
  Widget build(BuildContext context) {
    final name = registerData['name'] ?? '';
    final status = registerData['status'] ?? 'open';
    final count = registerData['participantCount'] ?? 0;
    final isOpen = status == 'open';

    return Scaffold(
      appBar: SalsoAppBar(title: Text(name, style: const TextStyle(color: Colors.white))),
      body: Column(
        children: [
          // Register info header
          Container(
            color: SalsoTheme.primary.withValues(alpha: 0.05),
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                      Text('Status: $status', style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                      Text('$count participants', style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                    ],
                  ),
                ),
                if (isOpen)
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.qr_code, color: SalsoTheme.primary),
                        tooltip: 'Show QR code',
                        onPressed: () => Navigator.push(context, MaterialPageRoute(
                          builder: (_) => QrDisplayPage(registerId: registerId, registerName: name),
                        )),
                      ),
                      IconButton(
                        icon: const Icon(Icons.person_add_alt, color: SalsoTheme.primary),
                        tooltip: 'Add participant',
                        onPressed: () => Navigator.push(context, MaterialPageRoute(
                          builder: (_) => AddParticipantPage(registerId: registerId, registerName: name),
                        )),
                      ),
                    ],
                  ),
              ],
            ),
          ),

          // Participants list
          Expanded(
            child: StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('attendanceRegisters').doc(registerId)
                  .collection('participants')
                  .orderBy('addedAtMs', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) return Center(child: Text('Error: ${snapshot.error}'));
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                final participants = snapshot.data!.docs;
                if (participants.isEmpty) return const Center(child: Text('No participants yet.'));
                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: participants.length,
                  itemBuilder: (_, i) {
                    final p = participants[i].data() as Map<String, dynamic>;
                    final pId = participants[i].id;
                    return SalsoCard(
                      child: ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: CircleAvatar(
                          backgroundColor: SalsoTheme.primary.withValues(alpha: 0.1),
                          child: Text('${i + 1}', style: const TextStyle(color: SalsoTheme.primary, fontWeight: FontWeight.w700)),
                        ),
                        title: Text(p['name'] ?? 'Unknown', style: const TextStyle(fontWeight: FontWeight.w600)),
                        subtitle: Text(p['phone'] ?? p['idNumber'] ?? '', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                        trailing: Text(p['signedInAtMs'] != null
                            ? DateTime.fromMillisecondsSinceEpoch(p['signedInAtMs']).toString().substring(11, 16)
                            : '', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                      ),
                    );
                  },
                );
              },
            ),
          ),

          // Bottom actions
          if (isOpen)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.qr_code),
                      label: const Text('QR Code'),
                      onPressed: () => Navigator.push(context, MaterialPageRoute(
                        builder: (_) => QrDisplayPage(registerId: registerId, registerName: name),
                      )),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.add),
                      label: const Text('Add'),
                      onPressed: () => Navigator.push(context, MaterialPageRoute(
                        builder: (_) => AddParticipantPage(registerId: registerId, registerName: name),
                      )),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.lock),
                      label: const Text('Close'),
                      onPressed: () => Navigator.push(context, MaterialPageRoute(
                        builder: (_) => CloseRegisterPage(registerId: registerId, registerName: name, currentCount: count),
                      )),
                    ),
                  ),
                ],
              ),
            )
          else ...[
            Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.add_circle_outline),
                  label: const Text('Late Additions'),
                  onPressed: () => Navigator.push(context, MaterialPageRoute(
                    builder: (_) => LateAdditionsPage(registerId: registerId, registerName: name),
                  )),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
