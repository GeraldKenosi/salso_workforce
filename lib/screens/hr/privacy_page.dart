import 'package:flutter/material.dart';

class PrivacyPage extends StatelessWidget {
  const PrivacyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Privacy Policy')),
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Privacy Policy', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            SizedBox(height: 16),
            Text(
              'SALSO is committed to protecting your personal information. '
              'This policy explains how we collect, use, and safeguard your data.',
              style: TextStyle(fontSize: 13, color: Colors.black87),
            ),
            SizedBox(height: 16),
            _pSection('Information We Collect',
              'We collect personal information including your name, email address, phone number, '
              'ID number, physical address, and next-of-kin details for workforce management purposes. '
              'We also collect attendance data, reports, and workflow requests.'),
            _pSection('How We Use Your Information',
              'Your information is used for: staff administration, time and attendance tracking, '
              'report management, workflow approvals, compliance with organisational policies, '
              'and communication regarding work-related matters.'),
            _pSection('Data Storage and Security',
              'Your data is stored securely on Firebase (Google Cloud Platform) servers. '
              'We implement appropriate technical and organisational measures to protect your data.'),
            _pSection('Data Sharing',
              'We do not share your personal information with third parties except as required by law '
              'or with your explicit consent. Authorised SALSO administrators have access to employee records.'),
            _pSection('Your Rights',
              'You have the right to access, correct, or request deletion of your personal data. '
              'You may update your profile information through the application. '
              'For data requests, please contact the SALSO administration team.'),
            _pSection('Retention',
              'Employee data is retained for the duration of your employment and for a period '
              'thereafter as required by applicable laws and organisational policies.'),
            _pSection('Cookies and Tracking',
              'This application uses essential authentication tokens and does not use cookies '
              'for tracking purposes.'),
            SizedBox(height: 24),
            Text('Last updated: June 2026', style: TextStyle(color: Colors.grey, fontSize: 11)),
          ],
        ),
      ),
    );
  }
}

class _pSection extends StatelessWidget {
  final String title;
  final String body;

  const _pSection(this.title, this.body);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 4),
          Text(body, style: const TextStyle(fontSize: 13, color: Colors.black87, height: 1.4)),
        ],
      ),
    );
  }
}
