import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:natcon_mobile/api.dart';

void main() {
  test('mobile login token is sent on later staff API requests', () async {
    final requests = <http.Request>[];
    final token = List.filled(64, 'a').join();
    final client = MockClient((request) async {
      requests.add(request);
      final action = request.url.queryParameters['action'];
      if (action == 'mobile_login') {
        return http.Response(jsonEncode({'ok': true, 'data': {'user': {'id': 4, 'role': 'registrar', 'access_token': token}}}), 200);
      }
      return http.Response(jsonEncode({'ok': true, 'data': {'result': 'accepted'}}), 200);
    });
    final api = NatconApi('https://natcon.example', client: client);
    final login = await api.call('mobile_login', {'email': 'registrar@example.test', 'password': 'test-password'});
    expect(login['user']['role'], 'registrar');
    await api.call('checkin', {'token': 'ticket-token', 'mode': 'arrival'});
    expect(requests[0].url.path, '/api/natcon.php');
    expect(requests[1].headers['authorization'], 'Bearer $token');
    expect(jsonDecode(requests[1].body)['token'], 'ticket-token');
    api.close();
  });
}
