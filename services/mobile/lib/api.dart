import 'dart:convert';
import 'package:http/http.dart' as http;

class NatconApi {
  NatconApi(String baseUrl, {http.Client? client})
      : base = Uri.parse('${baseUrl.replaceFirst(RegExp(r'/+$'), '')}/'),
        client = client ?? http.Client();

  final Uri base;
  final http.Client client;
  String csrf = '';
  String cookie = '';
  String accessToken = '';

  static bool isValidBase(String value) {
    final uri = Uri.tryParse(value);
    if (uri == null || uri.host.isEmpty || uri.hasQuery || uri.hasFragment || uri.userInfo.isNotEmpty) return false;
    return uri.scheme == 'https' ||
        (uri.scheme == 'http' && ['localhost', '127.0.0.1', '10.0.2.2'].contains(uri.host));
  }

  Future<Map<String, dynamic>> call(String action, [Map<String, dynamic>? body, Map<String, String>? query]) async {
    final url = base.resolve('api/natcon.php').replace(queryParameters: {'action': action, ...?query});
    final headers = <String, String>{'Accept': 'application/json'};
    if (cookie.isNotEmpty) headers['Cookie'] = cookie;
    if (csrf.isNotEmpty) headers['X-CSRF-Token'] = csrf;
    if (accessToken.isNotEmpty) {
      headers['Authorization'] = 'Bearer $accessToken';
    }
    if (body != null) headers['Content-Type'] = 'application/json';
    final response = await (body == null
            ? client.get(url, headers: headers)
            : client.post(url, headers: headers, body: jsonEncode(body)))
        .timeout(const Duration(seconds: 30));
    final setCookie = response.headers['set-cookie'];
    if (setCookie != null) cookie = setCookie.split(';').first;
    dynamic decoded;
    try {
      decoded = jsonDecode(response.body);
    } catch (_) {
      throw const NatconException('The conference service is unavailable. Please try again.');
    }
    if (decoded is! Map || decoded['ok'] != true) {
      throw NatconException(decoded is Map
          ? (decoded['error'] is Map ? decoded['error']['message'] : decoded['error'])?.toString() ?? 'Request failed.'
          : 'Request failed.');
    }
    final data = Map<String, dynamic>.from(decoded['data'] as Map? ?? {});
    if (data['csrf_token'] is String) csrf = data['csrf_token'] as String;
    if (data['csrf'] is String) csrf = data['csrf'] as String;
    final user = data['user'];
    if (user is Map && user['access_token'] is String) accessToken = user['access_token'] as String;
    return data;
  }

  void close() => client.close();
}

class NatconException implements Exception {
  const NatconException(this.message);
  final String message;
  @override
  String toString() => message;
}
