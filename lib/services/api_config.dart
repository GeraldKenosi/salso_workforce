class ApiConfig {
  ApiConfig._();

  /// Base URL for the Render API server.
  /// Change this to your production URL when deployed.
  static const String baseUrl = 'https://api.salso.org.za';

  static const String hrCreateUser = '$baseUrl/api/hr-create-user';
  static const String fileTransferSharePoint = '$baseUrl/api/file-transfer-sharepoint';
  static const String qrSelfService = '$baseUrl/api/qr-self-service';
  static const String signIn = '$baseUrl/api/sign-in';
  static const String health = '$baseUrl/api/health';
}
