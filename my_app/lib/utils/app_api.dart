import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:my_app/config/app_config.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppApi {
  static Future<Map<String, dynamic>> post(String path, Map<String, dynamic> body) async {
    final response = await http.post(Uri.parse('${AppConfig.apiBaseUri}$path'),
        headers: const {'Content-Type': 'application/json; charset=UTF-8'}, body: jsonEncode(body));
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  static Future<Map<String, dynamic>> getAuthenticated(String path) async {
    final preferences = await SharedPreferences.getInstance();
    final response = await http.get(Uri.parse('${AppConfig.apiBaseUri}$path'), headers: {
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Bearer ${preferences.getString('access_token') ?? ''}',
    });
    return jsonDecode(response.body) as Map<String, dynamic>;
  }
}
