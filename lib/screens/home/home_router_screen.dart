import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../state/session_provider.dart';
import '../auth/login_screen.dart';
import '../shell/app_shell.dart';
import '../../widgets/splash_screen.dart';

class HomeRouterScreen extends StatelessWidget {
  const HomeRouterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final session = context.watch<SessionProvider>();

    if (session.loading) {
      return const SplashScreen();
    }

    // Not logged in
    if (session.firebaseUser == null) {
      return const LoginScreen();
    }

    // Profile error
    if (session.error != null) {
      return Scaffold(
        appBar: AppBar(title: const Text("Account Issue")),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Text(session.error!, textAlign: TextAlign.center),
          ),
        ),
      );
    }

    // Missing role
    final role = session.profile?.roleTemplateId.trim() ?? "";
    if (role.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text("Profile Incomplete")),
        body: const Center(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              "Your profile is missing a role (roleTemplateId).\n\n"
              "Please contact SALSO Admin.",
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }

    // ✅ Logged in + profile ready → show app shell with bottom navigation
    return const AppShell();
  }
}