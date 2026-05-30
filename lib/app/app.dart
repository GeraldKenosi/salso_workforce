import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:hive/hive.dart';

import '../services/auth_service.dart';
import '../services/user_service.dart';
import '../services/attendance_service.dart';
import '../services/attendance_correction_service.dart';
import '../services/attendance_correction_admin_service.dart';
import '../services/report_service.dart';
import '../services/document_service.dart';
import '../services/microsoft_auth_service.dart';
import '../services/sharepoint_upload_service.dart';
import '../services/hr_profile_service.dart';
import '../services/hr_user_admin_service.dart';
import '../services/leave_service.dart';
import '../services/reimbursement_service.dart';
import '../services/contact_service.dart';
import '../services/announcement_service.dart';
import '../services/finance_sop_service.dart';
import '../services/kpi_service.dart';
import '../services/audit_service.dart';
import '../services/notification_service.dart';
import '../services/resource_service.dart';
import '../services/timesheet_service.dart';
import '../services/sync_service.dart';
import '../services/signature_service.dart';
import '../services/workflow_service.dart';
import '../services/register_service.dart';
import '../services/narrative_report_service.dart';
import '../services/analytics_service.dart';
import '../services/file_upload_service.dart';
import '../services/pdf_generator_service.dart';
import '../state/session_provider.dart';
import '../state/connectivity_provider.dart';

import 'router.dart';
import 'theme.dart';

class SalsoWorkforceApp extends StatelessWidget {
  const SalsoWorkforceApp({super.key});

  @override
  Widget build(BuildContext context) {
    final attendanceBox = Hive.box('attendance_events');
    final firestore = FirebaseFirestore.instance;

    final workflowBox = Hive.box('workflow_offline');
    final signatureBox = Hive.box('signature_cache');
    final profileBox = Hive.box('profile_cache');
    final reportBox = Hive.box('report_drafts');

    return MultiProvider(
      providers: [
        Provider(create: (_) => AuthService()),
        Provider(create: (_) => UserService()),

        Provider<AttendanceService>(
          create: (_) {
            final svc = AttendanceService(
              FirebaseAuth.instance,
              firestore,
              attendanceBox,
            );
            svc.startAutoSync();
            return svc;
          },
          dispose: (_, svc) => svc.dispose(),
        ),

        Provider(create: (_) => AttendanceCorrectionService(firestore, FirebaseAuth.instance)),
        Provider(create: (_) => AttendanceCorrectionAdminService(firestore, FirebaseAuth.instance)),
        Provider(create: (_) => ReportService(firestore, FirebaseAuth.instance)),
        Provider(create: (_) => DocumentService(firestore, FirebaseAuth.instance)),
        Provider(create: (_) => MicrosoftAuthService()),
        Provider(create: (ctx) => SharePointUploadService(ctx.read<MicrosoftAuthService>())),
        Provider(create: (_) => HrProfileService(FirebaseFirestore.instance, FirebaseAuth.instance)),
        Provider(create: (_) => HrUserAdminService(FirebaseAuth.instance)),
        Provider(create: (_) => LeaveService(firestore, FirebaseAuth.instance)),
        Provider(create: (_) => ReimbursementService(firestore, FirebaseAuth.instance)),
        Provider(create: (_) => ContactService(firestore, FirebaseAuth.instance)),
        Provider(create: (_) => AnnouncementService(firestore, FirebaseAuth.instance)),

        Provider(create: (_) => FinanceSopService(firestore, FirebaseAuth.instance)),
        Provider(create: (_) => AuditService(firestore, FirebaseAuth.instance)),
        Provider(create: (_) => NotificationService(firestore, FirebaseAuth.instance)),
        Provider(create: (_) => ResourceService(firestore, FirebaseAuth.instance)),
        Provider(create: (_) => TimesheetService(firestore)),

        Provider(create: (_) => KpiService(firestore, FirebaseAuth.instance)),

        Provider<SyncService>(
          create: (_) => SyncService(
            firestore: firestore,
            auth: FirebaseAuth.instance,
            storage: FirebaseStorage.instance,
            hive: workflowBox,
            connectivity: Connectivity(),
          ),
          dispose: (_, svc) => svc.dispose(),
        ),

        Provider(create: (_) => SignatureService(
          FirebaseAuth.instance,
          FirebaseStorage.instance,
          signatureBox,
        )),

        Provider(create: (_) => ConnectivityProvider()),

        Provider(create: (_) => WorkflowService(firestore, FirebaseAuth.instance)),
        Provider(create: (_) => RegisterService(firestore, FirebaseAuth.instance)),
        Provider(create: (_) => NarrativeReportService(firestore, FirebaseAuth.instance)),
        Provider(create: (_) => FileUploadService(FirebaseStorage.instance)),
        Provider(create: (_) => PdfGeneratorService()),
        Provider(create: (_) => AnalyticsService(firestore)),

        ChangeNotifierProvider(
          create: (context) => SessionProvider(
            context.read<AuthService>(),
            context.read<UserService>(),
          ),
        ),
      ],
      child: MaterialApp.router(
        title: 'SALSO Workforce',
        theme: SalsoTheme.light(),
        routerConfig: buildRouter(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
