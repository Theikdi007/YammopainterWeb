// Verifies that create/edit flows show a success popup with an OK button
// (demo mode, so no real backend or file picker needed).

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:yammopaintingweb/app/bindings/home_binding.dart';
import 'package:yammopaintingweb/controllers/nav_controller.dart';
import 'package:yammopaintingweb/models/svg_asset.dart';
import 'package:yammopaintingweb/screens/svg/svg_form_dialog.dart';

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  testWidgets('SVG edit shows a success popup, OK dismisses it',
      (tester) async {
    Get.testMode = true;
    HomeBinding().dependencies();
    Get.find<NavController>(); // realize controllers

    final asset = SvgAsset(
      id: 'x',
      name: 'Cat',
      description: 'desc',
      category: 'Drawing',
      targetApp: 'AR Drawing',
      filePath: '',
      publicUrl: '',
      isActive: true,
      createdAt: DateTime(2026, 1, 1),
    );

    await tester.pumpWidget(const GetMaterialApp(home: Scaffold()));
    unawaited(Get.dialog<void>(SvgFormDialog(existing: asset)));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(find.text('SVG updated successfully.'), findsOneWidget);
    expect(find.widgetWithText(ElevatedButton, 'OK'), findsOneWidget);

    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();
    expect(find.text('SVG updated successfully.'), findsNothing);

    Get.reset();
  });
}
