import 'package:go_router/go_router.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/forgot_password_screen.dart';
import '../screens/home/home_router_screen.dart';

// Existing screens
import '../screens/admin/ed_dashboard_screen.dart';
import '../screens/admin/admin_dashboard_screen.dart';
import '../screens/finance/finance_sop_list_screen.dart';
import '../screens/finance/finance_sop_approvals_screen.dart';
import '../screens/kpi/kpi_dashboard_screen.dart';
import '../screens/audit/audit_log_screen.dart';
import '../screens/notifications/notifications_screen.dart';
import '../screens/resources/resources_screen.dart';
import '../screens/reports/create_report_screen.dart';
import '../screens/reports/report_detail_page.dart';
import '../screens/attendance/my_attendance_history_page.dart';
import '../screens/sops/sop_library_page.dart';
import '../screens/leave/leave_screen.dart';
import '../screens/leave/leave_approvals_page.dart';
import '../screens/reimbursement/reimbursement_screen.dart';
import '../screens/reimbursement/reimbursement_approvals_page.dart';
import '../screens/menu/about_salso_page.dart';
import '../screens/menu/privacy_policy_page.dart';
import '../screens/menu/terms_of_service_page.dart';
import '../screens/menu/contact_admin_page.dart';
import '../screens/menu/blog_news_page.dart';
import '../screens/hr/hr_home_page.dart';
import '../screens/documents/documents_screen.dart';

// NEW screens
import '../screens/profile/edit_profile_page.dart';
import '../screens/attendance/register/register_list_page.dart';
import '../screens/attendance/register/create_register_page.dart';
import '../screens/attendance/register/register_detail_page.dart';
import '../screens/attendance/register/add_participant_page.dart';
import '../screens/attendance/register/qr_display_page.dart';
import '../screens/attendance/register/close_register_page.dart';
import '../screens/attendance/register/late_additions_page.dart';
import '../screens/reports/narrative/narrative_report_stepper.dart';
import '../screens/reports/narrative/narrative_report_list_page.dart';
import '../screens/reports/narrative/narrative_report_detail_page.dart';
import '../screens/reports/report_analytics_page.dart';
import '../screens/sops/sop_form_page.dart';
import '../screens/sops/approvals_dashboard_page.dart';
import '../screens/sops/my_requests_page.dart';
import '../screens/sops/sop_request_detail_page.dart';
import '../screens/kpi/kpi_config_page.dart';
import '../screens/kpi/kpi_team_page.dart';
import '../screens/kpi/kpi_org_page.dart';
import '../screens/kpi/kpi_one_on_one_page.dart';

GoRouter buildRouter() {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(path: '/', builder: (_, __) => const HomeRouterScreen()),
      GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
      GoRoute(path: '/forgot-password', builder: (_, __) => const ForgotPasswordScreen()),

      // Existing routes
      GoRoute(path: '/ed-dashboard', builder: (_, __) => const EdDashboardScreen()),
      GoRoute(path: '/admin-dashboard', builder: (_, __) => const AdminDashboardScreen()),
      GoRoute(path: '/finance/sops', builder: (_, __) => const FinanceSopListScreen()),
      GoRoute(path: '/finance/approvals', builder: (_, __) => const FinanceSopApprovalsScreen(approvalStep: 'manager')),
      GoRoute(path: '/finance/ed-approvals', builder: (_, __) => const FinanceSopApprovalsScreen(approvalStep: 'ed')),
      GoRoute(path: '/kpi', builder: (_, __) => const KpiDashboardScreen()),
      GoRoute(path: '/audit-log', builder: (_, __) => const AuditLogScreen()),
      GoRoute(path: '/notifications', builder: (_, __) => const NotificationsScreen()),
      GoRoute(path: '/resources', builder: (_, __) => const ResourcesScreen()),
      GoRoute(path: '/reports/create', builder: (_, __) => const CreateReportScreen()),
      GoRoute(path: '/attendance/history', builder: (_, __) => const MyAttendanceHistoryPage()),
      GoRoute(path: '/sops', builder: (_, __) => const SopLibraryPage()),
      GoRoute(path: '/leave', builder: (_, __) => const LeaveScreen()),
      GoRoute(path: '/leave/approvals', builder: (_, __) => const LeaveApprovalsPage()),
      GoRoute(path: '/reimbursements', builder: (_, __) => const ReimbursementScreen()),
      GoRoute(path: '/reimbursements/approvals', builder: (_, __) => const ReimbursementApprovalsPage()),
      GoRoute(path: '/about', builder: (_, __) => const AboutSalsoPage()),
      GoRoute(path: '/privacy', builder: (_, __) => const PrivacyPolicyPage()),
      GoRoute(path: '/terms', builder: (_, __) => const TermsOfServicePage()),
      GoRoute(path: '/contact', builder: (_, __) => const ContactAdminPage()),
      GoRoute(path: '/announcements', builder: (_, __) => const BlogNewsPage()),
      GoRoute(path: '/hr', builder: (_, __) => const HrHomePage()),
      GoRoute(path: '/documents', builder: (_, __) => const DocumentsScreen()),

      // NEW: Profile
      GoRoute(path: '/profile/edit', builder: (_, __) => const EditProfilePage()),

      // NEW: Attendance Registers
      GoRoute(path: '/registers', builder: (_, __) => const RegisterListPage()),
      GoRoute(path: '/registers/create', builder: (_, __) => const CreateRegisterPage()),
      GoRoute(path: '/registers/:id', builder: (_, state) => RegisterDetailPage(
        registerId: state.pathParameters['id'] ?? '',
        registerData: state.extra as Map<String, dynamic>? ?? {},
      )),
      GoRoute(path: '/registers/:id/add', builder: (_, state) => AddParticipantPage(
        registerId: state.pathParameters['id'] ?? '',
        registerName: state.extra as String? ?? '',
      )),
      GoRoute(path: '/registers/:id/qr', builder: (_, state) => QrDisplayPage(
        registerId: state.pathParameters['id'] ?? '',
        registerName: state.extra as String? ?? '',
      )),
      GoRoute(path: '/registers/:id/close', builder: (_, state) => CloseRegisterPage(
        registerId: state.pathParameters['id'] ?? '',
        registerName: state.extra as String? ?? '',
        currentCount: state.extra is int ? state.extra as int : 0,
      )),
      GoRoute(path: '/registers/:id/late', builder: (_, state) => LateAdditionsPage(
        registerId: state.pathParameters['id'] ?? '',
        registerName: state.extra as String? ?? '',
      )),

      // NEW: Narrative Reports
      GoRoute(path: '/reports/narrative/new', builder: (_, __) => const NarrativeReportStepper()),
      GoRoute(path: '/reports/narrative/list', builder: (_, __) => const NarrativeReportListPage()),
      GoRoute(path: '/reports/narrative/analytics', builder: (_, __) => const ReportAnalyticsPage()),

      // NEW: SOP Workflow
      GoRoute(path: '/sop/new/:type', builder: (_, state) => SopFormPage(type: state.pathParameters['type'] ?? 'general')),
      GoRoute(path: '/sop/approvals', builder: (_, __) => const ApprovalsDashboardPage()),
      GoRoute(path: '/sop/my-requests', builder: (_, __) => const MyRequestsPage()),

      // NEW: KPI
      GoRoute(path: '/kpi/config', builder: (_, __) => const KpiConfigPage()),
      GoRoute(path: '/kpi/team', builder: (_, __) => const KpiTeamPage()),
      GoRoute(path: '/kpi/org', builder: (_, __) => const KpiOrgPage()),
      GoRoute(path: '/kpi/one-on-one', builder: (_, __) => const KpiOneOnOnePage()),
    ],
  );
}
