// Smoke + unit tests for the Yammo Admin Portal.

import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

import 'package:yammopaintingweb/controllers/auth_controller.dart';
import 'package:yammopaintingweb/models/svg_asset.dart';
import 'package:yammopaintingweb/screens/auth/login_screen.dart';
import 'package:yammopaintingweb/theme/app_theme.dart';
import 'package:yammopaintingweb/theme/theme_controller.dart';

void main() {
  testWidgets('Login screen renders sign-in form', (tester) async {
    Get.testMode = true;
    Get.put(ThemeController());
    Get.put(AuthController());

    await tester.pumpWidget(
      GetMaterialApp(theme: AppTheme.light, home: const LoginScreen()),
    );
    await tester.pump();

    expect(find.text('Sign In'), findsOneWidget);
    expect(find.text('Email'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);

    Get.reset();
  });

  test('SvgAsset.fromMap parses fields', () {
    final asset = SvgAsset.fromMap({
      'id': '1',
      'name': 'Cat',
      'category': 'Drawing',
      'target_app': 'AR Drawing',
      'is_active': true,
      'created_at': '2026-01-01T00:00:00Z',
    });

    expect(asset.name, 'Cat');
    expect(asset.category, 'Drawing');
    expect(asset.isActive, true);
  });
}
