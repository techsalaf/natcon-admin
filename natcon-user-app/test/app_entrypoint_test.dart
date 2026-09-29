import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('user app boots its existing routed app and Firebase setup', () {
    final source = File('lib/main.dart').readAsStringSync();
    expect(source, contains("import 'package:magicmate_user/"));
    expect(source, contains('DefaultFirebaseOptions.currentPlatform'));
    expect(source, contains('initialRoute: Routes.initial'));
    expect(source, contains('getPages: getPages'));
    expect(source, isNot(contains('NatconApp(')));
  });
}
