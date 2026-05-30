import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../services/hr_profile_service.dart';
import '../../services/hr_user_admin_service.dart';

class HrCreateUserPage extends StatefulWidget {
  const HrCreateUserPage({super.key});

  @override
  State<HrCreateUserPage> createState() => _HrCreateUserPageState();
}

class _HrCreateUserPageState extends State<HrCreateUserPage> {
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _programmeCtrl = TextEditingController();
  final _teamCtrl = TextEditingController();
  String _role = 'volunteer';
  bool _createAuth = false;
  bool _working = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _programmeCtrl.dispose();
    _teamCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hr = context.read<HrProfileService>();
    final hrAdmin = context.read<HrUserAdminService>();

    return Scaffold(
      appBar: AppBar(title: const Text('Create User')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            if (!_createAuth)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Text(
                    'Profile-only mode: creates a Firestore profile for HR tracking. '
                    'The user will NOT have login access until you enable full account creation.',
                    style: TextStyle(color: Colors.black54, height: 1.4),
                  ),
                ),
              ),

            const SizedBox(height: 12),

            TextField(
              controller: _nameCtrl,
              decoration: const InputDecoration(labelText: 'Full Name'),
            ),
            const SizedBox(height: 12),

            TextField(
              controller: _emailCtrl,
              decoration: const InputDecoration(labelText: 'Email Address'),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 12),

            TextField(
              controller: _programmeCtrl,
              decoration: const InputDecoration(labelText: 'Programme (optional)'),
            ),
            const SizedBox(height: 12),

            TextField(
              controller: _teamCtrl,
              decoration: const InputDecoration(labelText: 'Team (optional)'),
            ),
            const SizedBox(height: 12),

            DropdownButtonFormField<String>(
              value: _role,
              decoration: const InputDecoration(labelText: 'Role'),
              items: const [
                DropdownMenuItem(value: 'volunteer', child: Text('Volunteer')),
                DropdownMenuItem(value: 'teamLeader', child: Text('Team Leader')),
                DropdownMenuItem(value: 'manager', child: Text('Manager')),
                DropdownMenuItem(value: 'admin', child: Text('Admin')),
              ],
              onChanged: _working ? null : (v) => setState(() => _role = v ?? 'volunteer'),
            ),

            const SizedBox(height: 12),

            SwitchListTile(
              title: const Text('Create full login account'),
              subtitle: const Text(
                'Requires Firebase Blaze plan + hrCreateUser Cloud Function deployed.\n'
                'User will receive a password reset email.',
              ),
              value: _createAuth,
              onChanged: _working ? null : (v) => setState(() => _createAuth = v),
            ),

            const SizedBox(height: 18),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _working ? null : () => _createUser(hr, hrAdmin),
                child: Text(_working
                    ? 'Creating…'
                    : _createAuth
                        ? 'Create User & Send Login Email'
                        : 'Create Profile Only'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _createUser(HrProfileService hr, HrUserAdminService hrAdmin) async {
    final name = _nameCtrl.text.trim();
    final email = _emailCtrl.text.trim();

    if (name.isEmpty || email.isEmpty) {
      _snack('Please enter full name and email.');
      return;
    }

    setState(() => _working = true);
    try {
      if (_createAuth) {
        await hrAdmin.createUserAndSendResetEmail(
          fullName: name,
          email: email,
          roleTemplateId: _role,
          programmeId: _programmeCtrl.text.trim(),
          teamId: _teamCtrl.text.trim(),
        );
      } else {
        await hr.createProfileOnly(
          fullName: name,
          email: email,
          roleTemplateId: _role,
          programmeId: _programmeCtrl.text.trim(),
          teamId: _teamCtrl.text.trim(),
        );
      }
      if (!mounted) return;
      _snack(_createAuth ? 'User created ✅ Login email sent.' : 'Profile created ✅');
      Navigator.pop(context);
    } catch (e) {
      _snack('Failed: $e');
    } finally {
      if (mounted) setState(() => _working = false);
    }
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg.replaceAll('Exception: ', ''))),
    );
  }
}
