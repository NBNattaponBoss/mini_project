// ==============================================================================
// Register Screen: หน้าจอสมัครสมาชิกใหม่สำหรับสร้างบัญชีผู้ใช้งาน
// ==============================================================================

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:my_app/theme/app_colors.dart';
import 'package:my_app/utils/app_api.dart';
import 'package:my_app/widgets/animated_header.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  final _name = TextEditingController();
  final _username = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _name.dispose();
    _username.dispose();
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  /// ฟังก์ชันส่งคำขอสมัครสมาชิก (Register Flow):
  /// 1. ตรวจสอบความถูกต้องของ Form (Validation: กรอกครบ, รหัสผ่าน >= 6 ตัวอักษร, รหัสผ่านตรงกัน)
  /// 2. เรียก API POST `/auth/register` พร้อมแนบ fullname, username, password
  /// 3. หากสำเร็จ แสดง Alert ยืนยัน และพากลับไปยังหน้า Login เพื่อเข้าสู่ระบบ
  /// 4. หากชื่อผู้ใช้ซ้ำหรือข้อมูลผิดพลาด แสดง Alert แจ้งเตือน
  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final response = await AppAPI.post(
        '/auth/register',
        {
          'fullname': _name.text.trim(),
          'username': _username.text.trim(),
          'password': _password.text,
        },
        auth: false,
      );

      final json = jsonDecode(response.body);
      final isError = json['isError'] ?? (json['success'] == false);
      final errorMessage = json['errorMessage'] ?? json['message'] ?? '';

      if (!isError) {
        if (!mounted) return;
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            title: const Text('สำเร็จ'),
            content: const Text('สมัครสมาชิกสำเร็จ กรุณาเข้าสู่ระบบ'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // ปิด Dialog
                  Navigator.pop(context); // ย้อนกลับไปยังหน้า LoginScreen
                },
                child: const Text('ตกลง'),
              ),
            ],
          ),
        );
      } else {
        if (!mounted) return;
        _showErrorDialog(
          errorMessage.isNotEmpty
              ? errorMessage
              : 'เกิดข้อผิดพลาดในการสมัครสมาชิก',
        );
      }
    } catch (e) {
      if (!mounted) return;
      _showErrorDialog('Unable to connect to the server.');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }


  void _showErrorDialog(String text) {
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('แจ้งเตือน'),
        content: Text(text),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ตกลง'),
          ),
        ],
      ),
    );
  }

  Widget _field(
    TextEditingController controller,
    String label,
    IconData icon, {
    bool obscure = false,
    Widget? suffixIcon,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        suffixIcon: suffixIcon,
        border: const OutlineInputBorder(),
      ),
      validator: validator ??
          (value) =>
              value == null || value.trim().isEmpty
                  ? 'กรุณากรอก$label'
                  : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AnimatedTangKepHeader(
        title: 'สมัครสมาชิก',
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Icon(
                      Icons.person_add_alt_1_rounded,
                      size: 64,
                      color: Color(0xFF00695C),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'สร้างบัญชีผู้ใช้',
                      textAlign: TextAlign.center,
                      style: Theme.of(context)
                          .textTheme
                          .headlineSmall
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 28),

                    _field(
                      _name,
                      'ชื่อ-นามสกุล',
                      Icons.badge_outlined,
                    ),

                    const SizedBox(height: 16),

                    _field(
                      _username,
                      'ชื่อผู้ใช้',
                      Icons.person_outline,
                    ),

                    const SizedBox(height: 16),

                    _field(
                      _password,
                      'รหัสผ่าน',
                      Icons.lock_outline,
                      obscure: _obscurePassword,
                      suffixIcon: IconButton(
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.length < 6) {
                          return 'รหัสผ่านต้องมีอย่างน้อย 6 ตัวอักษร';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    _field(
                      _confirm,
                      'ยืนยันรหัสผ่าน',
                      Icons.lock_reset_outlined,
                      obscure: _obscureConfirmPassword,
                      suffixIcon: IconButton(
                        onPressed: () {
                          setState(() {
                            _obscureConfirmPassword =
                                !_obscureConfirmPassword;
                          });
                        },
                        icon: Icon(
                          _obscureConfirmPassword
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      validator: (value) {
                        if (value != _password.text) {
                          return 'รหัสผ่านไม่ตรงกัน';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 24),

                    FilledButton(
                      onPressed: _isLoading ? null : _register,
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                              ),
                            )
                          : const Text('สมัครสมาชิก'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}