import 'package:flutter/material.dart';

class TermsOfServicePage extends StatelessWidget {
  const TermsOfServicePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Terms of Service')),
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Terms of Service',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12),
            Text(
              'Last updated: 2026',
              style: TextStyle(color: Colors.black54),
            ),
            SizedBox(height: 16),
            Text(
              'By using the SALSO Workforce app, you agree to the following terms:',
              style: TextStyle(height: 1.6),
            ),
            SizedBox(height: 12),
            Text(
              '1. You will use the app only for legitimate SALSO-related activities.',
              style: TextStyle(height: 1.4),
            ),
            SizedBox(height: 6),
            Text(
              '2. You will record accurate attendance information.',
              style: TextStyle(height: 1.4),
            ),
            SizedBox(height: 6),
            Text(
              '3. You will not share your login credentials with anyone.',
              style: TextStyle(height: 1.4),
            ),
            SizedBox(height: 6),
            Text(
              '4. You will adhere to SALSO policies and SOPs.',
              style: TextStyle(height: 1.4),
            ),
            SizedBox(height: 6),
            Text(
              '5. SALSO reserves the right to modify or discontinue the app at any time.',
              style: TextStyle(height: 1.4),
            ),
            SizedBox(height: 6),
            Text(
              '6. SALSO is not liable for any damages arising from app usage.',
              style: TextStyle(height: 1.4),
            ),
            SizedBox(height: 16),
            Text(
              'If you do not agree with these terms, please stop using the app '
              'and contact SALSO administration.',
              style: TextStyle(height: 1.6),
            ),
          ],
        ),
      ),
    );
  }
}