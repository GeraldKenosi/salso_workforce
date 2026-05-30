import 'package:flutter/material.dart';

class AboutSalsoPage extends StatelessWidget {
  const AboutSalsoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('About SALSO')),
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'About SALSO',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12),
            Text(
              'SALSO (South African Literacy and Skills Organisation) '
              'is a non-profit organisation dedicated to improving literacy '
              'and vocational skills in underserved communities across South Africa.',
              style: TextStyle(height: 1.6),
            ),
            SizedBox(height: 16),
            Text(
              'Our Mission',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'To empower individuals through education and skills development, '
              'creating pathways to economic participation and community upliftment.',
              style: TextStyle(height: 1.6),
            ),
            SizedBox(height: 16),
            Text(
              'This App',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'The SALSO Workforce app helps volunteers and staff manage '
              'attendance, submit reports, access SOPs, and stay connected '
              'with the organisation.',
              style: TextStyle(height: 1.6),
            ),
          ],
        ),
      ),
    );
  }
}