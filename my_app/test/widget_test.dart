import 'package:flutter_test/flutter_test.dart';
import 'package:my_app/main.dart';
void main() { testWidgets('login screen is displayed', (tester) async { await tester.pumpWidget(const SavingsAccountApp()); expect(find.text('บัญชีเงินฝากส่วนตัว'), findsOneWidget); expect(find.text('เข้าสู่ระบบ'), findsOneWidget); }); }
