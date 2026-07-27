/*class AppConfig {
  // Android emulator uses 10.0.2.2 to reach the host machine. Replace when using a physical device.
  static const String apiBaseUri = String.fromEnvironment('API_BASE_URL', defaultValue: 'http://10.0.2.2:3000/api');
}*/

class AppConfig {
  static const String apiBaseUri =
      String.fromEnvironment(
        'API_BASE_URL',
        defaultValue: 'http://localhost:3000/api',
      );
}