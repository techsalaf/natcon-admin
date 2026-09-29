import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:magicmate_user/screen/natcon_delegate_details.dart';

void main() {
  testWidgets('requires complete delegate details and privacy consent', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1000, 1800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    List<Map<String, String>>? result;
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: ElevatedButton(
                onPressed: () async {
                  result = await Navigator.of(context)
                      .push<List<Map<String, String>>>(
                        MaterialPageRoute(
                          builder: (_) => const NatconDelegateDetailsScreen(
                            count: 1,
                            account: {'name': '', 'email': '', 'mobile': ''},
                          ),
                        ),
                      );
                },
                child: const Text('Open details'),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open details'));
    await tester.pumpAndSettle();
    final continueButton = find.text('Continue to secure payment');
    await tester.tap(continueButton);
    await tester.pumpAndSettle();
    expect(find.text('Required'), findsNWidgets(7));
    expect(result, isNull);

    final fields = find.byType(TextFormField);
    const values = [
      'Test Delegate',
      'delegate@example.test',
      'Islamic Studies',
      'Test University',
      'Graduate',
      '+2348000000000',
      '',
      'Osun',
      '2',
    ];
    for (var i = 0; i < values.length; i++) {
      await tester.enterText(fields.at(i), values[i]);
    }
    await tester.tap(find.byType(CheckboxListTile));
    await tester.pump();
    await tester.tap(continueButton);
    await tester.pumpAndSettle();

    expect(result, hasLength(1));
    expect(result!.single['institution'], 'Test University');
    expect(result!.single['times_attended'], '2');
    expect(result!.single['calling_line'], '');
  });
}
