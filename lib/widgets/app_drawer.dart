import 'package:flutter/material.dart';
import '../state/session_provider.dart';
import '../app/theme.dart';
import '../screens/menu/about_salso_page.dart';
import '../screens/menu/privacy_policy_page.dart';
import '../screens/menu/terms_of_service_page.dart';
import '../screens/menu/contact_admin_page.dart';
import '../screens/menu/blog_news_page.dart';
import '../screens/hr/hr_home_page.dart';
import '../screens/audit/audit_log_screen.dart';
import '../screens/admin/ed_dashboard_screen.dart';
import '../screens/notifications/notifications_screen.dart';
import '../screens/resources/resources_screen.dart';
import '../screens/finance/finance_sop_list_screen.dart';
import '../screens/finance/finance_sop_approvals_screen.dart';

class AppDrawer extends StatelessWidget {
  final String roleTemplateId;
  final VoidCallback onLogout;

  const AppDrawer({
    super.key,
    required this.roleTemplateId,
    required this.onLogout,
  });

  bool get _canSeeHr =>
      roleTemplateId == 'executiveDirector' || roleTemplateId == 'manager' || roleTemplateId == 'admin' || roleTemplateId == 'coordinator';
  bool get _isEd => roleTemplateId == 'executiveDirector';
  bool get _isManager => roleTemplateId == 'manager' || _isEd;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(color: SalsoTheme.primary),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Image.asset(
                    'assets/branding/salso_logo_horizontal.png',
                    height: 40,
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => const Text(
                      'SALSO Workforce',
                      style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _isEd ? 'Executive Director' : _canSeeHr ? 'Administrator' : 'Staff',
                    style: TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                ],
              ),
            ),

            if (_isEd) ...[
              _menuItem(context, Icons.dashboard, 'ED Dashboard', () => _push(context, const EdDashboardScreen())),
            ],

            _menuItem(context, Icons.notifications_outlined, 'Notifications', () => _push(context, const NotificationsScreen())),

            if (_canSeeHr)
              _menuItem(context, Icons.badge_outlined, 'HR', () => _push(context, const HrHomePage())),
            if (_isManager)
              _menuItem(context, Icons.receipt_long_outlined, 'Finance SOPs', () => _push(context, const FinanceSopListScreen())),
            if (_isManager)
              _menuItem(context, Icons.approval_outlined, 'Finance Approvals', () => _push(context, const FinanceSopApprovalsScreen(approvalStep: 'manager'))),
            if (_isEd) ...[
              _menuItem(context, Icons.account_balance, 'Finance — Final Approval', () => _push(context, const FinanceSopApprovalsScreen(approvalStep: 'ed'))),
              _menuItem(context, Icons.history, 'Audit Log', () => _push(context, const AuditLogScreen())),
            ],
            _menuItem(context, Icons.library_books_outlined, 'Resources', () => _push(context, const ResourcesScreen())),

            const Divider(),
            _menuItem(context, Icons.info_outline, 'About SALSO', () => _push(context, const AboutSalsoPage())),
            _menuItem(context, Icons.article_outlined, 'Announcements', () => _push(context, const BlogNewsPage())),
            _menuItem(context, Icons.privacy_tip_outlined, 'Privacy Policy', () => _push(context, const PrivacyPolicyPage())),
            _menuItem(context, Icons.gavel_outlined, 'Terms of Service', () => _push(context, const TermsOfServicePage())),
            _menuItem(context, Icons.support_agent_outlined, 'Contact Admin', () => _push(context, const ContactAdminPage())),

            const Divider(),
            _menuItem(context, Icons.logout, 'Log out', () {
              Navigator.pop(context);
              onLogout();
            }, color: Colors.red),
          ],
        ),
      ),
    );
  }

  Widget _menuItem(BuildContext context, IconData icon, String title, VoidCallback onTap, {Color? color}) {
    return ListTile(
      leading: Icon(icon, color: color ?? Colors.grey[700], size: 22),
      title: Text(title, style: TextStyle(color: color ?? Colors.black87, fontSize: 14)),
      onTap: onTap,
      dense: true,
    );
  }

  void _push(BuildContext context, Widget page) {
    Navigator.pop(context);
    Navigator.push(context, MaterialPageRoute(builder: (_) => page));
  }
}
