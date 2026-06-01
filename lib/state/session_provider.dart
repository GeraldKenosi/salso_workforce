import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_profile.dart';
import '../services/auth_service.dart';
import '../services/user_service.dart';

class SessionProvider extends ChangeNotifier {
  final AuthService _authService;
  final UserService _userService;

  User? firebaseUser;
  UserProfile? profile;
  bool loading = true;
  String? error;

  SessionProvider(this._authService, this._userService) {
    _authService.authStateChanges().listen(_onAuthChanged);
  }

  Future<void> _onAuthChanged(User? user) async {
    loading = true;
    error = null;
    notifyListeners();

    firebaseUser = user;
    profile = null;

    if (user == null) {
      loading = false;
      notifyListeners();
      return;
    }

    try {
      final p = await _userService.getUserProfile(user.uid);

      if (p == null) {
        error = "No profile found for this user. Please contact SALSO Admin.";
      } else if (p.status != 'active') {
        error = "Your account is not active. Please contact SALSO Admin.";
      } else {
        profile = p;
      }
    } catch (_) {
      error = "Failed to load profile. Please try again.";
    }

    loading = false;
    notifyListeners();
  }

  Future<void> refreshProfile() async {
    if (firebaseUser == null) return;
    try {
      final p = await _userService.getUserProfile(firebaseUser!.uid);
      profile = p;
      notifyListeners();
    } catch (_) {}
  }

  Future<void> signOut() async {
    await _authService.signOut();
  }
}