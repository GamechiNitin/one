import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import '../error/exceptions.dart';
import 'mock_backend.dart';

abstract class ApiClient {
  Future<dynamic> get(String path);
  Future<dynamic> post(String path, {Map<String, dynamic>? body});
}

/// Real HTTP client. Used when MOCK_API=false.
class HttpApiClient implements ApiClient {
  final http.Client _client;
  final String baseUrl;
  HttpApiClient(this._client, {this.baseUrl = AppConfig.baseUrl});

  @override
  Future<dynamic> get(String path) => _send(() => _client.get(Uri.parse('$baseUrl$path')));

  @override
  Future<dynamic> post(String path, {Map<String, dynamic>? body}) => _send(() => _client.post(
        Uri.parse('$baseUrl$path'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body ?? {}),
      ));

  Future<dynamic> _send(Future<http.Response> Function() call) async {
    try {
      final r = await call().timeout(AppConfig.timeout);
      if (r.statusCode >= 400) throw ServerException('HTTP ${r.statusCode}', r.statusCode);
      return jsonDecode(utf8.decode(r.bodyBytes));
    } on ServerException {
      rethrow;
    } catch (_) {
      throw const NetworkException();
    }
  }
}

/// In-memory backend with simulated latency. Used by default so the app runs offline.
class MockApiClient implements ApiClient {
  final MockBackend _backend;
  MockApiClient(this._backend);

  @override
  Future<dynamic> get(String path) async {
    await Future<void>.delayed(AppConfig.mockLatency);
    return _backend.handleGet(path);
  }

  @override
  Future<dynamic> post(String path, {Map<String, dynamic>? body}) async {
    await Future<void>.delayed(AppConfig.mockLatency);
    return _backend.handlePost(path, body ?? const {});
  }
}
