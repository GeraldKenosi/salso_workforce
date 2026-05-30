import 'package:flutter/material.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Privacy Policy')),
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Privacy Policy',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12),
            Text(
              'Last updated: 2026',
              style: TextStyle(color: Colors.black54),
            ),
            SizedBox(height: 16),
            Text(
              'SALSO respects your privacy. This app collects and stores '
              'the following data:',
              style: TextStyle(height: 1.6),
            ),
            SizedBox(height: 12),
            Text('• Name and email address (for authentication and identification)'),
            Text('• Attendance records with GPS location (for work hours tracking)'),
            Text('• Documents you upload (CV, ID, contracts for HR compliance)'),
            Text('• Reports and communications you submit'),
            SizedBox(height: 12),
            Text(
              'Your data is stored securely in Firebase (Google Cloud) and '
              'SharePoint (Microsoft). It is not shared with third parties '
              'except as required by law.',
              style: TextStyle(height: 1.6),
            ),
            SizedBox(height: 12),
            Text(
              'You may request deletion of your data by contacting SALSO admin.',
              style: TextStyle(height: 1.6),
            ),
          ],
        ),
      ),
    );
  }
}