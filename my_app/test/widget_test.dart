// ==============================================================================
// Flutter Widget & Unit Tests: ชุดการทดสอบ Widget และฟังก์ชันต่างๆ ของแอปพลิเคชัน
// ==============================================================================

import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_app/login_screen.dart';
import 'package:my_app/main.dart';
import 'package:my_app/models/transaction_model.dart';
import 'package:my_app/screens/monthly_summary_screen.dart';
import 'package:my_app/screens/register_screen.dart';
import 'package:my_app/screens/splash_screen.dart';
import 'package:my_app/theme/app_theme.dart';
import 'package:my_app/utils/app_api.dart';
import 'package:my_app/utils/profile_image_service.dart';
import 'package:my_app/widgets/animated_header.dart';
import 'package:my_app/widgets/empty_state.dart';
import 'package:my_app/widgets/profile_avatar.dart';
import 'package:my_app/widgets/transaction_card.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  // ทดสอบการแสดงผลหน้า MonthlySummaryScreen (หัวข้อและแถบเลือกรอบเดือน)
  testWidgets(
    'MonthlySummaryScreen displays header and summary title',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const MonthlySummaryScreen(),
        ),
      );

      // ตรวจสอบข้อความบน Header
      expect(find.text('สรุป'), findsOneWidget);
      expect(find.text('รอบเดือนที่เลือก'), findsOneWidget);
    },
  );


  testWidgets(
    'SplashScreen displays TangKep branding, logo, and animated particle background',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const SplashScreen(),
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('ตังค์เก็บ'), findsOneWidget);
      expect(find.text('TangKep'), findsOneWidget);
      expect(find.byType(CustomPaint), findsWidgets);
      expect(find.byType(Image), findsOneWidget);

      await tester.pump(const Duration(milliseconds: 1500));
    },
  );

  testWidgets(
    'EmptyState widget displays custom title and message',
    (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EmptyState(
              title: 'ไม่มีรายการ',
              message: 'กรุณาเพิ่มรายการแรกของคุณ',
            ),
          ),
        ),
      );

      expect(find.text('ไม่มีรายการ'), findsOneWidget);
      expect(find.text('กรุณาเพิ่มรายการแรกของคุณ'), findsOneWidget);
    },
  );

  testWidgets(
    'TransactionCard renders deposit transaction correctly',
    (tester) async {
      final depositTx = TransactionModel(
        id: 1,
        type: 'deposit',
        amount: 1500.0,
        transactionDate: DateTime(2026, 10, 4),
        description: 'เงินเดือน',
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: TransactionCard(item: depositTx),
          ),
        ),
      );

      expect(find.text('เงินเดือน'), findsOneWidget);
      expect(find.textContaining('1,500.00'), findsOneWidget);
      expect(find.textContaining('+'), findsOneWidget);
    },
  );

  testWidgets(
    'TransactionCard renders withdrawal transaction correctly',
    (tester) async {
      final withdrawTx = TransactionModel(
        id: 2,
        type: 'withdraw',
        amount: 350.0,
        transactionDate: DateTime(2026, 10, 4),
        description: 'ค่าอาหาร',
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: TransactionCard(item: withdrawTx),
          ),
        ),
      );

      expect(find.text('ค่าอาหาร'), findsOneWidget);
      expect(find.textContaining('350.00'), findsOneWidget);
      expect(find.textContaining('-'), findsOneWidget);
    },
  );

  test('TransactionModel toPayload formats date to ISO YYYY-MM-DD', () {
    final tx = TransactionModel(
      id: 99,
      type: 'deposit',
      amount: 5000.0,
      transactionDate: DateTime(2026, 10, 4),
      description: 'โบนัส',
    );

    final payload = tx.toPayload();
    expect(payload['type'], 'deposit');
    expect(payload['amount'], 5000.0);
    expect(payload['transaction_date'], '2026-10-04');
    expect(payload['description'], 'โบนัส');
  });

  testWidgets(
    'AnimatedTangKepHeader renders title and actions',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const Scaffold(
            appBar: AnimatedTangKepHeader(
              title: 'ภาพรวม',
              actions: [
                Icon(Icons.logout),
              ],
            ),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 50));

      expect(find.text('ภาพรวม'), findsOneWidget);
      expect(find.byIcon(Icons.logout), findsOneWidget);
    },
  );

  testWidgets(
    'AnimatedTangKepHeader renders responsively across 360px, 390px, and 412px',
    (tester) async {
      for (final width in [360.0, 390.0, 412.0]) {
        tester.view.physicalSize = Size(width, 800);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);

        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.lightTheme,
            home: const Scaffold(
              appBar: AnimatedTangKepHeader(
                title: 'ตังค์เก็บ (TangKep)',
              ),
            ),
          ),
        );
        await tester.pump(const Duration(milliseconds: 50));

        expect(find.text('ตังค์เก็บ (TangKep)'), findsOneWidget);
        expect(tester.takeException(), isNull);
      }
    },
  );

  test('ProfileImageService saves, retrieves, and deletes profile image', () async {
    SharedPreferences.setMockInitialValues({});

    final testBytes = Uint8List.fromList([1, 2, 3, 4, 5, 6, 7, 8]);
    const username = 'testuser';

    // Verify initial is null
    final initial = await ProfileImageService.getProfileImage(username);
    expect(initial, isNull);

    // Save
    final saved = await ProfileImageService.saveProfileImage(username, testBytes);
    expect(saved, isTrue);

    // Retrieve
    final retrieved = await ProfileImageService.getProfileImage(username);
    expect(retrieved, isNotNull);
    expect(retrieved, equals(testBytes));

    // Delete
    final deleted = await ProfileImageService.deleteProfileImage(username);
    expect(deleted, isTrue);

    // Verify deleted
    final afterDelete = await ProfileImageService.getProfileImage(username);
    expect(afterDelete, isNull);
  });

  testWidgets('ProfileAvatar renders default person icon and editable camera badge', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: ProfileAvatar(
            radius: 32,
            isEditable: true,
          ),
        ),
      ),
    );

    expect(find.byIcon(Icons.person_rounded), findsOneWidget);
    expect(find.byIcon(Icons.camera_alt_rounded), findsOneWidget);
  });

  testWidgets('PersonalAccountApp initializes with AppAPI navigatorKey', (tester) async {
    await tester.pumpWidget(
      const PersonalAccountApp(),
    );
    await tester.pump(const Duration(milliseconds: 100));

    expect(AppAPI.navigatorKey.currentState, isNotNull);
    await tester.pump(const Duration(milliseconds: 1500));
  });

  test('Session token clearing preserves local profile image', () async {
    SharedPreferences.setMockInitialValues({
      'access_token': 'mock_token_123',
      'username': 'somchai',
      'profile_photo_somchai': 'base64_mock_data',
    });

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('access_token'), equals('mock_token_123'));
    expect(prefs.getString('profile_photo_somchai'), equals('base64_mock_data'));

    // Simulate session expiry / logout
    await prefs.remove('access_token');
    await prefs.remove('username');

    expect(prefs.getString('access_token'), isNull);
    expect(prefs.getString('username'), isNull);
    expect(prefs.getString('profile_photo_somchai'), equals('base64_mock_data'));
  });

  testWidgets('RegisterScreen toggles password and confirm password visibility independently', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: const RegisterScreen(),
      ),
    );

    // Find EditableText widgets or TextFormField widgets
    // Initially both password fields are obscured (obscureText = true)
    final passwordFields = find.byType(TextField);
    // 4 fields: Fullname, Username, Password, Confirm Password
    expect(passwordFields, findsNWidgets(4));

    TextField passwordField() => tester.widget<TextField>(passwordFields.at(2));
    TextField confirmField() => tester.widget<TextField>(passwordFields.at(3));

    expect(passwordField().obscureText, isTrue);
    expect(confirmField().obscureText, isTrue);

    // Check visibility toggle icons
    expect(find.byIcon(Icons.visibility_outlined), findsNWidgets(2));
    expect(find.byIcon(Icons.visibility_off_outlined), findsNothing);

    // Enter text in password and confirm password
    await tester.enterText(passwordFields.at(2), 'secret123');
    await tester.enterText(passwordFields.at(3), 'secret123');
    await tester.pump();

    // Toggle password visibility (first eye button)
    final toggleButtons = find.widgetWithIcon(IconButton, Icons.visibility_outlined);
    expect(toggleButtons, findsNWidgets(2));

    await tester.tap(toggleButtons.first);
    await tester.pump();

    // Password should be revealed, confirm password should still be obscured
    expect(passwordField().obscureText, isFalse);
    expect(confirmField().obscureText, isTrue);
    expect(passwordField().controller?.text, 'secret123');

    // One eye off, one eye on
    expect(find.byIcon(Icons.visibility_off_outlined), findsOneWidget);
    expect(find.byIcon(Icons.visibility_outlined), findsOneWidget);

    // Toggle confirm password visibility
    await tester.tap(find.widgetWithIcon(IconButton, Icons.visibility_outlined));
    await tester.pump();

    // Both should now be revealed
    expect(passwordField().obscureText, isFalse);
    expect(confirmField().obscureText, isFalse);
    expect(find.byIcon(Icons.visibility_off_outlined), findsNWidgets(2));
    expect(find.byIcon(Icons.visibility_outlined), findsNothing);

    // Toggle password back to hidden
    await tester.tap(find.widgetWithIcon(IconButton, Icons.visibility_off_outlined).first);
    await tester.pump();

    // Password hidden, confirm revealed
    expect(passwordField().obscureText, isTrue);
    expect(confirmField().obscureText, isFalse);
    expect(passwordField().controller?.text, 'secret123');
    expect(confirmField().controller?.text, 'secret123');
  });

  testWidgets('LoginScreen renders layered card with animated background and functional toggle', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: const LoginScreen(),
      ),
    );

    // Verify background particles CustomPaint
    expect(find.byType(CustomPaint), findsWidgets);

    // Verify brand logo and app title
    expect(find.byType(Image), findsOneWidget);
    expect(find.text('ตังค์เก็บ (TangKep)'), findsOneWidget);
    expect(find.text('Sign in'), findsOneWidget);
    expect(find.text('Create an account'), findsOneWidget);

    // Verify password field & toggle
    final passwordFieldFinder = find.byType(TextField).at(1);
    TextField passwordField() => tester.widget<TextField>(passwordFieldFinder);

    expect(passwordField().obscureText, isTrue);
    expect(find.byIcon(Icons.visibility_outlined), findsOneWidget);

    await tester.enterText(passwordFieldFinder, 'pass1234');
    await tester.pump();

    // Tap eye toggle to reveal
    await tester.tap(find.widgetWithIcon(IconButton, Icons.visibility_outlined));
    await tester.pump();

    expect(passwordField().obscureText, isFalse);
    expect(passwordField().controller?.text, 'pass1234');
    expect(find.byIcon(Icons.visibility_off_outlined), findsOneWidget);

    // Tap eye toggle to hide again
    await tester.tap(find.widgetWithIcon(IconButton, Icons.visibility_off_outlined));
    await tester.pump();

    expect(passwordField().obscureText, isTrue);
    expect(passwordField().controller?.text, 'pass1234');
  });

  testWidgets('LoginScreen renders responsively without overflow across 360px, 390px, and 412px', (tester) async {
    for (final width in [360.0, 390.0, 412.0]) {
      tester.view.physicalSize = Size(width, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const LoginScreen(),
        ),
      );

      expect(tester.takeException(), isNull);
      expect(find.text('ตังค์เก็บ (TangKep)'), findsOneWidget);
      expect(find.text('Sign in'), findsOneWidget);
    }
  });
}