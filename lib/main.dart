import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'firebase_options.dart';
import 'app/app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Offline storage init (works on mobile + web)
  await Hive.initFlutter();
  await Hive.openBox('attendance_events');
  await Hive.openBox('workflow_offline');
  await Hive.openBox('signature_cache');
  await Hive.openBox('profile_cache');
  await Hive.openBox('report_drafts');

  runApp(const SalsoWorkforceApp());
}