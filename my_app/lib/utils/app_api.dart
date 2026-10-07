// ==============================================================================
// AppAPI Service: ศูนย์กลางจัดการ HTTP Requests และ Network Communication
// ==============================================================================
// ทำหน้าที่เป็น HTTP Client Wrapper สำหรับ:
// 1. จัดการ Base URL และสร้าง Uri พร้อม Query Parameters
// 2. แนบ HTTP Headers มาตรฐาน (Content-Type, Accept)
// 3. แนบ Authorization Bearer Token จาก SharedPreferences โดยอัตโนมัติ
// 4. ทำ Interceptor ดักจับ HTTP 401 Unauthorized เมื่อ Token หมดอายุ เพื่อเคลียร์ Session และเตะกลับหน้า Login

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:my_app/config/app_config.dart';
import 'package:my_app/login_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppAPI {
  /// GlobalKey สำหรับเข้าถึง NavigatorState ของ MaterialApp ได้จากทุกที่
  /// ใช้สำหรับ Redirect ไปยังหน้า Login เมื่อเกิดเหตุการณ์ Unauthorized (401) โดยไม่ต้องพึ่งพา BuildContext
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  /// Flag ป้องกันการทำงานซ้ำซ้อนกรณีเกิด 401 พร้อมกันหลาย Request
  static bool _isHandlingUnauthorized = false;

  /// สร้าง Uri พร้อมรวม Query Parameters (ถ้ามี)
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

  /// สร้าง HTTP Headers มาตรฐาน และแนบ Bearer Token จาก SharedPreferences หากกำหนด auth = true
  static Future<Map<String, String>> _headers({
    bool auth = true,
  }) async {
    final headers = <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'Accept': 'application/json',
    };

    if (auth) {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token');
      if (token != null && token.isNotEmpty) {
        // แนบ JWT Token ในรูปแบบ Bearer Token เพื่อให้ Backend ตรวจสอบสิทธิ์
        headers['Authorization'] = 'Bearer $token';
      }
    }

    return headers;
  }

  /// จัดการกรณี Token หมดอายุหรือไม่ถูกต้อง (HTTP 401 Unauthorized):
  /// ลบ Token ออกจากเครื่อง และนำทางผู้ใช้กลับไปยังหน้า Login ทันที
  static Future<void> _handleUnauthorized() async {
    if (_isHandlingUnauthorized) return;
    _isHandlingUnauthorized = true;

    try {
      // ลบ Access Token และ Username ออกจากเครื่อง
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('access_token');
      await prefs.remove('username');

      // นำทางกลับไปยัง LoginScreen และล้าง Route Stack ทั้งหมด
      final navState = navigatorKey.currentState;
      if (navState != null && navState.mounted) {
        navState.pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (_) => const LoginScreen(),
          ),
          (route) => false,
        );
      }
    } finally {
      // หน่วงเวลาเล็กน้อยก่อนรีเซ็ต Flag เพื่อป้องกันการเรียกซ้ำ
      Future.delayed(const Duration(seconds: 2), () {
        _isHandlingUnauthorized = false;
      });
    }
  }

  /// Interceptor ตรวจสอบ Response Status Code หลังจากการยิง Request
  static Future<http.Response> _processResponse(
    http.Response response,
    bool auth,
  ) async {
    if (auth && response.statusCode == 401) {
      await _handleUnauthorized();
    }
    return response;
  }

  /// ส่ง HTTP GET Request
  static Future<http.Response> get(
    String path, {
    Map<String, String>? query,
    bool auth = true,
  }) async {
    final response = await http.get(
      _uri(path, query),
      headers: await _headers(auth: auth),
    );
    return _processResponse(response, auth);
  }

  /// ส่ง HTTP POST Request พร้อมแปลง body Map เป็น JSON String
  static Future<http.Response> post(
    String path,
    Map<String, dynamic> body, {
    bool auth = true,
  }) async {
    final response = await http.post(
      _uri(path),
      headers: await _headers(auth: auth),
      body: jsonEncode(body),
    );
    return _processResponse(response, auth);
  }

  /// ส่ง HTTP PUT Request สำหรับแก้ไขข้อมูล
  static Future<http.Response> put(
    String path,
    Map<String, dynamic> body, {
    bool auth = true,
  }) async {
    final response = await http.put(
      _uri(path),
      headers: await _headers(auth: auth),
      body: jsonEncode(body),
    );
    return _processResponse(response, auth);
  }

  /// ส่ง HTTP DELETE Request สำหรับลบข้อมูล
  static Future<http.Response> delete(
    String path, {
    bool auth = true,
  }) async {
    final response = await http.delete(
      _uri(path),
      headers: await _headers(auth: auth),
    );
    return _processResponse(response, auth);
  }
}