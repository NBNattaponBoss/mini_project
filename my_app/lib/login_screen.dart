import 'package:flutter/material.dart';
import 'package:my_app/screens/home_screen.dart';
import 'package:my_app/screens/register_screen.dart';
import 'package:my_app/utils/app_api.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() { _usernameController.dispose(); _passwordController.dispose(); super.dispose(); }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      final result = await AppApi.post('/auth/login', {'username': _usernameController.text.trim(), 'password': _passwordController.text});
      if (!mounted) return;
      if (result['isError'] == true) { _showMessage(result['errorMessage'] as String? ?? 'เข้าสู่ระบบไม่สำเร็จ'); return; }
      final preferences = await SharedPreferences.getInstance();
      await preferences.setString('access_token', result['data']['access_token']);
      await preferences.setString('username', result['data']['username']);
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (_) => const HomeScreen()), (_) => false);
    } catch (_) { if (mounted) _showMessage('ไม่สามารถเชื่อมต่อกับเซิร์ฟเวอร์ได้'); }
    finally { if (mounted) setState(() => _isLoading = false); }
  }

  void _showMessage(String message) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(child: Center(child: SingleChildScrollView(padding: const EdgeInsets.all(24), child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 420), child: Form(key: _formKey, child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        const Icon(Icons.account_balance_wallet_rounded, size: 76, color: Color(0xFF00695C)), const SizedBox(height: 20),
        Text('บัญชีเงินฝากส่วนตัว', textAlign: TextAlign.center, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8), Text('เข้าสู่ระบบเพื่อจัดการเงินฝากของคุณ', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey.shade700)), const SizedBox(height: 32),
        TextFormField(controller: _usernameController, textInputAction: TextInputAction.next, decoration: const InputDecoration(labelText: 'ชื่อผู้ใช้', prefixIcon: Icon(Icons.person_outline), border: OutlineInputBorder()), validator: (value) => value == null || value.trim().isEmpty ? 'กรุณากรอกชื่อผู้ใช้' : null),
        const SizedBox(height: 16), TextFormField(controller: _passwordController, obscureText: _obscurePassword, onFieldSubmitted: (_) => _login(), decoration: InputDecoration(labelText: 'รหัสผ่าน', prefixIcon: const Icon(Icons.lock_outline), border: const OutlineInputBorder(), suffixIcon: IconButton(icon: Icon(_obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined), onPressed: () => setState(() => _obscurePassword = !_obscurePassword))), validator: (value) => value == null || value.isEmpty ? 'กรุณากรอกรหัสผ่าน' : null),
        const SizedBox(height: 24), FilledButton(onPressed: _isLoading ? null : _login, style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)), child: _isLoading ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('เข้าสู่ระบบ')),
        const SizedBox(height: 12), TextButton(onPressed: _isLoading ? null : () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const RegisterScreen())), child: const Text('ยังไม่มีบัญชี? สมัครสมาชิก')),
      ])))),
    )),
  );
}
