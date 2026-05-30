import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../app/theme.dart';

class AddParticipantPage extends StatefulWidget {
  final String registerId;
  final String registerName;
  const AddParticipantPage({super.key, required this.registerId, required this.registerName});

  @override
  State<AddParticipantPage> createState() => _AddParticipantPageState();
}

class _AddParticipantPageState extends State<AddParticipantPage> {
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _idCtrl = TextEditingController();
  bool _saving = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _idCtrl.dispose();
    super.dispose();
  }

  Future<void> _add() async {
    if (_nameCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Name is required.')),
      );
      return;
    }
    setState(() => _saving = true);
    try {
      await FirebaseFirestore.instance
          .collection('attendanceRegisters').doc(widget.registerId)
          .collection('participants').add({
        'name': _nameCtrl.text.trim(),
        'phone': _phoneCtrl.text.trim(),
        'idNumber': _idCtrl.text.trim(),
        'signedInAtMs': DateTime.now().millisecondsSinceEpoch,
        'addedAtMs': DateTime.now().millisecondsSinceEpoch,
      });

      // Increment counter on register
      await FirebaseFirestore.instance
          .collection('attendanceRegisters').doc(widget.registerId)
          .update({
        'participantCount': FieldValue.increment(1),
      });

      _nameCtrl.clear();
      _phoneCtrl.clear();
      _idCtrl.clear();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Participant added.')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Participant')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Register: ${widget.registerName}', style: TextStyle(color: Colors.grey[600], fontSize: 13)),
          const SizedBox(height: 16),
          TextField(controller: _nameCtrl, decoration: const InputDecoration(labelText: 'Full Name *')),
          const SizedBox(height: 12),
          TextField(controller: _phoneCtrl, decoration: const InputDecoration(labelText: 'Phone Number'), keyboardType: TextInputType.phone),
          const SizedBox(height: 12),
          TextField(controller: _idCtrl, decoration: const InputDecoration(labelText: 'ID Number')),
          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: _saving ? null : _add,
                  child: _saving
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Text('Add & Continue'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
