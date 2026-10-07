// ==============================================================================
// การตั้งค่าทั่วไปของแอปพลิเคชัน (Application Configuration)
// ==============================================================================

class AppConfig {
  /// Base URL ของ Backend API Server
  /// สามารถกำหนดผ่าน `--dart-define=API_BASE_URL=...` ตอน compile/run ได้
  /// หากไม่กำหนด จะใช้ค่าเริ่มต้นเป็น `http://localhost:3000/api`
  static const String apiBaseUri =
      String.fromEnvironment(
        'API_BASE_URL',
        defaultValue: 'http://localhost:3000/api',
      );
}