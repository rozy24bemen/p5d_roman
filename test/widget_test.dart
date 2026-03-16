import 'package:flutter_test/flutter_test.dart';
import 'package:api_prueba/main.dart';

void main() {
  testWidgets('App loads and shows home screen', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    // Comprova que la pantalla principal es mostra
    expect(find.text('Pràctica 5d - APIs REST'), findsOneWidget);
    expect(find.text('Exercicis'), findsOneWidget);
  });
}
