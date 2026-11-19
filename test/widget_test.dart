import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tp5_widget/main.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channel = MethodChannel('widget/maj');

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
      switch (call.method) {
        case 'nombreWidgets':
          return 0;
        case 'mettreAJour':
          return 0;
        case 'epingler':
          return false;
        default:
          return null;
      }
    });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  testWidgets('Affichage de la page de contrôle du widget',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: PageWidget(),
      ),
    );

    await tester.pump();

    expect(find.text('Contrôle du widget'), findsOneWidget);
    expect(find.text('Widgets installés'), findsOneWidget);
    expect(find.text('Ajouter le widget'), findsOneWidget);
    expect(find.text('Envoyer au widget'), findsOneWidget);
  });
}
