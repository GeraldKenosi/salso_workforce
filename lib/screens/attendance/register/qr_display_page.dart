import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';

class QrDisplayPage extends StatelessWidget {
  final String registerId;
  final String registerName;
  const QrDisplayPage({super.key, required this.registerId, required this.registerName});

  @override
  Widget build(BuildContext context) {
    final qrData = jsonEncode({
      'type': 'register',
      'registerId': registerId,
      'registerName': registerName,
    });

    return Scaffold(
      appBar: AppBar(title: const Text('QR Code')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Scan to sign in', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18)),
            const SizedBox(height: 8),
            Text(registerName, style: TextStyle(color: Colors.grey[600], fontSize: 14), textAlign: TextAlign.center),
            const SizedBox(height: 24),
            QrImageView(
              data: qrData,
              version: QrVersions.auto,
              size: 260,
              foregroundColor: Colors.black87,
              backgroundColor: Colors.white,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              icon: const Icon(Icons.copy),
              label: const Text('Copy QR Data'),
              onPressed: () {
                Clipboard.setData(ClipboardData(text: qrData));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('QR data copied.')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
