import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class AuthController {
  static const _storage = FlutterSecureStorage();

  /// Returns null on success (204), or an error message string.
  Future<String?> login({
    required String baseUrl,
    required String token,
  }) async {
    final cleanBase = baseUrl.trim().replaceAll(RegExp(r'/+$'), '');
    final uri = Uri.parse('$cleanBase/api/v1/app/auth/login');

    try {
      final response = await http.post(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 204) {
        await Future.wait([
          _storage.write(key: 'baseUrl', value: cleanBase),
          _storage.write(key: 'authToken', value: token),
        ]);
        return null;
      }

      return _errorMessage(response.statusCode);
    } catch (_) {
      return 'Could not connect. Check your Base URL and try again.';
    }
  }

  String _errorMessage(int statusCode) => switch (statusCode) {
    401 => 'Invalid auth token.',
    403 => 'Access denied.',
    404 => 'Server not found. Check your Base URL.',
    _ => 'Login failed (HTTP $statusCode).',
  };
}
