/// Build-time configuration.
/// Real backend:  flutter run --dart-define=MOCK_API=false --dart-define=API_BASE_URL=https://api.example.com
class AppConfig {
  AppConfig._();
  static const bool useMockApi = bool.fromEnvironment('MOCK_API', defaultValue: true);
  static const String baseUrl = String.fromEnvironment('API_BASE_URL', defaultValue: 'https://api.one.example.com/v1');
  static const Duration timeout = Duration(seconds: 15);
  static const Duration mockLatency = Duration(milliseconds: 350);
}
