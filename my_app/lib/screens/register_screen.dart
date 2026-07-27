import 'package:flutter/material.dart';
import 'package:my_app/utils/app_api.dart';

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

  @override
  void dispose() {
    _name.dispose();
    _username.dispose();
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await AppApi.post(
        '/auth/register',
        {
          // ✅ เปลี่ยนจาก full_name เป็น fullname
          'fullname': _name.text.trim(),
          'username': _username.text.trim(),
          'password': _password.text,
        },
      );

      if (!mounted) return;

      _message('สมัครสมาชิกสำเร็จ กรุณาเข้าสู่ระบบ');
      Navigator.pop(context);
    } on ApiException catch (e) {
      if (!mounted) return;
      _message(e.message);
    } catch (e) {
      if (!mounted) return;
      _message('เกิดข้อผิดพลาด : $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _message(String text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(text)),
    );
  }

  Widget _field(
    TextEditingController controller,
    String label,
    IconData icon, {
    bool obscure = false,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
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
      appBar: AppBar(
        title: const Text('สมัครสมาชิก'),
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
                      obscure: true,
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
                      obscure: true,
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