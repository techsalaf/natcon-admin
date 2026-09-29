import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('organizer app boots its existing event organizer navigation', () {
    final source = File('lib/main.dart').readAsStringSync();
    expect(source, contains("import 'package:magicmate_organizer/"));
    expect(source, contains('DefaultFirebaseOptions.currentPlatform'));
    expect(source, contains('GetMaterialApp('));
    expect(source, contains('home: onbording()'));
    expect(source, isNot(contains('NatconApp(')));
  });
}
