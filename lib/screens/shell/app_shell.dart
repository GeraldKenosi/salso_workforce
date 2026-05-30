import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../state/session_provider.dart';
import '../tabs/tab_home.dart';
import '../tabs/tab_attendance.dart';
import '../tabs/tab_reports.dart';
import '../tabs/tab_sops.dart';
import '../tabs/tab_profile.dart';

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

    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: _pages,
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
}
