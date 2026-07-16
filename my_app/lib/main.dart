import 'package:flutter/material.dart';
import 'package:my_app/login_screen.dart';

void main() => runApp(const SavingsAccountApp());

class SavingsAccountApp extends StatelessWidget {
  const SavingsAccountApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'บัญชีเงินฝากส่วนตัว',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF00695C)),
          useMaterial3: true,
        ),
        home: const LoginScreen(),
      );
}