import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../state/session_provider.dart';
import '../../utils/display_labels.dart';
import '../../app/theme.dart';
import '../tabs/tab_home.dart';
import '../tabs/tab_attendance.dart';
import '../tabs/tab_reports.dart';
import '../tabs/tab_sops.dart';
import '../tabs/tab_profile.dart';
import '../hr/hr_employee_directory_page.dart';
import '../hr/contact_admin_page.dart';
import '../hr/terms_page.dart';
import '../hr/privacy_page.dart';
import '../resources/resources_screen.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _index = 0;

  final _pages = const [
    TabHome(),
    TabAttendance(),
    TabReports(),
    TabSOPs(),
    TabProfile(),
  ];

  final _items = const [
    BottomNavigationBarItem(icon: Icon(Icons.dashboard_outlined), activeIcon: Icon(Icons.dashboard), label: "Home"),
    BottomNavigationBarItem(icon: Icon(Icons.access_time), activeIcon: Icon(Icons.access_time_filled), label: "Attend"),
    BottomNavigationBarItem(icon: Icon(Icons.description_outlined), activeIcon: Icon(Icons.description), label: "Reports"),
    BottomNavigationBarItem(icon: Icon(Icons.assignment_outlined), activeIcon: Icon(Icons.assignment), label: "SOPs"),
    BottomNavigationBarItem(icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person), label: "Profile"),
  ];

  bool _hasAccess(String roleTemplateId, int tabIndex) {
    if (roleTemplateId == 'executiveDirector') return true;
    switch (roleTemplateId) {
      case 'manager':
        return true;
      case 'admin':
        return tabIndex != 1;
      case 'coordinator':
        return tabIndex != 3;
      case 'teamLeader':
        return tabIndex != 3;
      default:
        return (tabIndex == 1 || tabIndex == 2 || tabIndex == 4);
    }
  }

  void _onTap(int newIndex, String roleTemplateId) {
    if (_hasAccess(roleTemplateId, newIndex)) {
      setState(() => _index = newIndex);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("This area is restricted."),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final session = context.watch<SessionProvider>();
    final role = session.profile?.roleTemplateId.trim() ?? '';

    final name = session.profile?.fullName ?? 'User';
    final email = session.profile?.email ?? '';
    final roleLabel = DisplayLabels.roleLabel(session.profile?.roleTemplateId ?? '');

    return Scaffold(
      drawer: Drawer(
        child: Column(
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(color: SalsoTheme.primary),
              child: SizedBox(
                width: double.infinity,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: Colors.white.withValues(alpha: 0.2),
                      child: Text(name.isNotEmpty ? name[0].toUpperCase() : '?', style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(height: 10),
                    Text(name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                    Text(email, style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 12)),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(10)),
                      child: Text(roleLabel, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w600)),
                    ),
                  ],
                ),
              ),
            ),
            _drawerItem(Icons.people_outline, 'Employee Directory', () { Navigator.pop(context); Navigator.push(context, MaterialPageRoute(builder: (_) => const HrEmployeeDirectoryPage())); }),
            _drawerItem(Icons.mail_outline, 'Contact Admin', () { Navigator.pop(context); Navigator.push(context, MaterialPageRoute(builder: (_) => const ContactAdminPage())); }),
            _drawerItem(Icons.library_books_outlined, 'Resources', () { Navigator.pop(context); Navigator.push(context, MaterialPageRoute(builder: (_) => const ResourcesScreen())); }),
            const Spacer(),
            const Divider(height: 1),
            _drawerItem(Icons.description_outlined, 'Terms of Service', () { Navigator.pop(context); Navigator.push(context, MaterialPageRoute(builder: (_) => const TermsPage())); }),
            _drawerItem(Icons.privacy_tip_outlined, 'Privacy Policy', () { Navigator.pop(context); Navigator.push(context, MaterialPageRoute(builder: (_) => const PrivacyPage())); }),
            const Divider(height: 1),
            _drawerItem(Icons.logout, 'Sign Out', () {
              Navigator.pop(context);
              session.signOut();
            }, color: SalsoTheme.primary),
            const SizedBox(height: 16),
          ],
        ),
      ),
      body: Builder(
        builder: (ctx) => Stack(
          children: [
            IndexedStack(
              index: _index,
              children: _pages,
            ),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.only(left: 12, top: 8),
                child: Align(
                  alignment: Alignment.topLeft,
                  child: Material(
                    color: Colors.white,
                    elevation: 3,
                    borderRadius: BorderRadius.circular(10),
                    shadowColor: Colors.black26,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(10),
                      onTap: () => Scaffold.of(ctx).openDrawer(),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        child: const Icon(Icons.menu, color: Color(0xFFD90429), size: 22),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(left: 12, right: 12, bottom: 8),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200, width: 1),
                boxShadow: [
                  BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 8, offset: const Offset(0, -2)),
                ],
              ),
              child: BottomNavigationBar(
                items: _items,
                currentIndex: _index,
                onTap: (i) => _onTap(i, role),
                type: BottomNavigationBarType.fixed,
                backgroundColor: Colors.transparent,
                elevation: 0,
                selectedLabelStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
                unselectedLabelStyle: const TextStyle(fontSize: 11),
                selectedItemColor: const Color(0xFFD90429),
                unselectedItemColor: Colors.grey,
                showSelectedLabels: true,
                showUnselectedLabels: true,
                selectedIconTheme: const IconThemeData(color: Color(0xFFD90429), size: 22),
                unselectedIconTheme: IconThemeData(color: Colors.grey.shade400, size: 22),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _drawerItem(IconData icon, String label, VoidCallback onTap, {Color? color}) {
    return ListTile(
      leading: Icon(icon, color: color ?? Colors.grey[700], size: 22),
      title: Text(label, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: color ?? Colors.grey[800])),
      onTap: onTap,
      dense: true,
      visualDensity: VisualDensity.compact,
    );
  }
}
