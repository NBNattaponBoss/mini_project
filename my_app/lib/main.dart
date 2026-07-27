import 'package:flutter/material.dart';
import 'package:my_app/login_screen.dart';
import 'package:my_app/screens/home_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(
    const PersonalAccountApp(),
  );
}

class PersonalAccountApp extends StatelessWidget {
  const PersonalAccountApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Personal Account',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF00695C),
        ),
        scaffoldBackgroundColor: const Color(0xFFF7F9F8),
        useMaterial3: true,
      ),
      home: const _SessionGate(),
    );
  }
}

class _SessionGate extends StatelessWidget {
  const _SessionGate();

  Future<bool> _hasToken() async {
    return (await SharedPreferences.getInstance())
            .getString('access_token')
            ?.isNotEmpty ==
        true;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _hasToken(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        return snapshot.data!
            ? const HomeScreen()
            : const LoginScreen();
      },
    );
  }
}