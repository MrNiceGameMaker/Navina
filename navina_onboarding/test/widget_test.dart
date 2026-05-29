import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:navina_onboarding/main.dart';

void main() {
  testWidgets('NavinaApp renders without crashing', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: NavinaApp()));
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
