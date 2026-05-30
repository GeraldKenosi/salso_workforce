import 'package:msal_flutter/msal_flutter.dart';

class MicrosoftAuthService {
  // ✅ Replace with your real values
  static const String clientId = '877f94de-6653-4447-b151-f3cfcfb1c36b';
  static const String authority =
      'https://login.microsoftonline.com/55218b8a-fe5d-49d4-93c6-39c6e9a35df8';

  static const List<String> scopes = [
    'https://graph.microsoft.com/Sites.ReadWrite.All',
  ];

  PublicClientApplication? _pca;

  MicrosoftAuthService();

  Future<PublicClientApplication> _getPca() async {
    _pca ??= await PublicClientApplication.createPublicClientApplication(
      clientId,
      authority: authority,
    );
    return _pca!;
  }

  Future<String> getAccessToken() async {
    final pca = await _getPca();
    try {
      return await pca.acquireTokenSilent(scopes);
    } on MsalException {
      return await pca.acquireToken(scopes);
    }
  }

  Future<void> signOut() async {
    try {
      final pca = await _getPca();
      await pca.logout();
    } on MsalException {
      // ignore
    }
  }
}