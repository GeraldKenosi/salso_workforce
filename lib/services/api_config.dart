class ApiConfig {
  ApiConfig._();

  /// Base URL for the Render API server.
  /// Change to your custom domain when ready (e.g. https://api.salso.org.za).
  static const String baseUrl = 'https://salso-workforce-api.onrender.com';

  static const String hrCreateUser = '$baseUrl/api/hr-create-user';
  static const String fileTransferSharePoint = '$baseUrl/api/file-transfer-sharepoint';
  static const String qrSelfService = '$baseUrl/api/qr-self-service';
  static const String signIn = '$baseUrl/api/sign-in';
  static const String health = '$baseUrl/api/health';
}
