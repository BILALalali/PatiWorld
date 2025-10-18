// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:pati_world/main.dart';

void main() {
  testWidgets('PatiWorld app smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const PatiWorldApp());

    // Verify that the app title is displayed
    expect(find.text('PatiWorld'), findsOneWidget);

    // Verify that the main screen elements are present
    expect(find.text('مرحباً بك في عالم الحيوانات الأليفة'), findsOneWidget);
    expect(
      find.text('اكتشف معلومات مفيدة عن رعاية حيواناتك الأليفة'),
      findsOneWidget,
    );

    // Verify that the bottom navigation bar is present
    expect(find.byType(Container), findsWidgets);
    
    // Verify that the home navigation item is present (it's always visible)
    expect(find.text('الرئيسية'), findsOneWidget);
    
    // Verify that the app builds without errors
    expect(find.byType(MaterialApp), findsOneWidget);
    expect(find.byType(Scaffold), findsAtLeastNWidgets(1));
  });
}
