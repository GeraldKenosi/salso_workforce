import 'package:flutter/material.dart';

class ContactAdminPage extends StatelessWidget {
  const ContactAdminPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Contact Admin')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Icon(Icons.mail_outline, size: 48, color: Color(0xFFD90429)),
          const SizedBox(height: 16),
          const Text(
            'For any account or HR-related queries, please contact the SALSO Administration team:',
            style: TextStyle(fontSize: 14, color: Colors.black87),
          ),
          const SizedBox(height: 20),
          _card(
            icon: Icons.email_outlined,
            title: 'Email',
            value: 'admin@salso.org.za',
          ),
          const SizedBox(height: 12),
          _card(
            icon: Icons.phone_outlined,
            title: 'Phone',
            value: '+27 67 403 7598',
          ),
          const SizedBox(height: 12),
          _card(
            icon: Icons.location_on_outlined,
            title: 'Office',
            value: 'SALSO Head Office\nJohannesburg, South Africa',
          ),
          const SizedBox(height: 20),
          Text(
            'Response time: within 24 hours on business days.',
            style: TextStyle(color: Colors.grey[600], fontSize: 12, fontStyle: FontStyle.italic),
          ),
        ],
      ),
    );
  }

  Widget _card({required IconData icon, required String title, required String value}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFFD90429), size: 24),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
              const SizedBox(height: 2),
              Text(value, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
            ],
          ),
        ],
      ),
    );
  }
}
