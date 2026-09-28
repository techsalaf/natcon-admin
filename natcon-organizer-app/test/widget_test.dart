import 'package:flutter_test/flutter_test.dart';
import 'package:natcon_mobile/natcon_mobile.dart';

void main() {
  testWidgets('Unconfigured build fails closed without contacting vendor', (tester) async {
    await tester.pumpWidget(const NatconApp(staff: true, baseUrl: ''));
    expect(find.text('NATCON setup required'), findsOneWidget);
  });
}
