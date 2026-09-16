import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  static const String _prefKeyHost = 'backend_host_override';
  static String? _configuredHost;

  /// Default LAN IP for physical mobile devices on the current local network
  static const String defaultLocalIp = '172.30.6.83:3000';

  /// Initialize and load any saved backend host preference, or auto-detect working route
  static Future<void> init() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _configuredHost = prefs.getString(_prefKeyHost);
      if (_configuredHost == null || _configuredHost!.isEmpty) {
        // Auto-detect which host responds
        if (await testConnection('localhost:3000')) {
          _configuredHost = 'localhost:3000';
        } else if (await testConnection(defaultLocalIp)) {
          _configuredHost = defaultLocalIp;
        } else if (await testConnection('10.0.2.2:3000')) {
          _configuredHost = '10.0.2.2:3000';
        }
      }
    } catch (_) {}
  }

  /// Override the backend host (e.g. '172.30.6.83:3000' or 'localhost:3000')
  static Future<void> setHost(String? host) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (host == null || host.trim().isEmpty) {
        _configuredHost = null;
        await prefs.remove(_prefKeyHost);
      } else {
        _configuredHost = host
            .trim()
            .replaceAll('http://', '')
            .replaceAll('https://', '')
            .replaceAll('/api', '')
            .replaceAll('/', '');
        await prefs.setString(_prefKeyHost, _configuredHost!);
      }
    } catch (_) {}
  }

  /// The active backend host and port
  static String get host {
    if (_configuredHost != null && _configuredHost!.isNotEmpty) {
      return _configuredHost!;
    }
    const envHost = String.fromEnvironment('BACKEND_HOST');
    if (envHost.isNotEmpty) {
      return envHost;
    }
    // Default to localhost:3000 (works directly via adb reverse, desktop, iOS simulator, and web)
    return 'localhost:3000';
  }

  static String get baseUrl => 'http://$host/api';
  static String get socketUrl => 'http://$host';

  /// Test connectivity to a given host or active host
  static Future<bool> testConnection([String? hostToTest]) async {
    final target = (hostToTest != null && hostToTest.isNotEmpty) ? hostToTest : host;
    final cleaned = target
        .replaceAll('http://', '')
        .replaceAll('https://', '')
        .replaceAll('/api', '')
        .replaceAll('/', '');
    try {
      final res = await http
          .get(Uri.parse('http://$cleaned/api/health'))
          .timeout(const Duration(seconds: 4));
      return res.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  String? _token;

  void setToken(String? token) {
    _token = token;
  }

  String? get token => _token;

  Map<String, String> _headers() {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (_token != null && _token!.isNotEmpty) {
      headers['Authorization'] = 'Bearer $_token';
    }
    return headers;
  }

  Future<dynamic> get(String endpoint) async {
    final uri = Uri.parse('$baseUrl$endpoint');
    try {
      final response = await http.get(uri, headers: _headers());
      return _handleResponse(response);
    } catch (e) {
      throw ApiException('Network error connecting to $endpoint: $e');
    }
  }

  Future<dynamic> post(String endpoint, [Map<String, dynamic>? body]) async {
    final uri = Uri.parse('$baseUrl$endpoint');
    try {
      final response = await http.post(
        uri,
        headers: _headers(),
        body: body != null ? jsonEncode(body) : null,
      );
      return _handleResponse(response);
    } catch (e) {
      throw ApiException('Network error posting to $endpoint: $e');
    }
  }

  Future<dynamic> put(String endpoint, Map<String, dynamic> body) async {
    final uri = Uri.parse('$baseUrl$endpoint');
    try {
      final response = await http.put(
        uri,
        headers: _headers(),
        body: jsonEncode(body),
      );
      return _handleResponse(response);
    } catch (e) {
      throw ApiException('Network error updating $endpoint: $e');
    }
  }

  dynamic _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) return null;
      return jsonDecode(response.body);
    } else {
      String errorMessage = 'Server error (${response.statusCode})';
      try {
        final decoded = jsonDecode(response.body);
        if (decoded is Map && decoded.containsKey('error')) {
          errorMessage = decoded['error'];
        } else if (decoded is Map && decoded.containsKey('message')) {
          errorMessage = decoded['message'];
        }
      } catch (_) {}
      throw ApiException(errorMessage, response.statusCode);
    }
  }
}

class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException(this.message, [this.statusCode]);

  @override
  String toString() => message;
}
