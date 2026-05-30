import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../state/session_provider.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _phoneCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _nokNameCtrl = TextEditingController();
  final _nokRelationshipCtrl = TextEditingController();
  final _nokPhoneCtrl = TextEditingController();

  bool _saving = false;
  bool _saved = false;

  @override
  void initState() {
    super.initState();
    final session = context.read<SessionProvider>();
    final p = session.profile;
    if (p != null) {
      _phoneCtrl.text = p.phoneNumber ?? '';
      _addressCtrl.text = p.physicalAddress ?? '';
      _nokNameCtrl.text = p.nextOfKinName ?? '';
      _nokRelationshipCtrl.text = p.nextOfKinRelationship ?? '';
      _nokPhoneCtrl.text = p.nextOfKinPhone ?? '';
    }
  }

  @override
  void dispose() {
    _phoneCtrl.dispose();
    _addressCtrl.dispose();
    _nokNameCtrl.dispose();
    _nokRelationshipCtrl.dispose();
    _nokPhoneCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
        'phoneNumber': _phoneCtrl.text.trim(),
        'physicalAddress': _addressCtrl.text.trim(),
        'nextOfKinName': _nokNameCtrl.text.trim(),
        'nextOfKinRelationship': _nokRelationshipCtrl.text.trim(),
        'nextOfKinPhone': _nokPhoneCtrl.text.trim(),
      });

      setState(() => _saved = true);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully.')),
        );
        Future.delayed(const Duration(seconds: 1), () {
          if (mounted) Navigator.pop(context);
        });
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

  Future<void> _requestEmailChange() async {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Email change request sent to admin.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final session = context.watch<SessionProvider>();
    final p = session.profile;
    final name = p?.fullName ?? '';
    final email = p?.email ?? '';
    final roleCode = p?.roleTemplateId ?? '';
    final idNumber = p?.idNumber ?? 'Not set';
    final roleLabel = _roleLabel(roleCode);

    return Scaffold(
      appBar: AppBar(title: const Text('Edit Profile')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Header
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 32,
                    backgroundColor: const Color(0xFFD90429),
                    child: Text(name.isNotEmpty ? name[0].toUpperCase() : '?',
                      style: const TextStyle(color: Colors.white, fontSize: 28)),
                  ),
                  const SizedBox(height: 12),
                  Text(name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 18)),
                  Text(roleLabel, style: TextStyle(color: Colors.grey[600], fontSize: 14)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Read-only personal info
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Personal Information', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                  const SizedBox(height: 12),
                  _readOnlyField('Full Name', name),
                  _readOnlyField('ID Number', idNumber),
                  _readOnlyField('Email', email),
                  const SizedBox(height: 8),
                  TextButton.icon(
                    icon: const Icon(Icons.mail_outline, size: 16),
                    label: const Text('Request email change'),
                    onPressed: _requestEmailChange,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Editable contact
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Contact Details', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                  const SizedBox(height: 12),
                  TextField(controller: _phoneCtrl, decoration: const InputDecoration(labelText: 'Phone Number'), keyboardType: TextInputType.phone),
                  const SizedBox(height: 12),
                  TextField(controller: _addressCtrl, decoration: const InputDecoration(labelText: 'Physical Address'), maxLines: 2),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Editable next of kin
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Next of Kin', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                  const SizedBox(height: 12),
                  TextField(controller: _nokNameCtrl, decoration: const InputDecoration(labelText: 'Full Name')),
                  const SizedBox(height: 12),
                  TextField(controller: _nokRelationshipCtrl, decoration: const InputDecoration(labelText: 'Relationship')),
                  const SizedBox(height: 12),
                  TextField(controller: _nokPhoneCtrl, decoration: const InputDecoration(labelText: 'Phone Number'), keyboardType: TextInputType.phone),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _saving ? null : _save,
              child: _saving
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : Text(_saved ? 'Saved!' : 'Save Changes'),
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _readOnlyField(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(width: 100, child: Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 13))),
          Expanded(child: Text(value, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13))),
          const Icon(Icons.lock, size: 14, color: Colors.grey),
        ],
      ),
    );
  }

  String _roleLabel(String role) {
    switch (role) {
      case 'executiveDirector': return 'Executive Director';
      case 'teamLeader': return 'Team Leader';
      case 'manager': return 'Manager';
      case 'admin': return 'Administrator';
      case 'coordinator': return 'Coordinator';
      default: return 'Volunteer';
    }
  }
}
