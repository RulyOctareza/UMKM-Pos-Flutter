import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:umkm_pos/app/app.dart';

void main() {
  testWidgets('App bootstrapping test - renders UmkmPosApp without crash', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const ProviderScope(child: UmkmPosApp()));

    // Verifikasi inisialisasi MaterialApp
    expect(find.byType(UmkmPosApp), findsOneWidget);
  });
}
