import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:net_intelligence/app/app.dart';

void main() {
  testWidgets('アプリが起動する', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: NetIntelligenceApp()));
    await tester.pump();
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
