import 'package:flutter/material.dart';

class TermsPage extends StatelessWidget {
  const TermsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Terms of Service')),
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Terms of Service', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            SizedBox(height: 16),
            Text(
              'Welcome to the SALSO Workforce Management System. By using this application, you agree to the following terms and conditions:',
              style: TextStyle(fontSize: 13, color: Colors.black87),
            ),
            SizedBox(height: 16),
            _section('1. Account Registration',
              'You must provide accurate and complete information when creating your account. '
              'You are responsible for maintaining the confidentiality of your login credentials.'),
            _section('2. Acceptable Use',
              'This system is intended for SALSO workforce management purposes only. '
              'Unauthorised access or misuse of the system is strictly prohibited.'),
            _section('3. Data Accuracy',
              'Employees are responsible for ensuring the accuracy of their time entries, '
              'reports, and personal information submitted through the system.'),
            _section('4. Privacy',
              'Your personal information is handled in accordance with our Privacy Policy '
              'and applicable data protection laws, including POPIA.'),
            _section('5. Intellectual Property',
              'All software, design, and content within this application are the property of SALSO.'),
            _section('6. Limitation of Liability',
              'SALSO shall not be liable for any indirect, incidental, or consequential damages '
              'arising from the use of this system.'),
            _section('7. Modifications',
              'SALSO reserves the right to modify these terms at any time. Users will be notified '
              'of material changes via the application.'),
            SizedBox(height: 24),
            Text('Last updated: June 2026', style: TextStyle(color: Colors.grey, fontSize: 11)),
          ],
        ),
      ),
    );
  }
}

class _section extends StatelessWidget {
  final String title;
  final String body;

  const _section(this.title, this.body);

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
