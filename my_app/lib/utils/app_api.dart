import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:my_app/config/app_config.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiException implements Exception {
  ApiException(this.message);

  final String message;
}

class AppApi {
  static Uri _uri(
    String path, [
    Map<String, String>? query,
  ]) {
    return Uri.parse(
      '${AppConfig.apiBaseUri}$path',
    ).replace(
      queryParameters: query,
    );
  }

  static Future<Map<String, dynamic>> _request(
    Future<http.Response> request,
  ) async {
    final response = await request;

    final body = response.body.isEmpty
        ? <String, dynamic>{}
        : jsonDecode(response.body)
            as Map<String, dynamic>;

    if (response.statusCode >= 400 ||
        body['success'] != true) {
      throw ApiException(
        body['message'] as String? ??
            'Request failed.',
      );
    }

    return body;
  }

  static Future<Map<String, String>> _headers({
    bool auth = false,
  }) async {
    final headers = <String, String>{
      'Content-Type': 'application/json',
    };

    if (auth) {
      headers['Authorization'] =
          'Bearer ${(await SharedPreferences.getInstance()).getString('access_token') ?? ''}';
    }

    return headers;
  }

  static Future<Map<String, dynamic>> post(
    String path,
    Map<String, dynamic> body, {
    bool auth = false,
  }) async {
    return _request(
      http.post(
        _uri(path),
        headers: await _headers(auth: auth),
        body: jsonEncode(body),
      ),
    );
  }

  static Future<Map<String, dynamic>> put(
    String path,
    Map<String, dynamic> body,
  ) async {
    return _request(
      http.put(
        _uri(path),
        headers: await _headers(auth: true),
        body: jsonEncode(body),
      ),
    );
  }

  static Future<Map<String, dynamic>> get(
    String path, {
    Map<String, String>? query,
  }) async {
    return _request(
      http.get(
        _uri(path, query),
        headers: await _headers(auth: true),
      ),
    );
  }

  static Future<Map<String, dynamic>> delete(
    String path,
  ) async {
    return _request(
      http.delete(
        _uri(path),
        headers: await _headers(auth: true),
      ),
    );
  }
}