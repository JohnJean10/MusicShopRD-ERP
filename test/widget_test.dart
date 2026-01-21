// Basic Flutter widget test for MusicShopRD ERP.

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:music_shop_erp/main.dart';

void main() {
  testWidgets('MusicShopRD App loads correctly', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const ProviderScope(child: MusicShopERPApp()));

    // Verify that the app title is displayed.
    expect(find.text('MusicShopRD Hub'), findsOneWidget);

    // Verify navigation items exist.
    expect(find.text('Inicio'), findsOneWidget);
    expect(find.text('Stock'), findsOneWidget);
    expect(find.text('Calc'), findsOneWidget);
    expect(find.text('Config'), findsOneWidget);
  });
}
