import 'package:flutter_test/flutter_test.dart';
import 'package:jasmina/main.dart';

void main() {
  testWidgets('Jasmin app opens', (tester) async {
    await tester.pumpWidget(const JasminApp());
    await tester.pump();
    expect(find.text('Jasmin'), findsWidgets);
  });
}
