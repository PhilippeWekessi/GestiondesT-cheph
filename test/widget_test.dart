import 'package:flutter_test/flutter_test.dart';
import 'package:gestion_taches/main.dart';

void main() {
  testWidgets("affiche l'écran de connexion", (WidgetTester tester) async {
    await tester.pumpWidget(const GestionTachesApp());
    expect(find.text('Connexion'), findsOneWidget);
  });
}