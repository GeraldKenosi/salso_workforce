import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CloseRegisterPage extends StatelessWidget {
  final String registerId;
  final String registerName;
  final int currentCount;
  const CloseRegisterPage({
    super.key,
    required this.registerId,
    required this.registerName,
    required this.currentCount,
  });

  Future<void> _close(BuildContext context) async {
    try {
      await FirebaseFirestore.instance.collection('attendanceRegisters').doc(registerId).update({
        'status': 'closed',
        'closedAtMs': DateTime.now().millisecondsSinceEpoch,
      });
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Register closed.')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Close Register')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.lock, size: 64, color: Colors.orange),
            const SizedBox(height: 16),
            const Text('Finalise this register?', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 20)),
            const SizedBox(height: 8),
            Text(registerName, style: TextStyle(color: Colors.grey[600], fontSize: 14), textAlign: TextAlign.center),
            const SizedBox(height: 24),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.people),
                    const SizedBox(width: 8),
                    Text('$currentCount participants signed in',
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text('Once closed, participants can only be added via Late Additions.',
              style: TextStyle(color: Colors.grey, fontSize: 12), textAlign: TextAlign.center),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.check),
                label: const Text('Close Register'),
                onPressed: () => _close(context),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
