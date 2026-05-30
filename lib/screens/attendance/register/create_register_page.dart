import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CreateRegisterPage extends StatefulWidget {
  const CreateRegisterPage({super.key});

  @override
  State<CreateRegisterPage> createState() => _CreateRegisterPageState();
}

class _CreateRegisterPageState extends State<CreateRegisterPage> {
  final _activityCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  bool _saving = false;

  @override
  void dispose() {
    _activityCtrl.dispose();
    _locationCtrl.dispose();
    super.dispose();
  }

  Future<void> _create() async {
    if (_activityCtrl.text.trim().isEmpty || _locationCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Activity name and location are required.')),
      );
      return;
    }

    setState(() => _saving = true);
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final year = _selectedDate.year.toString();
      final month = _selectedDate.month.toString().padLeft(2, '0');
      final day = _selectedDate.day.toString().padLeft(2, '0');
      final dateStr = '$year-$month-$day';
      final name = '$dateStr ${_activityCtrl.text.trim()} - ${_locationCtrl.text.trim()}';

      await FirebaseFirestore.instance.collection('attendanceRegisters').add({
        'name': name,
        'activityName': _activityCtrl.text.trim(),
        'location': _locationCtrl.text.trim(),
        'dateMs': _selectedDate.millisecondsSinceEpoch,
        'status': 'open',
        'participantCount': 0,
        'createdBy': user.uid,
        'createdAtMs': DateTime.now().millisecondsSinceEpoch,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Register created.')),
        );
        Navigator.pop(context);
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
      appBar: AppBar(title: const Text('New Register')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('Register name is auto-generated from date + activity + location.',
            style: TextStyle(fontSize: 12, color: Colors.grey)),
          const SizedBox(height: 16),
          TextField(
            controller: _activityCtrl,
            decoration: const InputDecoration(labelText: 'Activity Name *'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _locationCtrl,
            decoration: const InputDecoration(labelText: 'Location *'),
          ),
          const SizedBox(height: 12),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.calendar_today),
            title: Text('Date: ${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}'),
            trailing: const Icon(Icons.edit),
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: _selectedDate,
                firstDate: DateTime(2020),
                lastDate: DateTime(2030),
              );
              if (picked != null) setState(() => _selectedDate = picked);
            },
          ),
          const SizedBox(height: 16),

          // Preview
          Card(
            color: Colors.blue.shade50,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  const Icon(Icons.preview, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')} ${_activityCtrl.text.trim()} - ${_locationCtrl.text.trim()}',
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _saving ? null : _create,
              child: _saving
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Text('Create Register'),
            ),
          ),
        ],
      ),
    );
  }
}
