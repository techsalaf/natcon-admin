import 'dart:convert';

import 'package:http/http.dart' as http;

import 'data_store.dart';

class NatconHttp {
  static Map<String, String> _headers(Uri uri, Map<String, String>? supplied) {
    final headers = <String, String>{...?supplied};
    final natconApi = uri.path.contains('/user_api/') ||
        uri.path.contains('/orag_api/') ||
        uri.path.endsWith('/api/natcon.php');
    final token = getData.read('NATCON_ACCESS_TOKEN')?.toString() ?? '';
    if (natconApi && token.isNotEmpty) headers['Authorization'] = 'Bearer $token';
    return headers;
  }

  static Future<http.Response> post(
    Uri uri, {
    Map<String, String>? headers,
    Object? body,
    Encoding? encoding,
  }) =>
      http.post(uri, headers: _headers(uri, headers), body: body, encoding: encoding);

  static Future<http.Response> get(
    Uri uri, {
    Map<String, String>? headers,
  }) =>
      http.get(uri, headers: _headers(uri, headers));
}
